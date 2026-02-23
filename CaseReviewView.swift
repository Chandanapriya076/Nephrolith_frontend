import SwiftUI

// MARK: - Case Review View (Enhanced UI/UX with Animations)

struct CaseReviewView: View {
    
    @State var caseItem: CaseItem
    
    @State private var showAnnotatedFullscreen = false
    @State private var diagnosisNotes: String = ""
    @State private var diagnosisConfirmed = false
    @State private var showSuccess = false
    @State private var isSubmitting = false
    @State private var submitError = ""
    @State private var diagnosisAlreadySaved = false
    
    // Animation states
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    @State private var imageScale: CGFloat = 0.9
    @State private var pulseAnimation = false
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                
                // Annotated Image Section with Enhanced Animations
                if !caseItem.fullAnnotatedImageUrl.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Label("Annotated Analysis", systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                                )
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ZStack(alignment: .topTrailing) {
                            annotatedImageView
                                .scaleEffect(imageScale)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        showAnnotatedFullscreen = true
                                    }
                                }
                            
                            Button {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showAnnotatedFullscreen = true
                                }
                            } label: {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.teal)
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    )
                            }
                            .padding(12)
                            .scaleEffect(pulseAnimation ? 1.1 : 1.0)
                        }
                        .padding(.horizontal)
                    }
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                }
                
                // Patient Information with Glass Effect
                patientInformationView
                
                // AI Results with Enhanced Styling - FIXED STONE COUNT
                aiResultsView
                
                // Doctor Confirmation Section - FIXED DIAGNOSIS SUBMISSION
                doctorConfirmationView
                
                Spacer(minLength: 30)
            }
            .padding(.top)
            .padding(.bottom, 160)

        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarTitle(caseItem.patientName, displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .toolbar(.hidden, for: .tabBar)
        .alert("Submission Error", isPresented: .constant(!submitError.isEmpty)) {
            Button("OK") {
                submitError = ""
            }
        } message: {
            Text(submitError)
        }
        .fullScreenCover(isPresented: $showAnnotatedFullscreen) {
            fullScreenImageContent
        }
        .sheet(isPresented: $showSuccess) {
            DiagnosisCompletedView {
                showSuccess = false
                diagnosisAlreadySaved = true
                // ✅ Update local state only, not the original caseItem
                // The server has already updated the database
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear(perform: onAppearActions)
    }
    
    // MARK: - Extracted Views
    
    private var annotatedImageView: some View {
        Group {
            if let image = loadBase64Image(base64String: caseItem.fullAnnotatedImageUrl) {
                // Base64 image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
                    .cornerRadius(16)
                    .shadow(color: .teal.opacity(0.2), radius: 10, x: 0, y: 5)
            } else if caseItem.fullAnnotatedImageUrl.hasPrefix("http"), let url = URL(string: caseItem.fullAnnotatedImageUrl) {
                // URL image
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.tertiarySystemFill))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.teal.opacity(0.3), lineWidth: 1)
                                    )
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .cornerRadius(16)
                            .shadow(color: .teal.opacity(0.2), radius: 10, x: 0, y: 5)
                    case .failure(_):
                        ErrorImageView()
                    @unknown default:
                        Color.gray.frame(height: 280).cornerRadius(16)
                    }
                }
            } else {
                // If no valid image
                ErrorImageView()
            }
        }
    }
    
    private var fullScreenImageContent: some View {
        Group {
            if let uiImage = loadBase64Image(base64String: caseItem.fullAnnotatedImageUrl) {
                FullScreenImageView(isPresented: $showAnnotatedFullscreen, uiImage: uiImage)
            } else if let url = URL(string: caseItem.fullAnnotatedImageUrl) {
                FullScreenImageView(isPresented: $showAnnotatedFullscreen, imageUrl: caseItem.fullAnnotatedImageUrl)
            } else {
                // Fallback empty view
                FullScreenImageView(isPresented: $showAnnotatedFullscreen)
            }
        }
    }
    
    private var patientInformationView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patient Information")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(colors: [.primary, .secondary], startPoint: .leading, endPoint: .trailing)
                )
            
            HStack(spacing: 16) {
                PatientInfoCard(title: "Name", value: caseItem.patientName, icon: "person.fill")
                PatientInfoCard(title: "Age", value: "\(caseItem.age)", icon: "calendar")
                PatientInfoCard(title: "Gender", value: caseItem.gender, icon: "figure.dress.line.vertical.figure")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
        .opacity(contentOpacity)
        .offset(y: contentOffset)
    }
    
    private var aiResultsView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("AI Suggested Results")
                    .font(.headline)
                Spacer()
                HStack(spacing: 6) {
                    Text("Confidence:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("\(caseItem.aiScore)%")
                        .font(.caption)
                        .bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                                )
                        )
                        .foregroundColor(.white)
                }
            }
            
            // Detection row
            HStack(spacing: 12) {
                AIResultCard(
                    title: "Detection",
                    value: caseItem.aiDetected ? "Stone Found" : "No Stone",
                    icon: caseItem.aiDetected ? "checkmark.circle.fill" : "xmark.circle.fill",
                    color: caseItem.aiDetected ? .green : .red
                )
                
                // ✅ Display stone count
                AIResultCard(
                    title: "Count",
                    value: "\(caseItem.aiCount)",
                    icon: "number.circle.fill",
                    color: .purple
                )
                
                // ✅ Display largest stone size
                if caseItem.aiDetected {
                    AIResultCard(
                        title: "Largest",
                        value: "\(String(format: "%.1f", caseItem.aiSizeMM)) mm",
                        icon: "arrow.up.circle.fill",
                        color: .orange
                    )
                } else {
                    AIResultCard(
                        title: "Size",
                        value: "—",
                        icon: "ruler",
                        color: .orange
                    )
                }
            }
            
            // Stone Sizes Detailed View - Show all sizes
            // Alternative compact stone sizes display
            if caseItem.aiDetected && !caseItem.stoneSizes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "circle.grid.2x2.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Text("All Stone Sizes:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(caseItem.stoneCount) stones")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                    
                    // Show all sizes in a horizontal scroll view
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(caseItem.stoneSizes.enumerated()), id: \.offset) { index, size in
                                VStack(spacing: 2) {
                                    Text("\(index + 1)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(width: 20, height: 20)
                                        .background(Circle().fill(Color.blue))
                                    
                                    Text(formatStoneSize(size))
                                        .font(.system(.caption, design: .rounded))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(10)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            }
            
            // Stone Locations
            if caseItem.aiDetected && !caseItem.stoneLocations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.teal)
                        Text("Locations:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                        
                        // Show unique location count
                        let uniqueLocations = Array(Set(caseItem.stoneLocations))
                        Text("\(uniqueLocations.count) location(s)")
                            .font(.caption)
                            .foregroundColor(.teal)
                    }
                    
                    // Show locations
                    let columns = [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                    
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Array(caseItem.stoneLocations.enumerated()), id: \.offset) { index, location in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(getLocationColor(for: location))
                                    .frame(width: 8, height: 8)
                                
                                Text("\(index + 1). \(location)")
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(.primary)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
                .padding(12)
                .background(Color.teal.opacity(0.05))
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .teal.opacity(0.1), radius: 12, x: 0, y: 6)
        )
        .padding(.horizontal)
        .opacity(contentOpacity)
        .offset(y: contentOffset)
    }

    // Helper function to format stone size
    private func formatStoneSize(_ sizeString: String) -> String {
        // Remove "mm" and trim
        let cleaned = sizeString
            .replacingOccurrences(of: "mm", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to parse as Double
        if let number = Double(cleaned) {
            // Format with 1 decimal if it has decimals, otherwise as integer
            if number.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(number)) mm"
            } else {
                return String(format: "%.1f mm", number)
            }
        }
        
        // If parsing fails, return the original string
        return sizeString
    }

    // Helper function to get color for location
    private func getLocationColor(for location: String) -> Color {
        let lowercased = location.lowercased()
        if lowercased.contains("right") {
            return .green
        } else if lowercased.contains("left") {
            return .blue
        } else if lowercased.contains("kidney") {
            return .purple
        } else if lowercased.contains("ureter") {
            return .orange
        } else if lowercased.contains("bladder") {
            return .red
        }
        return .gray
    }
    
    private var doctorConfirmationView: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "stethoscope")
                    .foregroundColor(.teal)
                Text("Doctor Confirmation")
                    .font(.headline)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Review Notes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ZStack(alignment: .topLeading) {
                    if diagnosisNotes.isEmpty {
                        Text("Enter your professional Review and recommendations...")
                            .foregroundColor(.secondary.opacity(0.5))
                            .padding(.horizontal, 12)
                            .padding(.top, 16)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $diagnosisNotes)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.secondarySystemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    diagnosisNotes.isEmpty ? Color(.separator) : Color.teal.opacity(0.5),
                                    lineWidth: 1.5
                                )
                        )
                        .disabled(diagnosisAlreadySaved)
                }
            }
            
            // Validation Warning
            if diagnosisNotes.trimmingCharacters(in: .whitespaces).isEmpty && !diagnosisNotes.isEmpty {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Please enter meaningful Review notes.")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.orange.opacity(0.1))
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            // Already Submitted Message - FIXED: Check diagnosisAlreadySaved state
            if diagnosisAlreadySaved {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .symbolEffect(.pulse)
                    Text("Review already submitted. Cannot edit.")
                        .font(.subheadline)
                        .foregroundColor(.green)
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green.opacity(0.1))
                )
                .transition(.scale.combined(with: .opacity))
            }
            
            submitButtonView
                .scaleEffect(isButtonDisabled ? 0.98 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isButtonDisabled)
            
            if isButtonDisabled && diagnosisNotes.trimmingCharacters(in: .whitespaces).isEmpty {
                Text("Please write your Review notes before submitting.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .padding(.horizontal)
        .opacity(contentOpacity)
        .offset(y: contentOffset)
    }
    
    private var submitButtonView: some View {
        Group {
            if isSubmitting {
                HStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                    Text("Submitting Doctor Review...")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(colors: [.teal.opacity(0.7), .cyan.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                        )
                )
                .foregroundColor(.white)
                .transition(.scale.combined(with: .opacity))
            } else {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        submitDiagnosis()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "paperplane.fill")
                        Text("Submit Review")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                isButtonDisabled ?
                                LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing) :
                                LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: isButtonDisabled ? .clear : .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                    .foregroundColor(.white)
                }
                .disabled(isButtonDisabled)
            }
        }
    }
    
    var isButtonDisabled: Bool {
        let trimmedNotes = diagnosisNotes.trimmingCharacters(in: .whitespaces)
        
        let disabled = trimmedNotes.isEmpty ||
               trimmedNotes.count < 5 ||
               isSubmitting ||
               diagnosisAlreadySaved
        
        return disabled
    }
    
    // MARK: - Helper function to load base64 image
    private func loadBase64Image(base64String: String) -> UIImage? {
        // Check if it's a base64 string (starts with data:image)
        if base64String.hasPrefix("data:image") || base64String.hasPrefix("/9j/") || base64String.count > 1000 {
            print("📸 Detected base64 image, length: \(base64String.count)")
            
            // Extract base64 data if it has a prefix
            let base64Data: String
            if base64String.contains(",") {
                base64Data = String(base64String.split(separator: ",").last ?? "")
            } else {
                base64Data = base64String
            }
            
            if let imageData = Data(base64Encoded: base64Data, options: .ignoreUnknownCharacters) {
                return UIImage(data: imageData)
            }
        }
        return nil
    }
    
    // MARK: - Submit Diagnosis - FIXED VERSION
    // MARK: - Submit Diagnosis - FIXED VERSION
    func submitDiagnosis() {
        let trimmedNotes = diagnosisNotes.trimmingCharacters(in: .whitespaces)
        
        print("\n📝 === DIAGNOSIS SUBMISSION PROCESS ===")
        print("📝 Current state before submit:")
        print("   - diagnosisAlreadySaved: \(diagnosisAlreadySaved)")
        print("   - notes length: \(trimmedNotes.count)")
        print("   - patientEmail: \(caseItem.patientEmail)")
        print("   - pid: \(caseItem.pid)")
        
        if trimmedNotes.isEmpty {
            submitError = "Diagnosis notes cannot be empty. Please write your diagnosis."
            print("❌ REJECTED: Notes are empty")
            return
        }
        
        if trimmedNotes.count < 5 {
            submitError = "Diagnosis notes must be at least 5 characters. Please provide more detail."
            print("❌ REJECTED: Notes too short (<5 chars)")
            return
        }
        
        // ✅ FIX: Check for pid instead of email
        if caseItem.pid.isEmpty {
            submitError = "Patient ID not available. Please go back and try again."
            print("❌ REJECTED: Patient ID (pid) missing")
            return
        }
        
        isSubmitting = true
        submitError = ""
        
        print("✅ VALIDATION PASSED - Preparing submission...")
        print("📝 Submitting diagnosis for patient: \(caseItem.patientName)")
        print("📝 Patient ID (pid): \(caseItem.pid)")
        print("📝 Diagnosis notes length: \(trimmedNotes.count) characters")
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/diagnosis.php") else {
            submitError = "Invalid server URL"
            isSubmitting = false
            print("❌ ERROR: Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        // ✅ FIXED: Send pid instead of patient_email
        let body: [String: Any] = [
            "history_id": caseItem.id,   // ✅ THIS IS REQUIRED
            "diagnosis_notes": trimmedNotes,
            "diagnosis_confirmed": 1
        ]
        print("📝 History ID:", caseItem.id)
        print("📝 Patient ID (pid):", caseItem.pid)


        
        print("📤 Sending Body:", body)
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            submitError = "Encoding error: \(error.localizedDescription)"
            isSubmitting = false
            print("❌ JSON Encoding Error: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isSubmitting = false
                
                if let error = error {
                    self.submitError = "Network error: \(error.localizedDescription)"
                    print("❌ Network Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.submitError = "No response from server"
                    print("❌ No response data received")
                    return
                }
                
                let raw = String(data: data, encoding: .utf8) ?? "nil"
                print("📥 Raw Response: \(raw)")
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        
                        print("📥 Parsed JSON:", json)
                        
                        if let success = json["success"] as? Bool {
                            
                            if success {
                                print("✅ SUCCESS: Diagnosis saved to database")
                                print("✅ Setting diagnosisAlreadySaved = true")
                                
                                // ✅ FIX: Create a new CaseItem instance instead of modifying
                                let updatedCaseItem = CaseItem(
                                    id: self.caseItem.id,
                                    patientEmail: self.caseItem.patientEmail,
                                    patientName: self.caseItem.patientName,
                                    age: self.caseItem.age,
                                    gender: self.caseItem.gender,
                                    doctor: self.caseItem.doctor,
                                    stoneCount: self.caseItem.stoneCount,
                                    stoneSizes: self.caseItem.stoneSizes,
                                    stoneLocations: self.caseItem.stoneLocations,
                                    image: self.caseItem.image,
                                    pid: self.caseItem.pid,
                                    diagnosisNotes: trimmedNotes,
                                    diagnosisConfirmed: 1
                                )
                                
                                // Update the state with new instance
                                self.caseItem = updatedCaseItem
                                
                                // Update local state
                                self.diagnosisAlreadySaved = true
                                self.diagnosisNotes = trimmedNotes
                                self.showSuccess = true
                                
                            } else {
                                let errorMsg = json["message"] as? String ?? "Unknown error from server"
                                print("❌ Server Error: \(errorMsg)")
                                self.submitError = errorMsg
                            }
                            
                        } else {
                            self.submitError = "Invalid response: 'success' field missing"
                            print("❌ Missing 'success' field in response")
                        }
                        
                    } else {
                        self.submitError = "Invalid server response format"
                        print("❌ Could not parse JSON response")
                    }
                    
                } catch {
                    self.submitError = "JSON parse error: \(error.localizedDescription)"
                    print("❌ JSON Parse Error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    // MARK: - On Appear Actions
    private func onAppearActions() {
        print("🔍 DEBUG: CaseItem data on appear:")
        print("  - diagnosis_confirmed: \(caseItem.diagnosisConfirmed)")
        print("  - status: \(caseItem.status)")
        print("  - aiCount: \(caseItem.aiCount)")
        print("  - annotatedImage (first 100 chars): \(String(caseItem.fullAnnotatedImageUrl.prefix(100)))...")
        
        // Check if diagnosis is already confirmed (server-side check)
        if caseItem.diagnosisConfirmed == 1 {
            print("✅ Diagnosis CONFIRMED (1) - Mark as saved, disable editing")
            diagnosisAlreadySaved = true
            
            // Pre-fill diagnosis notes if available
            if !caseItem.diagnosisNotes.isEmpty {
                diagnosisNotes = caseItem.diagnosisNotes
            }
        } else {
            print("❌ Diagnosis NOT confirmed (0) - Allow editing, enable submit button")
            diagnosisAlreadySaved = false
        }
        
        // Animate content on appear
        withAnimation(.easeOut(duration: 0.6)) {
            contentOpacity = 1
            contentOffset = 0
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
            imageScale = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseAnimation.toggle()
        }
    }
}

// MARK: - Helper Views

struct ErrorImageView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.title)
                .foregroundColor(.orange)
                .symbolEffect(.bounce, value: true)
            Text("Failed to load image")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.tertiarySystemFill))
        )
    }
}

// MARK: - Patient Info Card Component
struct PatientInfoCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.teal)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.subheadline)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}

// MARK: - AI Result Card Component
struct AIResultCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(color)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Fullscreen Image View (Updated for base64)
struct FullScreenImageView: View {
    @Binding var isPresented: Bool
    var uiImage: UIImage? = nil
    var imageUrl: String? = nil
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .scaleEffect(scale)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                withAnimation(.spring()) {
                                    if scale < 1 {
                                        scale = 1
                                        lastScale = 1
                                    } else if scale > 3 {
                                        scale = 3
                                        lastScale = 3
                                    }
                                }
                            }
                    )
            } else if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .padding()
                            .scaleEffect(scale)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        scale = lastScale * value
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                        withAnimation(.spring()) {
                                            if scale < 1 {
                                                scale = 1
                                                lastScale = 1
                                            } else if scale > 3 {
                                                scale = 3
                                                lastScale = 3
                                            }
                                        }
                                    }
                            )
                    case .failure:
                        VStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.orange)
                            Text("Failed to load image")
                                .foregroundColor(.white)
                        }
                    @unknown default:
                        Color.black
                    }
                }
            } else {
                // Fallback if no image provided
                VStack(spacing: 12) {
                    Image(systemName: "photo.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white.opacity(0.5))
                    Text("No image available")
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            VStack {
                HStack {
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isPresented = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                            Text("Close")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                        .foregroundColor(.white)
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }
}

// MARK: - Diagnosis Completed View
struct DiagnosisCompletedView: View {
    var onDone: (() -> Void)? = nil
    @State private var checkmarkScale: CGFloat = 0.5
    @State private var checkmarkOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    
    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [.green.opacity(0.2), .green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 160, height: 160)
                    .blur(radius: 20)
                
                Image(systemName: "checkmark.seal.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundStyle(
                        LinearGradient(colors: [.green, .green.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                    )
                    .scaleEffect(checkmarkScale)
                    .opacity(checkmarkOpacity)
                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            VStack(spacing: 12) {
                Text("Review Submitted Successfully")
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("Your Review has been saved to the patient's medical record and the patient will be notified.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .opacity(contentOpacity)
            
            Spacer()
            
            Button {
                onDone?()
            } label: {
                Text("Back to Dashboard")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
                            )
                            .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .opacity(contentOpacity)
        }
        .padding()
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                contentOpacity = 1.0
            }
        }
    }
}

// MARK: - Back Button Helper
struct BackButton: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                presentationMode.wrappedValue.dismiss()
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                Text("Back")
                    .fontWeight(.medium)
            }
            .foregroundStyle(
                LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing)
            )
        }
    }
}
