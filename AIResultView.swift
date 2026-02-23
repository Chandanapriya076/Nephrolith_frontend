// AIResultView.swift - CORRECTED: Send annotated image file instead of uploaded image
// RenalCalculi
// FIXED: Send annotated image file from URL, not uploaded image file

import SwiftUI

struct AIResultView: View {
    var uploadedImage: UIImage?
    var aiResult: [String: Any] = [:]
    var patientPID: String = ""
    
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    
    // Animation states
    @State private var headerScale: CGFloat = 0.5
    @State private var headerOpacity: Double = 0
    @State private var cardOffset: CGFloat = 100
    @State private var cardOpacity: Double = 0
    @State private var pulseAnimation: Bool = false
    @State private var rotationAngle: Double = 0
    @State private var successCheckmark: Bool = false
    @State private var stoneCardAnimation: [Bool] = []
    
    // Database save states
    @State private var isSavingToDB = false
    @State private var savingMessage = ""
    @State private var savingError: String? = nil
    @State private var savingSuccess = false

    @State private var showGlobalCitation = true
    
    @StateObject private var viewModel = HistoryViewModel()
    
    @AppStorage("patientName") var patientName: String = ""
    
    // State for downloaded annotated image
    @State private var downloadedAnnotatedImage: UIImage?
    @State private var isLoadingAnnotatedImage = false
    
    var body: some View {
        ZStack {
            // Premium Teal-White Gradient Background
            backgroundView
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    headerSection
                    
                    // Medical Citation Tab
                    if aiResult["status"] as? String != "Invalid Input" {
                        medicalCitationSection
                    }
                    
                    if let error = aiResult["status"] as? String, error == "Invalid Input" {
                        invalidImageSection
                    }
                    
                    if let image = uploadedImage {
                        uploadedImageSection(image)
                    }
                    
                    if isLoading {
                        loadingSection
                    }
                    
                    if let label = aiResult["status"] as? String,
                       label != "Invalid Input" {
                        aiResultCard(label)
                    }
                    
                    // Show annotated image section if we have the downloaded image or URL
                    if let annotatedURLString = aiResult["annotated_image"] as? String,
                       aiResult["status"] as? String != "Invalid Input" {
                        annotatedImageSection(annotatedURLString)
                    }
                    
                    if let sizes = aiResult["stone_sizes_mm"] as? [Double],
                       let locations = aiResult["stone_locations"] as? [String],
                       sizes.count == locations.count,
                       !sizes.isEmpty,
                       aiResult["status"] as? String != "Invalid Input" {
                        stoneDetailsSection(sizes: sizes, locations: locations)
                    }
                    
                    // Save to Database Button
                    saveButtonSection
                    
                    if aiResult["status"] as? String != "Invalid Input",
                       aiResult["status"] != nil {
                        successMessageSection
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 10)
            }
        }
        .navigationBarTitle("AI Result", displayMode: .inline)
        .onAppear {
            setupAnimations()
            viewModel.processAIResult(aiResult)
            
            // Download annotated image automatically when view appears
            if let annotatedURLString = aiResult["annotated_image"] as? String {
                downloadAnnotatedImage(from: annotatedURLString)
            }
        }
    }
    
    // MARK: - View Components
    
    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.98, blue: 0.98),
                    Color.white,
                    Color(red: 0.88, green: 0.96, blue: 0.96)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GeometryReader { geometry in
                Circle()
                    .fill(Color.teal.opacity(0.03))
                    .frame(width: 250, height: 250)
                    .blur(radius: 40)
                    .offset(x: -50, y: 100)
                
                Circle()
                    .fill(Color.cyan.opacity(0.04))
                    .frame(width: 300, height: 300)
                    .blur(radius: 50)
                    .offset(x: geometry.size.width - 150, y: geometry.size.height - 200)
                
                Image(systemName: "cross.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.teal.opacity(0.04))
                    .rotationEffect(.degrees(rotationAngle))
                    .offset(x: geometry.size.width * 0.8, y: 80)
                
                Image(systemName: "heart.text.square")
                    .font(.system(size: 70))
                    .foregroundColor(Color.cyan.opacity(0.03))
                    .rotationEffect(.degrees(-rotationAngle * 0.7))
                    .offset(x: 20, y: geometry.size.height * 0.7)
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.teal.opacity(0.3), Color.cyan.opacity(0.2)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                    .opacity(pulseAnimation ? 0 : 0.6)
                
                Circle()
                    .stroke(Color.teal.opacity(0.4), lineWidth: 2)
                    .frame(width: 90, height: 90)
                    .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                    .opacity(pulseAnimation ? 0 : 0.8)
                
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.teal,
                                    Color.teal.opacity(0.8)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.teal.opacity(0.4), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "sparkles.rectangle.stack.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                }
                .scaleEffect(headerScale)
                .opacity(headerOpacity)
            }
            
            VStack(spacing: 6) {
                Text("Analysis Results")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.5))
                
                Text("AI-Powered Diagnostic Report")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 20)
        .padding(.bottom, 10)
        .overlay(
            Group {
                if showGlobalCitation {
                    VStack {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Source Citation")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.white)
                                
                                Text("EAU/AUA Urolithiasis Guidelines 2025")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                                .onTapGesture {
                                    withAnimation(.easeInOut(duration: 0.15)) {
                                        showGlobalCitation = false
                                    }
                                }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.85))
                            .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    )
                    .offset(y: -40)
                }
            }
            , alignment: .topTrailing
        )
    }
    
    private var medicalCitationSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text("Based on EAU/AUA clinical guidelines")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                
                Button("View Guidelines →") {
                    if let url = URL(string: "https://uroweb.org/guidelines/urolithiasis") {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.system(size: 13))
                .foregroundColor(.purple)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.purple.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.purple.opacity(0.15), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
        .opacity(cardOpacity)
    }
    
    private var invalidImageSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.red)
            }
            
            VStack(spacing: 8) {
                Text("Invalid Image Detected")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.red)
                
                Text("The uploaded image could not be analyzed. Please ensure you upload a valid CT scan image.")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            .padding(.vertical, 30)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.red.opacity(0.15), radius: 15, x: 0, y: 8)
            )
            .padding(.horizontal, 20)
            .offset(y: cardOffset)
            .opacity(cardOpacity)
        }
    }
    
    private func uploadedImageSection(_ image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "photo.fill.on.rectangle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.teal)
                
                Text("Original CT Scan")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.teal.opacity(0.5),
                                        Color.cyan.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: Color.teal.opacity(0.2), radius: 15, x: 0, y: 8)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            .offset(y: cardOffset)
            .opacity(cardOpacity)
        }
    }
    
    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.teal)
            
            Text("Analyzing Image...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 40)
    }
    
    private func aiResultCard(_ label: String) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.teal)
                
                Text("Result Summary")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            HStack(alignment: .top, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.green.opacity(0.2),
                                    Color.green.opacity(0.1)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.green)
                        .scaleEffect(successCheckmark ? 1.0 : 0.3)
                        .opacity(successCheckmark ? 1.0 : 0)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(label)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let stoneCount = aiResult["stone_count"] {
                        HStack(spacing: 8) {
                            Image(systemName: "circle.grid.cross.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.teal)
                            
                            Text("Stone Count: \(stoneCount)")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.teal.opacity(0.1))
                        )
                    }
                }
                
                Spacer()
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.green.opacity(0.15), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            .offset(y: cardOffset * 0.8)
            .opacity(cardOpacity)
        }
    }
    
    private func annotatedImageSection(_ urlString: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.teal)
                
                Text("AI Annotated Scan")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            if isLoadingAnnotatedImage {
                loadingAnnotatedImageSection
            } else if let image = downloadedAnnotatedImage {
                annotatedImageView(image)
            } else if let url = URL(string: urlString) {
                fallbackAsyncImageView(url)
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var loadingAnnotatedImageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 250)
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(.teal)
                
                Text("Loading annotated image...")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func annotatedImageView(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.teal.opacity(0.5),
                                Color.cyan.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
            )
            .shadow(color: Color.teal.opacity(0.2), radius: 15, x: 0, y: 8)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
            )
            .offset(y: cardOffset * 0.6)
            .opacity(cardOpacity)
    }
    
    private func fallbackAsyncImageView(_ url: URL) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                loadingAnnotatedImageSection
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.teal.opacity(0.5),
                                        Color.cyan.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: Color.teal.opacity(0.2), radius: 15, x: 0, y: 8)
            case .failure:
                failedImageSection
            @unknown default:
                EmptyView()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
        )
        .offset(y: cardOffset * 0.6)
        .opacity(cardOpacity)
    }
    
    private var failedImageSection: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.red.opacity(0.05))
                .frame(height: 250)
            
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red.opacity(0.7))
                
                Text("Failed to load image")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func stoneDetailsSection(sizes: [Double], locations: [String]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "list.bullet.rectangle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.teal)
                
                Text("Stone Details")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            ForEach(sizes.indices, id: \.self) { index in
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.teal,
                                        Color.teal.opacity(0.8)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 44, height: 44)
                        
                        Text("\(index + 1)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    stoneDetailRow(size: sizes[index], location: locations[index])
                    
                    Spacer()
                }
                .scaleEffect(index < stoneCardAnimation.count && stoneCardAnimation[index] ? 1.0 : 0.8)
                .opacity(index < stoneCardAnimation.count && stoneCardAnimation[index] ? 1.0 : 0)
            }
            
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 20, x: 0, y: 10)
            )
            .padding(.horizontal, 20)
            .offset(y: cardOffset * 0.4)
            .opacity(cardOpacity)
        }
    }
    
    private func stoneDetailRow(size: Double, location: String) -> some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "ruler.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.teal)
                    
                    Text("Size:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(String(format: "%.2f", size)) mm")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.teal)
                    
                    Text("Location:")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(location)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.teal.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.teal.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    private var saveButtonSection: some View {
        VStack(spacing: 12) {
            Button(action: saveToDatabase) {
                HStack(spacing: 12) {
                    if isSavingToDB {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text(isSavingToDB ? "Saving..." : "Save report and send to doctor")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .disabled(isSavingToDB ||
                     (aiResult["status"] as? String == "Invalid Input") ||
                     uploadedImage == nil)
            
            // Status message
            if isSavingToDB || savingSuccess || savingError != nil {
                saveStatusSection
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private func saveToDatabase() {
        // ✅ FIXED: Extract stone_count properly
        let stoneCountValue: String = {
            if let count = aiResult["stone_count"] as? Int {
                return "\(count)"
            } else if let count = aiResult["stone_count"] as? String {
                return count
            }
            return "0"
        }()
        
        // ✅ FIXED: Use downloaded annotated image or fallback to uploaded image
        if let annotatedImage = downloadedAnnotatedImage {
            saveHistoryWithImage(
                doctor: "Dr. Kumar",
                stoneCount: stoneCountValue,
                stoneSizes: viewModel.stoneSizes,
                stoneLocations: viewModel.stoneLocations,
                image: annotatedImage,  // ✅ SEND ANNOTATED IMAGE
                pid: patientPID,
                diagnosisNotes: aiResult["status"] as? String ?? "",
                diagnosisConfirmed: aiResult["status"] as? String ?? ""
            )
        } else if let uploadedImage = uploadedImage {
            // Fallback to original image if annotated image is not available
            saveHistoryWithImage(
                doctor: "Dr. Kumar",
                stoneCount: stoneCountValue,
                stoneSizes: viewModel.stoneSizes,
                stoneLocations: viewModel.stoneLocations,
                image: uploadedImage,
                pid: patientPID,
                diagnosisNotes: aiResult["status"] as? String ?? "",
                diagnosisConfirmed: aiResult["status"] as? String ?? ""
            )
        } else {
            savingError = "No image available"
            savingMessage = "Cannot save without an image"
            return
        }
        
        isSavingToDB = true
    }
    
    private var saveStatusSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName:
                    savingError != nil ? "xmark.circle.fill" :
                    savingSuccess ? "checkmark.circle.fill" :
                    "arrow.up.circle.fill"
                )
                .foregroundColor(
                    savingError != nil ? .red :
                    savingSuccess ? .green :
                    .blue
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(
                        savingError != nil ? "Save Failed" :
                        savingSuccess ? "Saved Successfully" :
                        "Saving to Database"
                    )
                    .font(.system(size: 14, weight: .semibold))
                    
                    Text(savingMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        savingError != nil ? Color.red.opacity(0.1) :
                        savingSuccess ? Color.green.opacity(0.1) :
                        Color.blue.opacity(0.1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .offset(y: cardOffset * 0.2)
        .opacity(cardOpacity)
    }
    
    private var successMessageSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Report Analyzed Successfully")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Your CT scan analysis is ready. Save it to your medical records.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.3))
            
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.teal)
                
                Text("Tap 'Save to Database' to store this analysis in your medical records.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.green.opacity(0.05),
                                Color.white
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green.opacity(0.2), lineWidth: 2)
                    )
            )
            .shadow(color: Color.green.opacity(0.1), radius: 15, x: 0, y: 8)
            .padding(.horizontal, 20)
            .offset(y: cardOffset * 0.2)
            .opacity(cardOpacity)
        }
    }
    
    // MARK: - Image Downloading
    
    private func downloadAnnotatedImage(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("❌ Invalid annotated image URL")
            return
        }
        
        isLoadingAnnotatedImage = true
        
        print("📥 Downloading annotated image from: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoadingAnnotatedImage = false
                
                if let error = error {
                    print("❌ Failed to download annotated image: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("❌ Invalid image data from URL")
                    return
                }
                
                print("✅ Annotated image downloaded successfully: \(data.count) bytes")
                self.downloadedAnnotatedImage = image
            }
        }.resume()
    }
    
    // MARK: - Database Operations
    
    private func saveHistoryWithImage(
        doctor: String,
        stoneCount: String,
        stoneSizes: String,
        stoneLocations: String,
        image: UIImage,
        pid: String,
        diagnosisNotes: String,
        diagnosisConfirmed: String
    ) {
        let baseAPI = "http://14.139.187.229:8081/oct/renal"
        
        guard let url = URL(string: "\(baseAPI)/addhistory.php") else {
            DispatchQueue.main.async {
                savingError = "Invalid URL"
                savingMessage = "Bad URL configuration"
                isSavingToDB = false
            }
            return
        }
        
        // Convert image to JPEG data
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            DispatchQueue.main.async {
                savingError = "Image conversion failed"
                savingMessage = "Could not process the image"
                isSavingToDB = false
            }
            return
        }
        
        // Create multipart form data boundary
        let boundary = "Boundary-\(UUID().uuidString)"
        var body = Data()
        
        // Helper to append form field
        func appendField(_ name: String, _ value: String) {
            body.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
            body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8) ?? Data())
            body.append("\(value)\r\n".data(using: .utf8) ?? Data())
        }
        
        // Add all form fields
        appendField("doctor", doctor)
        appendField("stone_count", stoneCount)
        appendField("stone_sizes", stoneSizes)
        appendField("stone_locations", stoneLocations)
        appendField("pid", pid)
        appendField("diagnosis_notes", diagnosisNotes)
        appendField("diagnosis_confirmed", diagnosisConfirmed)
        
        // Add image file
        body.append("--\(boundary)\r\n".data(using: .utf8) ?? Data())
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"ctscan_\(Date().timeIntervalSince1970).jpg\"\r\n".data(using: .utf8) ?? Data())
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8) ?? Data())
        body.append(imageData)
        body.append("\r\n".data(using: .utf8) ?? Data())
        
        // Add closing boundary
        body.append("--\(boundary)--\r\n".data(using: .utf8) ?? Data())
        
        // Create request with multipart/form-data
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.timeoutInterval = 60
        
        print("📤 Uploading image to: \(url.absoluteString)")
        print("📊 Image data size: \(imageData.count) bytes")
        
        // Send request
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSavingToDB = false
                
                // Check for network errors
                if let error = error {
                    savingError = error.localizedDescription
                    savingMessage = "Network error occurred"
                    print("❌ Network error: \(error.localizedDescription)")
                    return
                }
                
                // Check HTTP response
                if let httpResponse = response as? HTTPURLResponse {
                    print("📨 HTTP Status: \(httpResponse.statusCode)")
                }
                
                // Parse response
                guard let data = data else {
                    savingError = "No response from server"
                    savingMessage = "Server did not respond"
                    print("❌ No response data")
                    return
                }
                
                // Log raw response
                if let responseString = String(data: data, encoding: .utf8) {
                    print("📥 Raw Response: \(responseString)")
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let status = json["status"] as? String ?? "error"
                        let message = json["message"] as? String ?? "Unknown error"
                        
                        print("✅ Response: Status=\(status), Message=\(message)")
                        
                        if status == "success" {
                            savingSuccess = true
                            savingMessage = message
                            savingError = nil
                            print("✅ Image saved successfully!")
                        } else {
                            savingError = status
                            savingMessage = message
                            savingSuccess = false
                        }
                    } else {
                        savingError = "Invalid response format"
                        savingMessage = "Could not parse server response"
                    }
                } catch {
                    savingError = "Parsing error"
                    savingMessage = error.localizedDescription
                    print("❌ JSON parsing error: \(error)")
                }
            }
        }.resume()
    }
    
    private func setupAnimations() {
        // Initialize stone card animations array
        if let sizes = aiResult["stone_sizes_mm"] as? [Double] {
            stoneCardAnimation = Array(repeating: false, count: sizes.count)
        }
        
        // Header animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            headerScale = 1.0
            headerOpacity = 1.0
        }
        
        // Cards cascade animation
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
            cardOffset = 0
            cardOpacity = 1.0
        }
        
        // Success checkmark animation
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.5)) {
            successCheckmark = true
        }
        
        // Animate stone cards individually
        for index in stoneCardAnimation.indices {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.6 + Double(index) * 0.1)) {
                stoneCardAnimation[index] = true
            }
        }
        
        // Continuous animations
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            pulseAnimation.toggle()
        }
        
        withAnimation(.linear(duration: 25.0).repeatForever(autoreverses: false)) {
            rotationAngle = 360
        }
    }
}

#Preview {
    AIResultView(
        uploadedImage: UIImage(systemName: "photo"),
        aiResult: [
            "status": "Kidney Stone Detected",
            "stone_count": 2,
            "stone_sizes_mm": [4.5, 6.2],
            "stone_locations": ["Left Kidney", "Right Kidney"],
            "annotated_image": "http://example.com/annotated_image.jpg"
        ],
        patientPID: "P12345"
    )
}

// MARK: - HistoryViewModel

class HistoryViewModel: ObservableObject {
    @Published var stoneSizes: String = ""
    @Published var stoneLocations: String = ""
    
    func arrayValueToString(
        from aiResult: [String: Any],
        key: String,
        unit: String = "mm"
    ) -> String {
        guard let array = aiResult[key] as? [Any] else {
            return ""
        }
        return array.map { "\($0)\(unit)" }.joined(separator: ", ")
    }
    
    func processAIResult(_ aiResult: [String: Any]) {
        stoneSizes = arrayValueToString(
            from: aiResult,
            key: "stone_sizes_mm"
        )
        
        stoneLocations = arrayValueToString(
            from: aiResult,
            key: "stone_locations",
            unit: ""
        )
    }
}
