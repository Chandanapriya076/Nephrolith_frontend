//
//  TFLiteHelper.swift
//  RenalCalculi
//
//  Updated: 2025-12-05
//

import UIKit
import TensorFlowLite

// MARK: - Array extension for raw float decoding
extension Array where Element == Float {
    init?(unsafeData: Data) {
        let floatSize = MemoryLayout<Float>.size
        guard unsafeData.count % floatSize == 0 else { return nil }
        let count = unsafeData.count / floatSize
        self = unsafeData.withUnsafeBytes { rawBuffer -> [Float] in
            let ptr = rawBuffer.bindMemory(to: Float.self)
            guard let base = ptr.baseAddress else { return [] }
            return Array(UnsafeBufferPointer(start: base, count: count))
        }
    }
}

// MARK: - UIImage extension for simple CT scan heuristic
extension UIImage {
    var isProbablyCTScan: Bool {
        guard let cg = self.cgImage else { return false }
        let width = cg.width
        let height = cg.height

        // Aspect ratio check: CT scans are usually square-ish
        let ratio = Double(width) / Double(height)
        guard ratio > 0.8 && ratio < 1.2 else { return false }

        // Grayscale check
        guard let data = cg.dataProvider?.data else { return false }
        let ptr = CFDataGetBytePtr(data)
        var grayPixels = 0
        let total = width * height

        for i in stride(from: 0, to: total*4, by: 4) {
            let r = ptr?[i] ?? 0
            let g = ptr?[i+1] ?? 0
            let b = ptr?[i+2] ?? 0
            if abs(Int(r) - Int(g)) < 10 && abs(Int(g) - Int(b)) < 10 {
                grayPixels += 1
            }
        }

        let grayRatio = Double(grayPixels) / Double(total)
        return grayRatio > 0.9 // at least 90% gray pixels
    }
}

// MARK: - TFLiteHelper
final class TFLiteHelper {
    private var interpreter: Interpreter
    private let inputWidth: Int
    private let inputHeight: Int
    private var inputChannels: Int = 3
    private let threadCount: Int = 1
    var debugLogs: Bool = true

    /// Optional CT scan checker
    var ctChecker: ((UIImage) -> Bool)? = { image in
        image.isProbablyCTScan
    }

    init?() {
        guard let modelPath = Bundle.main.path(forResource: "best_float32", ofType: "tflite") else {
            print("❌ TFLite model not found in bundle")
            return nil
        }
        do {
            var options = Interpreter.Options()
            options.threadCount = threadCount
            interpreter = try Interpreter(modelPath: modelPath, options: options)
            try interpreter.allocateTensors()

            let inputTensor = try interpreter.input(at: 0)
            let dims = inputTensor.shape.dimensions
            guard dims.count == 4 else {
                print("❌ Invalid model input shape: \(dims)")
                return nil
            }

            inputChannels = dims[1]
            inputHeight = dims[2]
            inputWidth = dims[3]

            if debugLogs {
                print("📊 Model input shape: [batch=\(dims[0]), channels=\(inputChannels), height=\(inputHeight), width=\(inputWidth)]")
            }
        } catch {
            print("❌ Interpreter init error:", error)
            return nil
        }
    }

    // MARK: - Low-level inference
    func runModel(on image: UIImage) -> [Float]? {
        // Check if image is a CT scan
        if let checker = ctChecker, !checker(image) {
            print("⚠️ Image rejected: not a CT scan")
            return nil
        }

        guard let inputData = imageToCHWFloatData(image: image) else {
            debugPrint("❌ Preprocessing failed")
            return nil
        }

        do {
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()
            let output = try interpreter.output(at: 0)
            let floats = [Float](unsafeData: output.data) ?? []
            if debugLogs { print("✅ runModel() output count: \(floats.count)") }
            return floats
        } catch {
            debugPrint("❌ Inference error:", error)
            return nil
        }
    }

    // MARK: - High-level inference: JSON-like result
    func inferAndBuildResult(on image: UIImage, mmPerPixel: Double = 0.5, scoreThreshold: Float = 0.3, iouThreshold: Float = 0.45) -> [String: Any]? {
        // Reject non-CT scan images
        if let checker = ctChecker, !checker(image) {
            return [
                "status": "Invalid Input",
                "stone_count": 0,
                "stone_sizes_mm": [],
                "stone_locations": [],
                "annotated_image": "",
                "source": "offline"
            ]
        }

        guard let inputData = imageToCHWFloatData(image: image) else { return nil }

        do {
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()
            let output = try interpreter.output(at: 0)
            guard let flat = [Float](unsafeData: output.data) else { return nil }

            // Expect [1,6,21504]
            let total = flat.count
            guard total % 6 == 0 else { return classifyFromFlat(flat) }

            let anchorsCount = total / 6
            func val(channel: Int, idx: Int) -> Float { flat[channel * anchorsCount + idx] }

            var candidates: [(rect: CGRect, score: Float)] = []
            for i in 0..<anchorsCount {
                let cx = val(channel: 0, idx: i)
                let cy = val(channel: 1, idx: i)
                let w  = val(channel: 2, idx: i)
                let h  = val(channel: 3, idx: i)
                let conf = val(channel: 4, idx: i)
                if conf < scoreThreshold { continue }

                let normalized = (0...1 ~= cx && 0...1 ~= cy && 0...1 ~= w && 0...1 ~= h)
                let rect: CGRect
                if normalized {
                    let modelCx = CGFloat(cx) * CGFloat(inputWidth)
                    let modelCy = CGFloat(cy) * CGFloat(inputHeight)
                    let modelW = CGFloat(w) * CGFloat(inputWidth)
                    let modelH = CGFloat(h) * CGFloat(inputHeight)
                    rect = CGRect(x: modelCx - modelW/2, y: modelCy - modelH/2, width: modelW, height: modelH)
                } else {
                    rect = CGRect(x: CGFloat(cx - w/2), y: CGFloat(cy - h/2), width: CGFloat(w), height: CGFloat(h))
                }

                if rect.width >= 2 && rect.height >= 2 {
                    candidates.append((rect: rect, score: conf))
                }
            }

            let kept = nonMaximumSuppression(boxes: candidates, iouThreshold: iouThreshold)
            if kept.isEmpty { return classifyFromFlat(flat) }

            // Map boxes to original image
            let originalSize = image.size
            let scaleX = originalSize.width / CGFloat(inputWidth)
            let scaleY = originalSize.height / CGFloat(inputHeight)

            var sizesMM: [Double] = []
            var locations: [String] = []
            var annotatedEntries: [(CGRect, String)] = []

            for item in kept {
                var rect = item.rect
                rect.origin.x *= scaleX
                rect.origin.y *= scaleY
                rect.size.width *= scaleX
                rect.size.height *= scaleY

                let sizeMM = Double(max(rect.width, rect.height)) * mmPerPixel
                sizesMM.append(round(sizeMM * 100) / 100.0)

                let location = rect.midX > originalSize.width / 2 ? "Right Kidney" : "Left Kidney"
                locations.append(location)

                annotatedEntries.append((rect, String(format: "%.2f", item.score)))
            }

            let annotatedURL = saveAnnotatedImage(original: image, boxes: annotatedEntries)
            return [
                "status": sizesMM.isEmpty ? "" : "",
                "stone_count": sizesMM.count,
                "stone_sizes_mm": sizesMM,
                "stone_locations": locations,
                "annotated_image": annotatedURL?.absoluteString ?? "",
                "source": "offline"
            ]
        } catch {
            debugPrint("❌ Inference failed:", error)
            return nil
        }
    }

    // MARK: - Helpers
    private func nonMaximumSuppression(boxes: [(rect: CGRect, score: Float)], iouThreshold: Float) -> [(rect: CGRect, score: Float)] {
        var sorted = boxes.sorted { $0.score > $1.score }
        var kept: [(rect: CGRect, score: Float)] = []

        while !sorted.isEmpty {
            let current = sorted.removeFirst()
            kept.append(current)
            sorted = sorted.filter { iouBetween(a: current.rect, b: $0.rect) <= CGFloat(iouThreshold) }
        }
        return kept
    }

    private func iouBetween(a: CGRect, b: CGRect) -> CGFloat {
        let inter = a.intersection(b)
        if inter.isNull { return 0 }
        let interArea = inter.width * inter.height
        let union = a.width * a.height + b.width * b.height - interArea
        return union > 0 ? interArea / union : 0
    }

    private func classifyFromFlat(_ flat: [Float]) -> [String: Any]? {
        guard flat.count >= 2 else { return nil }
        let isStone = flat[1] > flat[0] && flat[1] > 0.5
        return [
            "status": isStone ? "" : "",
            "stone_count": isStone ? 1 : 0,
            "stone_sizes_mm": [],
            "stone_locations": isStone ? ["Unknown"] : [],
            "annotated_image": "",
            "source": "offline"
        ]
    }

    private func imageToCHWFloatData(image: UIImage) -> Data? {
        guard let cg = image.cgImage else { return nil }
        let bytesPerPixel = 4
        let modelW = inputWidth
        let modelH = inputHeight
        let bytesPerRow = modelW * bytesPerPixel
        var raw = [UInt8](repeating: 0, count: modelH * bytesPerRow)
        guard let ctx = CGContext(data: &raw, width: modelW, height: modelH, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        ctx.interpolationQuality = .high
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: modelW, height: modelH))

        var r = [Float32](repeating: 0, count: modelW*modelH)
        var g = [Float32](repeating: 0, count: modelW*modelH)
        var b = [Float32](repeating: 0, count: modelW*modelH)

        for y in 0..<modelH {
            for x in 0..<modelW {
                let off = y * bytesPerRow + x * bytesPerPixel
                let pos = y * modelW + x
                r[pos] = Float32(raw[off]) / 255.0
                g[pos] = Float32(raw[off+1]) / 255.0
                b[pos] = Float32(raw[off+2]) / 255.0
            }
        }
        var final = r + g + b
        return Data(bytes: &final, count: final.count * MemoryLayout<Float32>.size)
    }

    private func saveAnnotatedImage(original: UIImage, boxes: [(CGRect, String)]) -> URL? {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(original.size, false, scale)
        original.draw(in: CGRect(origin: .zero, size: original.size))
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        ctx.setLineWidth(3)
        ctx.setStrokeColor(UIColor.red.cgColor)
        let font = UIFont.systemFont(ofSize: max(12, min(24, original.size.width * 0.03)))
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.white,
            .backgroundColor: UIColor.red
        ]

        for (rect, label) in boxes {
            ctx.stroke(rect)
            let labelPoint = CGPoint(x: rect.origin.x + 4, y: max(4, rect.origin.y - font.lineHeight - 4))
            NSString(string: label).draw(at: labelPoint, withAttributes: attrs)
        }

        let annotated = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let img = annotated, let data = img.jpegData(compressionQuality: 0.9) else { return nil }
        let tmp = FileManager.default.temporaryDirectory
        let path = tmp.appendingPathComponent("annotated_\(UUID().uuidString).jpg")
        do {
            try data.write(to: path)
            return path
        } catch {
            debugPrint("❌ Save annotated error:", error)
            return nil
        }
    }
}
