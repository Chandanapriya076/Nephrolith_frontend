import SwiftUI

// MARK: - Validation Result
// MARK: - Validation Result
enum ValidationResult: Equatable, Hashable {
    case valid
    case invalid(String) // Error message
}

// MARK: - Profile Content View (UNCHANGED)
struct PatientProfileContent: View {
    let pid: String
    
    @State private var profile = PatientProfileData()
    @State private var isLoading = false
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    @State private var showDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Futuristic Header with Glow Effect
                ZStack {
                    // Background Gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.teal.opacity(0.15),
                            Color.teal.opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 280)

                    VStack(spacing: 16) {
                        // Profile Avatar with Glow
                        ZStack {
                            // Outer glow rings
                            Circle()
                                .stroke(Color.teal.opacity(0.1), lineWidth: 2)
                                .frame(width: 150, height: 150)
                            Circle()
                                .stroke(Color.teal.opacity(0.15), lineWidth: 2)
                                .frame(width: 135, height: 135)

                            // Main avatar
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.teal.opacity(0.2), Color.teal.opacity(0.3)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                    .shadow(color: Color.teal.opacity(0.3), radius: 20, x: 0, y: 10)

                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.teal, Color.teal.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                        .padding(.top, 40)

                        VStack(spacing: 8) {
                            Text(profile.name.isEmpty ? "Patient Profile" : profile.name)
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.primary)

                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.seal.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.teal)
                                Text("Verified Patient")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }

                // Profile Information Cards
                VStack(spacing: 16) {
                    if isLoading {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(.teal)
                            Text("Loading profile...")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 200)
                    } else {
                        ProfileRow(title: "Full Name", value: profile.name, icon: "person.fill")
                        ProfileRow(title: "Age", value: profile.age, icon: "calendar")
                        ProfileRow(title: "Gender", value: profile.gender, icon: "person.2.fill")
                        ProfileRow(title: "Phone", value: profile.phone, icon: "phone.fill")
                        ProfileRow(title: "Email", value: profile.email, icon: "envelope.fill")
                        ProfileRow(title: "Address", value: profile.address, icon: "location.fill")

                        // Edit Profile Button
                        NavigationLink(destination: EditPatientProfileView(profile: $profile, pid: pid)) {
                            HStack(spacing: 12) {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                Text("Edit Profile")
                                    .font(.system(size: 17, weight: .semibold))
                                Spacer()
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 20))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.teal, Color.teal.opacity(0.85)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.teal.opacity(0.35), radius: 12, x: 0, y: 6)
                        }
                        .padding(.top, 10)

                        // Medical Info Card
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.teal)
                                Text("Medical Information")
                                    .font(.system(size: 16, weight: .semibold))
                            }

                            Divider()
                                .background(Color.teal.opacity(0.2))

                            HStack {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Patient ID")
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(.secondary)
                                    Text(pid)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                }

                                Spacer()

                                Image(systemName: "qrcode")
                                    .font(.system(size: 40))
                                    .foregroundColor(.teal.opacity(0.3))
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.teal.opacity(0.15), lineWidth: 1)
                        )

                        // DELETE ACCOUNT SECTION
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

                            Text("Permanently delete your account and all associated medical data. This action cannot be undone.")
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
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .padding(.bottom, 160)
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear(perform: fetchProfile)
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
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
                Text("Are you sure you want to permanently delete your account? All your medical data, reports, and history will be erased. This cannot be undone.")
            }
        )
    }

    func fetchProfile() {
        guard !pid.isEmpty else { return }
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/pprofile.php?pid=\(pid)") else { return }

        isLoading = true
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async { isLoading = false }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    errorMessage = "Failed to load profile."
                    showErrorAlert = true
                }
                return
            }

            if let status = json["status"] as? String, status == "success",
               let data = json["data"] as? [String: Any] {
                DispatchQueue.main.async {
                    profile.name = data["name"] as? String ?? ""
                    if let ageInt = data["age"] as? Int {
                        profile.age = String(ageInt)
                    } else if let ageStr = data["age"] as? String {
                        profile.age = ageStr
                    } else {
                        profile.age = ""
                    }
                    profile.gender = data["gender"] as? String ?? "Female"
                    profile.phone = data["phone"] as? String ?? ""
                    profile.email = data["email"] as? String ?? ""
                    profile.address = data["address"] as? String ?? ""
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = json["message"] as? String ?? "Unknown server error"
                    showErrorAlert = true
                }
            }
        }.resume()
    }

    func deleteAccount() {
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/pprofile.php") else { return }

        isLoading = true
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "pid": pid,
            "action": "delete_account"
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async { isLoading = false }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    errorMessage = "Failed to delete account."
                    showErrorAlert = true
                }
                return
            }

            if let status = json["status"] as? String, status == "success" {
                DispatchQueue.main.async {
                    errorMessage = "Account deleted successfully. Please logout."
                    showErrorAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        // Trigger logout/navigation - implement based on your auth flow
                    }
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = json["message"] as? String ?? "Failed to delete account"
                    showErrorAlert = true
                }
            }
        }.resume()
    }
}

// MARK: - Edit Profile View (UPDATED WITH VALIDATIONS)
struct EditPatientProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var profile: PatientProfileData
    let pid: String
    
    @State private var showSaveAlert = false
    @State private var saveAlertMessage = ""
    @State private var isLoading = false
    
    // ✅ VALIDATION STATES
    @State private var nameValidation: ValidationResult = .valid
    @State private var ageValidation: ValidationResult = .valid
    @State private var phoneValidation: ValidationResult = .valid
    @State private var emailValidation: ValidationResult = .valid
    
    // ✅ Validation Functions
    private func validateName(_ name: String) -> ValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Name is required") }
        let nameRegex = "^[a-zA-Z\\s]+$"
        let namePredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        guard namePredicate.evaluate(with: trimmed) else {
            return .invalid("Name should contain only alphabets")
        }
        return .valid
    }
    
    private func validateAge(_ age: String) -> ValidationResult {
        let trimmed = age.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Age is required") }
        guard let ageInt = Int(trimmed), ageInt > 0 && ageInt <= 120 else {
            return .invalid("Age must be between 1-120 years")
        }
        return .valid
    }
    
    private func validatePhone(_ phone: String) -> ValidationResult {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines) // Fixed: "Andnewlines" -> "AndNewlines"
        guard !trimmed.isEmpty else { return .invalid("Phone number is required") }
        let cleanPhone = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard cleanPhone.count == 10 else {
            return .invalid("Phone number must be 10 digits")
        }
        return .valid
    }

    
    private func validateEmail(_ email: String) -> ValidationResult {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Email is required") }
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: trimmed) else {
            return .invalid("Invalid email format")
        }
        
        // ✅ Specific domain validation
        let allowedDomains = ["gmail.com", "yahoo.com"]
        let components = trimmed.components(separatedBy: "@")
        guard components.count == 2,
              let domain = components.last,
              allowedDomains.contains(domain.lowercased()) else {
            return .invalid("Email must be @gmail.com or @yahoo.com")
        }
        return .valid
    }
    
    private func validateAllFields() -> Bool {
        nameValidation = validateName(profile.name)
        ageValidation = validateAge(profile.age)
        phoneValidation = validatePhone(profile.phone)
        emailValidation = validateEmail(profile.email)
        
        return nameValidation == .valid &&
               ageValidation == .valid &&
               phoneValidation == .valid &&
               emailValidation == .valid
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.teal.opacity(0.2), Color.teal.opacity(0.1)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: "person.crop.circle.badge.checkmark")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.teal)
                    }

                    Text("Edit Profile")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Update your medical information")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)

                // Personal Information Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.text.rectangle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.teal)
                        Text("Personal Information")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 4)

                    VStack(spacing: 14) {
                        ValidatesTextField(
                            icon: "person.fill",
                            placeholder: "Full Name",
                            text: $profile.name,
                            validation: $nameValidation,
                            validator: validateName
                        )
                        
                        ValidatesTextField(
                            icon: "calendar",
                            placeholder: "Age",
                            text: $profile.age,
                            keyboardType: .numberPad,
                            validation: $ageValidation,
                            validator: validateAge
                        )

                        // Gender Picker
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.teal.opacity(0.7))
                                Text("Gender")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 18)

                            Picker("", selection: $profile.gender) {
                                Text("Female").tag("Female")
                                Text("Male").tag("Male")
                                Text("Other").tag("Other")
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal, 18)
                        }
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.teal.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                }

                // Contact Details Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "phone.bubble.left.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.teal)
                        Text("Contact Details")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 4)

                    VStack(spacing: 14) {
                        ValidatesTextField(
                            icon: "phone.fill",
                            placeholder: "Phone Number",
                            text: $profile.phone,
                            keyboardType: .phonePad,
                            validation: $phoneValidation,
                            validator: validatePhone
                        )
                        
                        ValidatesTextField(
                            icon: "envelope.fill",
                            placeholder: "Email Address",
                            text: $profile.email,
                            keyboardType: .emailAddress,
                            validation: $emailValidation,
                            validator: validateEmail
                        )
                        
                        ModernTextField(icon: "location.fill", placeholder: "Address", text: $profile.address)
                    }
                    .padding(.horizontal, 20)
                }

                // Save Button
                Button(action: saveProfile) {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20, weight: .semibold))
                        }

                        Text(isLoading ? "Saving Changes..." : "Save Changes")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.teal, Color.teal.opacity(0.85)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.teal.opacity(0.35), radius: 12, x: 0, y: 6)
                }
                .frame(maxWidth: .infinity)
                .disabled(isLoading || !isFormValid)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(Color(.systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .alert("Update Profile", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {
                if saveAlertMessage == "Profile updated successfully" {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(saveAlertMessage)
        }
        .onChange(of: profile.name) { _, newValue in
            nameValidation = validateName(newValue)
        }
        .onChange(of: profile.age) { _, newValue in
            ageValidation = validateAge(newValue)
        }
        .onChange(of: profile.phone) { _, newValue in
            phoneValidation = validatePhone(newValue)
        }
        .onChange(of: profile.email) { _, newValue in
            emailValidation = validateEmail(newValue)
        }
    }
    
    // ✅ Computed property to check if form is valid
    private var isFormValid: Bool {
        nameValidation == .valid &&
        ageValidation == .valid &&
        phoneValidation == .valid &&
        emailValidation == .valid
    }

    func saveProfile() {
        guard validateAllFields() else {
            saveAlertMessage = "Please fix the errors above before saving."
            showSaveAlert = true
            return
        }
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/pprofile.php") else { return }

        isLoading = true
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "pid": pid,
            "name": profile.name,
            "age": profile.age,
            "gender": profile.gender,
            "phone": profile.phone,
            "email": profile.email,
            "address": profile.address
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async { isLoading = false }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    saveAlertMessage = "Failed to update profile."
                    showSaveAlert = true
                }
                return
            }

            DispatchQueue.main.async {
                saveAlertMessage = json["message"] as? String ?? "Failed to update profile"
                showSaveAlert = true
            }
        }.resume()
    }
}

// MARK: - Validated TextField Component (NEW)
struct ValidatesTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @Binding var validation: ValidationResult
    let validator: (String) -> ValidationResult

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.teal.opacity(0.7))
                    .frame(width: 20)

                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.primary)
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .textInputAutocapitalization(.never)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(getBorderColor(), lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.2), value: validation)
            
            // ✅ Error message
            if case .invalid(let message) = validation {
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.horizontal, 18)
                    .padding(.top, 2)
                    .transition(.opacity.combined(with: .move(edge: .top)).animation(.easeInOut(duration: 0.2)))
            }
        }
        .onChange(of: text) { _, newValue in
            validation = validator(newValue)
        }
    }
    
    private func getBorderColor() -> Color {
        switch validation {
        case .valid:
            return Color.teal.opacity(0.15)
        case .invalid:
            return Color.red.opacity(0.4)
        }
    }


}

// MARK: - Profile Data Model (UNCHANGED)
struct PatientProfileData: Codable {
    var name: String = ""
    var age: String = ""
    var gender: String = "Female"
    var phone: String = ""
    var email: String = ""
    var address: String = ""
}

// MARK: - Profile Row Component (UNCHANGED)
struct ProfileRow: View {
    var title: String
    var value: String
    var icon: String

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.teal.opacity(0.15), Color.teal.opacity(0.05)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.teal)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)

                Text(value.isEmpty ? "Not set" : value)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.teal.opacity(0.4))
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.teal.opacity(0.1), Color.teal.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Modern TextField Component (UNCHANGED - for address field)
struct ModernTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.teal.opacity(0.7))
                .frame(width: 20)

            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .textInputAutocapitalization(.never)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.teal.opacity(0.15), lineWidth: 1)
        )
    }
}

