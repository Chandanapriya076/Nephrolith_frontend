//
// UploadCTScanView.swift
// RenalCalculi
// REFACTORED - Complete Backend Integration with Auto-Navigation
// FIXED - Type-checking error by extracting subviews

import SwiftUI
import Network

// MARK: - Network Monitor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue.global(qos: .background)
    
    @Published var isConnected: Bool = true
    
    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = (path.status == .satisfied)
            }
        }
        monitor.start(queue: queue)
    }
    
    deinit {
        monitor.cancel()
    }
}

// MARK: - Main View
struct UploadCTScanView: View {
    @State private var selectedImage: UIImage?
    @State private var isImagePickerPresented = false
    @State private var isLoading = false
    @State private var resultText = ""
    @State private var showResult = false
    @State private var navigateToResult = false
    @State private var aiResultData: [String: Any] = [:]
    
    // Animation states
    @State private var headerOpacity: Double = 0
    @State private var headerOffset: CGFloat = -30
    @State private var imagePreviewScale: CGFloat = 0.8
    @State private var imagePreviewOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: Double = 0
    @State private var scanLineOffset: CGFloat = 0
    @State private var pulseAnimation: Bool = false
    @State private var rotationAngle: Double = 0
    
    private let tfliteHelper = TFLiteHelper()
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    private var patientPID: String {
        UserDefaults.standard.string(forKey: "patientPID") ?? "P12345"
    }
    
    var body: some View {
        ZStack {
            // Medical gradient background
            BackgroundView(rotationAngle: $rotationAngle)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Section
                    HeaderSectionView(
                        headerOpacity: $headerOpacity,
                        headerOffset: $headerOffset,
                        pulseAnimation: $pulseAnimation
                    )
                    
                    // Image Preview & Action Buttons Section
                    ImagePreviewSection(
                        selectedImage: $selectedImage,
                        isImagePickerPresented: $isImagePickerPresented,
                        isLoading: $isLoading,
                        imagePreviewScale: $imagePreviewScale,
                        imagePreviewOpacity: $imagePreviewOpacity,
                        buttonsOffset: $buttonsOffset,
                        buttonsOpacity: $buttonsOpacity,
                        scanLineOffset: $scanLineOffset,
                        onAnalyze: analyzeImage
                    )
                    
                    // Status/Result Card
                    if showResult {
                        ResultCardView(resultText: resultText)
                    }
                    
                    // Info Card
                    InfoCardView(networkMonitor: networkMonitor)
                    
                    .padding(.bottom, 40)
                }
            }
            
            // ✅ NAVIGATION LINK (HIDDEN)
            NavigationLink(
                destination: aiResultData.isEmpty ?
                    AnyView(Text("Analysis failed")) :
                    AnyView(AIResultView(uploadedImage: selectedImage, aiResult: aiResultData, patientPID: patientPID)),
                isActive: $navigateToResult
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarTitle("Upload Scan", displayMode: .inline)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: selectedImage) { _ in
            withAnimation(.spring(response: 0.5)) {
                imagePreviewScale = 0.95
            }
            
            withAnimation(.spring(response: 0.5).delay(0.1)) {
                imagePreviewScale = 1.0
            }
        }
        .onChange(of: isLoading) { loading in
            if loading {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    scanLineOffset = 280
                }
            } else {
                scanLineOffset = 0
            }
        }
    }
    
    // MARK: - Animation Setup
    private func startAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            headerOpacity = 1.0
            headerOffset = 0
        }
        
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.1)) {
            imagePreviewScale = 1.0
            imagePreviewOpacity = 1.0
        }
        
        withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
            buttonsOffset = 0
            buttonsOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseAnimation.toggle()
        }
        
        withAnimation(.linear(duration: 20.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
    
    
    // MARK: - Analyze Flow
    private func analyzeImage() {
        guard let image = selectedImage else {
            resultText = "Please select an image"
            return
        }
        
        isLoading = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let tfliteHelper = tfliteHelper,
               let result = tfliteHelper.inferAndBuildResult(on: image) {
                DispatchQueue.main.async {
                    self.aiResultData = result
                    self.resultText = result["status"] as? String ?? "Analysis complete"
                    self.showResult = true
                    self.isLoading = false
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigateToResult = true
                    }
                    
                    print("✅ Analysis complete")
                    print("📊 Result: \(result)")
                }
            } else {
                DispatchQueue.main.async {
                    self.resultText = "Analysis failed"
                    self.isLoading = false
                }
            }
        }
        
    }
}



// MARK: - Background View
struct BackgroundView: View {
    @Binding var rotationAngle: Double
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.88, green: 0.94, blue: 0.98)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 100))
                    .foregroundColor(Color.blue.opacity(0.03))
                    .rotationEffect(.degrees(rotationAngle))
                    .offset(x: geometry.size.width * 0.7, y: 50)
                
                Image(systemName: "cross.case")
                    .font(.system(size: 80))
                    .foregroundColor(Color.teal.opacity(0.04))
                    .rotationEffect(.degrees(-rotationAngle))
                    .offset(x: -20, y: geometry.size.height * 0.6)
            }
        }
    }
}

// MARK: - Header Section View
struct HeaderSectionView: View {
    @Binding var headerOpacity: Double
    @Binding var headerOffset: CGFloat
    @Binding var pulseAnimation: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                // Animated pulse rings
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 2)
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                    .opacity(pulseAnimation ? 0 : 0.8)
                
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                    .frame(width: 90, height: 90)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .opacity(pulseAnimation ? 0 : 1)
                
                // Icon container
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.blue,
                                    Color.blue.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.blue.opacity(0.3), radius: 15, x: 0, y: 8)
                    
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            VStack(spacing: 6) {
                Text("CT Scan Analysis")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.1, green: 0.2, blue: 0.4))
                
                Text("Upload kidney CT scan for AI-powered Result")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .padding(.top, 30)
        .padding(.bottom, 20)
        .opacity(headerOpacity)
        .offset(y: headerOffset)
    }
}

// MARK: - Image Preview Section
struct ImagePreviewSection: View {
    @Binding var selectedImage: UIImage?
    @Binding var isImagePickerPresented: Bool
    @Binding var isLoading: Bool
    @Binding var imagePreviewScale: CGFloat
    @Binding var imagePreviewOpacity: Double
    @Binding var buttonsOffset: CGFloat
    @Binding var buttonsOpacity: Double
    @Binding var scanLineOffset: CGFloat
    
    var onAnalyze: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ImagePreviewCard(
                selectedImage: selectedImage,
                isLoading: isLoading,
                scanLineOffset: scanLineOffset,
                imagePreviewScale: imagePreviewScale,
                imagePreviewOpacity: imagePreviewOpacity,
                onRemove: {
                    withAnimation(.spring(response: 0.4)) {
                        selectedImage = nil
                    }
                }
            )
            
            // Action Buttons
            ActionButtonsView(
                selectedImage: selectedImage,
                isLoading: isLoading,
                buttonsOffset: buttonsOffset,
                buttonsOpacity: buttonsOpacity,
                onChoose: {
                    isImagePickerPresented = true
                },
                onAnalyze: onAnalyze
            )
        }
    }
}

// MARK: - Image Preview Card
struct ImagePreviewCard: View {
    let selectedImage: UIImage?
    let isLoading: Bool
    let scanLineOffset: CGFloat
    let imagePreviewScale: CGFloat
    let imagePreviewOpacity: Double
    let onRemove: () -> Void
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 20)
            
            if let image = selectedImage {
                VStack(spacing: 16) {
                    ZStack {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 280)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.blue.opacity(0.5),
                                                Color.teal.opacity(0.5)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                        
                        if isLoading {
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.clear,
                                            Color.blue.opacity(0.4),
                                            Color.clear
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(height: 4)
                                .offset(y: scanLineOffset)
                                .cornerRadius(2)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        
                        Text("Image Loaded")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: onRemove) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.green.opacity(0.1))
                    )
                    .padding(20)
                }
            } else {
                VStack(spacing: 20) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                style: StrokeStyle(lineWidth: 2, dash: [10, 5])
                            )
                            .foregroundColor(Color.blue.opacity(0.3))
                            .frame(height: 280)
                        
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue.opacity(0.6))
                            }
                            
                            VStack(spacing: 6) {
                                Text("No CT Scan Selected")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.secondary)
                                
                                Text("Tap below to upload")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary.opacity(0.7))
                            }
                        }
                        .padding(20)
                    }
                }
            }
        }
        .scaleEffect(imagePreviewScale)
        .opacity(imagePreviewOpacity)
    }
}

// MARK: - Action Buttons View
struct ActionButtonsView: View {
    let selectedImage: UIImage?
    let isLoading: Bool
    let buttonsOffset: CGFloat
    let buttonsOpacity: Double
    let onChoose: () -> Void
    let onAnalyze: () -> Void
    
    var body: some View {
        VStack(spacing: 14) {
            // Upload Button
            Button(action: onChoose) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "photo.fill.on.rectangle.fill")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text("Choose CT Scan")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue,
                            Color.blue.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            
            // Analyze Button
            Button(action: onAnalyze) {
                HStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.3))
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "waveform.path.ecg")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    
                    Text(isLoading ? "Analyzing Scan..." : "Start AI Analysis")
                        .font(.system(size: 17, weight: .semibold))
                    
                    if !isLoading {
                        Spacer()
                        
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: selectedImage == nil ? [
                            Color.gray.opacity(0.5),
                            Color.gray.opacity(0.4)
                        ] : [
                            Color.green,
                            Color.green.opacity(0.8)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: selectedImage == nil ? Color.clear : Color.green.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .disabled(selectedImage == nil || isLoading)
            .opacity(selectedImage == nil ? 0.5 : 1.0)
        }
        .padding(.horizontal, 20)
        .offset(y: buttonsOffset)
        .opacity(buttonsOpacity)
    }
}

// MARK: - Result Card View
struct ResultCardView: View {
    let resultText: String
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Analysis Complete")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(resultText)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.green.opacity(0.2), radius: 15, x: 0, y: 5)
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .transition(.scale.combined(with: .opacity))
    }
}

// MARK: - Info Card View
struct InfoCardView: View {
    let networkMonitor: NetworkMonitor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                
                Text("Analysis Information")
                    .font(.system(size: 15, weight: .semibold))
            }
            
            VStack(alignment: .leading, spacing: 10) {
                InfoRow(
                    icon: "checkmark.shield.fill",
                    label: "Detection Mode",
                    text: "AI-powered detection",
                    color: .green
                )
                
                InfoRow(
                    icon: "network",
                    label: "Connection",
                    text: networkMonitor.isConnected ? "Online mode available" : "Offline mode active",
                    color: networkMonitor.isConnected ? .blue : .orange
                )
                
                InfoRow(
                    icon: "lock.shield.fill",
                    label: "Privacy",
                    text: "Secure & confidential",
                    color: .orange
                )
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.7))
        )
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}

// MARK: - Info Row Component
struct InfoRow: View {
    let icon: String
    let label: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(text)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        UploadCTScanView()
    }
}
