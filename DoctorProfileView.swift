import SwiftUI

// MARK: - Doctor Profile View (Enhanced with Validation)

struct DoctorProfileView: View {
    @EnvironmentObject var profile: DoctorProfile
    @AppStorage("doctorDID") private var doctorDID: String = ""
    @State private var isEditing = false
    @State private var showSaveAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showProfile = false
    @State private var showFields = false
    @State private var showDeleteConfirmation = false
    @State private var isDeleting = false
    
    // Validation states
    @State private var nameValidation: ValidateResult = .valid
    @State private var emailValidation: ValidateResult = .valid
    @State private var specializationValidation: ValidateResult = .valid
    @State private var hospitalValidation: ValidateResult = .valid
    @State private var phoneValidation: ValidateResult = .valid
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.teal.opacity(0.08),
                    Color.blue.opacity(0.05),
                    Color.cyan.opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Enhanced Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.teal.opacity(0.3),
                                            Color.teal.opacity(0.0)
                                        ],
                                        center: .center,
                                        startRadius: 50,
                                        endRadius: 75
                                    )
                                )
                                .frame(width: 140, height: 140)
                                .blur(radius: 10)
                                .scaleEffect(showProfile ? 1 : 0.8)

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.teal.opacity(0.2), Color.blue.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                                .scaleEffect(showProfile ? 1 : 0.7)

                            ZStack {
                                Circle()
                                    .fill(Color(.systemBackground))
                                    .frame(width: 110, height: 110)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.teal, .teal.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .scaleEffect(showProfile ? 1 : 0.5)
                            .rotationEffect(.degrees(showProfile ? 0 : -180))
                        }

                        VStack(spacing: 8) {
                            Text(profile.name)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.primary)
                                .opacity(showProfile ? 1 : 0)
                                .offset(y: showProfile ? 0 : 20)

                            HStack(spacing: 8) {
                                Image(systemName: "stethoscope")
                                    .font(.system(size: 14))
                                    .foregroundColor(.teal)
                                Text(profile.specialization)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .opacity(showProfile ? 1 : 0)
                            .offset(y: showProfile ? 0 : 20)
                        }
                    }
                    .padding(.vertical, 20)

                    // Edit/Save Button
                    if !isEditing {
                        Button(action: {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isEditing = true
                            }
                        }) {
                            HStack(spacing: 12) {
                                Image(systemName: "pencil")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Edit Profile")
                                    .font(.system(size: 17, weight: .semibold))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .foregroundColor(.white)
                            .background(
                                LinearGradient(
                                    colors: [Color.teal, Color.teal.opacity(0.85)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.teal.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.horizontal, 20)
                        .scaleEffect(showFields ? 1 : 0.9)
                        .opacity(showFields ? 1 : 0)
                    }

                    // Enhanced Profile Fields with Validation
                    VStack(spacing: 16) {
                        // Name Field
                        ValidatedProfileField(
                            icon: "person.fill",
                            label: "Name",
                            value: $profile.name,
                            isEditing: isEditing,
                            index: 0,
                            showFields: $showFields,
                            validation: $nameValidation,
                            validator: validateName
                        )

                        // Email Field
                        ValidatedProfileField(
                            icon: "envelope.fill",
                            label: "Email",
                            value: $profile.email,
                            isEditing: isEditing,
                            index: 1,
                            showFields: $showFields,
                            validation: $emailValidation,
                            validator: validateEmail
                        )

                        // Gender Picker
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.teal.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "person.2.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.teal)
                                }
                                Text("Gender")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.secondary)
                            }

                            if isEditing {
                                Picker("Gender", selection: $profile.gender) {
                                    Text("Male").tag("Male")
                                    Text("Female").tag("Female")
                                    Text("Other").tag("Other")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .tint(.teal)
                            } else {
                                HStack {
                                    Text(profile.gender)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        )
                        .scaleEffect(showFields ? 1 : 0.9)
                        .opacity(showFields ? 1 : 0)

                        // Specialization Field
                        ValidatedProfileField(
                            icon: "cross.case.fill",
                            label: "Specialization",
                            value: $profile.specialization,
                            isEditing: isEditing,
                            index: 3,
                            showFields: $showFields,
                            validation: $specializationValidation,
                            validator: validateSpecialization
                        )

                        // Hospital Field
                        ValidatedProfileField(
                            icon: "building.2.fill",
                            label: "Hospital",
                            value: $profile.hospital,
                            isEditing: isEditing,
                            index: 4,
                            showFields: $showFields,
                            validation: $hospitalValidation,
                            validator: validateHospital
                        )

                        // Phone Field
                        ValidatedProfileField(
                            icon: "phone.fill",
                            label: "Phone",
                            value: $profile.phone,
                            isEditing: isEditing,
                            index: 5,
                            showFields: $showFields,
                            validation: $phoneValidation,
                            validator: validatePhone
                        )
                    }
                    .padding(.horizontal, 20)

                    // Save/Cancel Buttons with Validation Check
                    if isEditing {
                        HStack(spacing: 12) {
                            Button(action: {
                                let impactLight = UIImpactFeedbackGenerator(style: .light)
                                impactLight.impactOccurred()
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isEditing = false
                                    profile.saveOriginalData()
                                    resetValidation()
                                }
                            }) {
                                Text("Cancel")
                                    .font(.system(size: 17, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 54)
                                    .foregroundColor(.primary)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(16)
                            }
                            .buttonStyle(ScaleButtonStyle())

                            Button(action: {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                validateAllFields()
                                if isProfileValid {
                                    saveProfile()
                                } else {
                                    alertTitle = "Validation Error"
                                    alertMessage = "Please fix all validation errors before saving"
                                    showSaveAlert = true
                                }
                            }) {
                                HStack(spacing: 10) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                        Text("Saving...")
                                    } else {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 18))
                                        Text("Save")
                                    }
                                }
                                .font(.system(size: 17, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(
                                        colors: isLoading || !profile.hasChanges() || !isProfileValid
                                            ? [Color.teal.opacity(0.5), Color.teal.opacity(0.4)]
                                            : [Color.teal, Color.teal.opacity(0.85)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: Color.teal.opacity(isLoading || !profile.hasChanges() || !isProfileValid ? 0.2 : 0.4), radius: 12, x: 0, y: 6)
                            }
                            .buttonStyle(ScaleButtonStyle())
                            .disabled(isLoading || !profile.hasChanges() || !isProfileValid)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }

                    // Delete Account Section
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(.red)
                            Text("Account Management")
                                .font(.system(size: 16, weight: .semibold))
                        }

                        Divider()
                            .background(Color.red.opacity(0.2))

                        Text("Permanently delete your account and all associated data. This action cannot be undone.")
                            .font(.system(size: 13, weight: .regular))
                            .foregroundColor(.secondary)
                            .lineLimit(3)

                        Button(action: { showDeleteConfirmation = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "trash.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Delete Account")
                                    .font(.system(size: 15, weight: .semibold))
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.red.opacity(0.9),
                                        Color.red.opacity(0.75)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(UIColor.systemRed).opacity(0.05))
                            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red.opacity(0.2), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    Spacer(minLength: 40)
                }
                .padding(.vertical, 20)
            }
        }
        .navigationBarTitle("Profile", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .alert(alertTitle, isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .confirmationDialog(
            "Delete Account",
            isPresented: $showDeleteConfirmation,
            presenting: (),
            actions: { _ in
                Button("Delete Account", role: .destructive) {
                    deleteAccount()
                }
                Button("Cancel", role: .cancel) { }
            },
            message: { _ in
                Text("Are you sure you want to permanently delete your account? All your profile data and associated records will be erased. This cannot be undone.")
            }
        )
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                showProfile = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                showFields = true
            }
        }
        .onChange(of: profile.name) { newValue in
            if isEditing { nameValidation = validateName(newValue) }
        }
        .onChange(of: profile.email) { newValue in
            if isEditing { emailValidation = validateEmail(newValue) }
        }
        .onChange(of: profile.specialization) { newValue in
            if isEditing { specializationValidation = validateSpecialization(newValue) }
        }
        .onChange(of: profile.hospital) { newValue in
            if isEditing { hospitalValidation = validateHospital(newValue) }
        }
        .onChange(of: profile.phone) { newValue in
            if isEditing { phoneValidation = validatePhone(newValue) }
        }
    }

    // MARK: - Validation Functions
    private func validateName(_ name: String) -> ValidateResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Name is required") }
        let nameRegex = "^[a-zA-Z\\s]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        guard predicate.evaluate(with: trimmed) else { return .invalid("Only alphabets allowed") }
        guard trimmed.count >= 2 else { return .invalid("At least 2 characters required") }
        return .valid
    }
    
    private func validateEmail(_ email: String) -> ValidateResult {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Email is required") }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard predicate.evaluate(with: trimmed) else { return .invalid("Invalid email format") }
        let allowedDomains = ["gmail.com", "yahoo.com", "outlook.com", "hotmail.com", "icloud.com"]
        let components = trimmed.components(separatedBy: "@")
        guard components.count == 2, let domain = components.last, allowedDomains.contains(domain.lowercased()) else {
            return .invalid("Please use a common email provider")
        }
        return .valid
    }
    
    private func validateSpecialization(_ specialization: String) -> ValidateResult {
        let trimmed = specialization.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Specialization is required") }
        guard trimmed.count >= 3 else { return .invalid("At least 3 characters required") }
        return .valid
    }
    
    private func validateHospital(_ hospital: String) -> ValidateResult {
        let trimmed = hospital.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Hospital name is required") }
        guard trimmed.count >= 3 else { return .invalid("At least 3 characters required") }
        return .valid
    }
    
    private func validatePhone(_ phone: String) -> ValidateResult {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Phone number is required") }
        let cleanPhone = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard cleanPhone.count == 10 else { return .invalid("Must be 10 digits") }
        guard let first = cleanPhone.first, "6789".contains(first) else {
            return .invalid("Must start with 6, 7, 8, or 9")
        }
        return .valid
    }
    
    private var isProfileValid: Bool {
        nameValidation == .valid &&
        emailValidation == .valid &&
        specializationValidation == .valid &&
        hospitalValidation == .valid &&
        phoneValidation == .valid
    }
    
    private func validateAllFields() {
        nameValidation = validateName(profile.name)
        emailValidation = validateEmail(profile.email)
        specializationValidation = validateSpecialization(profile.specialization)
        hospitalValidation = validateHospital(profile.hospital)
        phoneValidation = validatePhone(profile.phone)
    }
    
    private func resetValidation() {
        nameValidation = .valid
        emailValidation = .valid
        specializationValidation = .valid
        hospitalValidation = .valid
        phoneValidation = .valid
    }

    // MARK: - Delete Account Function (keep existing)
    private func deleteAccount() {
        withAnimation {
            isDeleting = true
        }

        guard !doctorDID.isEmpty else {
            alertMessage = "Doctor ID not found"
            showSaveAlert = true
            isDeleting = false
            return
        }

        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/dprofile.php") else {
            alertMessage = "Invalid URL"
            showSaveAlert = true
            isDeleting = false
            return
        }

        let body: [String: Any] = ["did": doctorDID]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            alertMessage = "Failed to create request"
            showSaveAlert = true
            isDeleting = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                withAnimation {
                    isDeleting = false
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Delete response status: \(httpResponse.statusCode)")
                }

                if let error = error {
                    alertMessage = "Network Error: \(error.localizedDescription)"
                    showSaveAlert = true
                    return
                }

                guard let data = data, !data.isEmpty else {
                    alertMessage = "No response from server. Please try again."
                    showSaveAlert = true
                    return
                }

                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw response: \(rawResponse)")
                }

                struct APIResponse: Codable {
                    let success: Bool
                    let message: String
                }

                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    alertMessage = response.message

                    if response.success {
                        let impactSuccess = UINotificationFeedbackGenerator()
                        impactSuccess.notificationOccurred(.success)
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            UserDefaults.standard.removeObject(forKey: "doctorDID")
                        }
                    }
                } catch let decodingError {
                    print("Decoding error: \(decodingError)")
                    alertMessage = "Failed to process response: \(decodingError.localizedDescription)"
                }

                showSaveAlert = true
            }
        }.resume()
    }

    // MARK: - Save Profile Function (keep existing)
    func saveProfile() {
        withAnimation {
            isLoading = true
        }

        guard !doctorDID.isEmpty else {
            alertMessage = "Doctor ID not found"
            showSaveAlert = true
            isLoading = false
            return
        }

        let body: [String: Any] = [
            "did": doctorDID,
            "name": profile.name.trimmingCharacters(in: .whitespaces),
            "email": profile.email.trimmingCharacters(in: .whitespaces),
            "gender": profile.gender,
            "specialization": profile.specialization.trimmingCharacters(in: .whitespaces),
            "hospital": profile.hospital.trimmingCharacters(in: .whitespaces),
            "phone": profile.phone.trimmingCharacters(in: .whitespaces)
        ]

        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/dprofile.php") else {
            alertMessage = "Invalid URL"
            showSaveAlert = true
            isLoading = false
            return
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            alertMessage = "Failed to create request"
            showSaveAlert = true
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        request.timeoutInterval = 15

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                withAnimation {
                    isLoading = false
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print("Save response status: \(httpResponse.statusCode)")
                }

                if let error = error {
                    alertMessage = "Network Error: \(error.localizedDescription)"
                    showSaveAlert = true
                    return
                }

                guard let data = data, !data.isEmpty else {
                    alertMessage = "No response from server. Please try again."
                    showSaveAlert = true
                    return
                }

                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("Raw response: \(rawResponse)")
                }

                struct APIResponse: Codable {
                    let success: Bool
                    let message: String
                }

                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    alertMessage = response.message

                    if response.success {
                        let impactSuccess = UINotificationFeedbackGenerator()
                        impactSuccess.notificationOccurred(.success)
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            isEditing = false
                        }
                        profile.saveOriginalData()
                        resetValidation()
                    }
                } catch let decodingError {
                    print("Decoding error: \(decodingError)")
                    alertMessage = "Failed to process response: \(decodingError.localizedDescription)"
                }

                showSaveAlert = true
            }
        }.resume()
    }
}

// MARK: - Validated Profile Field Component
struct ValidatedProfileField: View {
    var icon: String
    var label: String
    @Binding var value: String
    var isEditing: Bool
    var index: Int
    @Binding var showFields: Bool
    @Binding var validation: ValidateResult
    let validator: (String) -> ValidateResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.teal.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .font(.system(size: 16))
                        .foregroundColor(.teal)
                }
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.secondary)
            }

            if isEditing {
                VStack(alignment: .leading, spacing: 6) {
                    TextField(label, text: $value)
                        .modifier(CustomTextFieldStyle(isError: isError))
                    
                    if case .invalid(let message) = validation {
                        Text(message)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.red)
                            .padding(.horizontal, 4)
                    }
                }
            } else {
                HStack {
                    Text(value)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(showFields ? 1 : 0.9)
        .opacity(showFields ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: showFields)
        .onChange(of: value) { newValue in
            validation = validator(newValue)
        }
    }
    
    private var isError: Bool {
        if case .invalid = validation {
            return true
        }
        return false
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: ViewModifier {
    var isError: Bool = false

    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isError ? Color.red : Color.teal.opacity(0.3),
                        lineWidth: 1.5
                    )
            )
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    DoctorProfileView()
        .environmentObject(DoctorProfile())
}
