import SwiftUI

// MARK: - ValidateResult Enum (Renamed to avoid conflicts)
enum ValidateResult: Equatable {
    case valid
    case invalid(String)
    
    static func == (lhs: ValidateResult, rhs: ValidateResult) -> Bool {
        switch (lhs, rhs) {
        case (.valid, .valid):
            return true
        case (.invalid(let lhsMsg), .invalid(let rhsMsg)):
            return lhsMsg == rhsMsg
        default:
            return false
        }
    }
}

struct PatientSignupView: View {
    @State private var name = ""
    @State private var age = ""
    @State private var gender = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var work = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var navigateToDashboard = false
    @State private var animateGradient = false
    
    // ✅ ALL VALIDATION STATES
    @State private var nameValidation: ValidateResult = .valid
    @State private var ageValidation: ValidateResult = .valid
    @State private var phoneValidation: ValidateResult = .valid
    @State private var emailValidation: ValidateResult = .valid
    @State private var addressValidation: ValidateResult = .valid
    @State private var workValidation: ValidateResult = .valid
    @State private var passwordValidation: ValidateResult = .valid
    @State private var confirmPasswordValidation: ValidateResult = .valid
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        ZStack {
            gradientBackground
            
            ScrollView {
                VStack(spacing: 25) {
                    headerView
                    
                    titleView
                    
                    formFields
                    
                    signupButton
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                if alertTitle == "Success" { navigateToDashboard = true }
            }
        } message: { Text(alertMessage) }
        .onChange(of: name) { newValue in nameValidation = validateName(newValue) }
        .onChange(of: age) { newValue in ageValidation = validateAge(newValue) }
        .onChange(of: phone) { newValue in phoneValidation = validatePhone(newValue) }
        .onChange(of: email) { newValue in emailValidation = validateEmail(newValue) }
        .onChange(of: address) { newValue in addressValidation = validateAddress(newValue) }
        .onChange(of: work) { newValue in workValidation = validateWork(newValue) }
        .onChange(of: password) { newValue in passwordValidation = validatePassword(newValue) }
        .onChange(of: confirmPassword) { newValue in confirmPasswordValidation = validateConfirmPassword(newValue) }
    }
    
    // MARK: - Subviews
    
    private var gradientBackground: some View {
        LinearGradient(
            colors: [Color.teal.opacity(0.1), Color.cyan.opacity(0.15), Color.blue.opacity(0.1), Color.teal.opacity(0.05)],
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 4).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
    
    private var headerView: some View {
        ZStack {
            Circle()
                .fill(LinearGradient(colors: [Color.teal.opacity(0.3), Color.cyan.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 120, height: 120)
            
            Image(systemName: "person.badge.plus.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 70)
                .foregroundStyle(LinearGradient(colors: [.teal, .cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
        }
        .padding(.top, 30)
        .shadow(color: .teal.opacity(0.3), radius: 20, x: 0, y: 10)
    }
    
    private var titleView: some View {
        VStack(spacing: 6) {
            Text("Create Account")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(LinearGradient(colors: [.teal, .cyan], startPoint: .leading, endPoint: .trailing))
            
            Text("Join us for better healthcare")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 10)
    }
    
    private var formFields: some View {
        VStack(spacing: 16) {
            // Name Field
            ValidatedTextField(
                icon: "person.fill",
                placeholder: "Full Name",
                text: $name,
                validation: $nameValidation,
                validator: validateName
            )
            
            // Age Field
            ValidatedTextField(
                icon: "calendar",
                placeholder: "Age",
                text: $age,
                keyboardType: .numberPad,
                validation: $ageValidation,
                validator: validateAge
            )
            
            // Gender Picker
            genderPicker
            
            // Phone Field
            ValidatedTextField(
                icon: "phone.fill",
                placeholder: "Phone Number",
                text: $phone,
                keyboardType: .phonePad,
                validation: $phoneValidation,
                validator: validatePhone
            )
            
            // Email Field
            ValidatedTextField(
                icon: "envelope.fill",
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress,
                validation: $emailValidation,
                validator: validateEmail
            )
            
            // Address Field
            ValidatedTextField(
                icon: "house.fill",
                placeholder: "Address",
                text: $address,
                validation: $addressValidation,
                validator: validateAddress
            )
            
            // Work Field
            ValidatedTextField(
                icon: "briefcase.fill",
                placeholder: "Nature of Work",
                text: $work,
                validation: $workValidation,
                validator: validateWork
            )
            
            // Password Field
            passwordField
            
            // Confirm Password Field
            confirmPasswordField
            
            // Password Strength
            PasswordStrengthView(password: password)
                .padding(.horizontal)
                .opacity(password.isEmpty ? 0 : 1)
        }
        .padding(.horizontal)
    }
    
    private var genderPicker: some View {
        Menu {
            ForEach(genders, id: \.self) { gender in
                Button(gender) {
                    withAnimation(.spring(response: 0.3)) {
                        self.gender = gender
                    }
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(.teal)
                    .frame(width: 20)
                
                Text(gender.isEmpty ? "Select Gender" : gender)
                    .foregroundColor(gender.isEmpty ? .gray : .primary)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .foregroundColor(.teal)
                    .font(.caption)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .teal.opacity(0.1), radius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [.teal.opacity(0.3), .cyan.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .padding(.horizontal)
    }
    
    private var passwordField: some View {
        HStack(spacing: 14) {
            ValidatedTextField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password,
                isSecure: !showPassword,
                validation: $passwordValidation,
                validator: validatePassword
            )
            
            Button(action: {
                withAnimation(.spring()) {
                    showPassword.toggle()
                }
            }) {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var confirmPasswordField: some View {
        HStack(spacing: 14) {
            ValidatedTextField(
                icon: "lock.shield.fill",
                placeholder: "Confirm Password",
                text: $confirmPassword,
                isSecure: !showConfirmPassword,
                validation: $confirmPasswordValidation,
                validator: validateConfirmPassword
            )
            
            Button(action: {
                withAnimation(.spring()) {
                    showConfirmPassword.toggle()
                }
            }) {
                Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private var signupButton: some View {
        Button(action: { signupPatient() }) {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                Text("Create Account")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: isFormValid ? [.teal, .cyan, .blue] : [.gray, .gray.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: isFormValid ? .teal.opacity(0.4) : .clear, radius: 15)
        }
        .disabled(!isFormValid)
        .scaleEffect(isFormValid ? 1.0 : 0.98)
        .animation(.spring(response: 0.3), value: isFormValid)
        .padding(.horizontal)
        .padding(.top, 10)
    }
    
    // MARK: - Validation Functions
    
    private func validateName(_ name: String) -> ValidateResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Name is required") }
        let nameRegex = "^[a-zA-Z\\s]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        guard predicate.evaluate(with: trimmed) else { return .invalid("Only alphabets allowed") }
        return .valid
    }
    
    private func validateAge(_ age: String) -> ValidateResult {
        let trimmed = age.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let ageInt = Int(trimmed), ageInt > 0 && ageInt <= 120 else {
            return .invalid("Age must be 1-120")
        }
        return .valid
    }
    
    private func validatePhone(_ phone: String) -> ValidateResult {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Phone is required") }
        let cleanPhone = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard cleanPhone.count == 10, let first = cleanPhone.first, "6789".contains(first) else {
            return .invalid("10 digits, starts with 6/7/8/9")
        }
        return .valid
    }
    
    private func validateEmail(_ email: String) -> ValidateResult {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Email is required") }
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard predicate.evaluate(with: trimmed) else { return .invalid("Invalid email format") }
        let allowedDomains = ["gmail.com", "yahoo.com"]
        let components = trimmed.components(separatedBy: "@")
        guard components.count == 2, let domain = components.last, allowedDomains.contains(domain.lowercased()) else {
            return .invalid("Use @gmail.com or @yahoo.com")
        }
        return .valid
    }
    
    private func validateAddress(_ address: String) -> ValidateResult {
        let trimmed = address.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? .invalid("Address is required") : .valid
    }
    
    private func validateWork(_ work: String) -> ValidateResult {
        let trimmed = work.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? .invalid("Work details required") : .valid
    }
    
    private func validatePassword(_ password: String) -> ValidateResult {
        guard !password.isEmpty else { return .invalid("Password required") }
        return password.count >= 6 ? .valid : .invalid("Minimum 6 characters")
    }
    
    private func validateConfirmPassword(_ confirmPassword: String) -> ValidateResult {
        guard !confirmPassword.isEmpty else { return .invalid("Confirm password required") }
        return confirmPassword == password ? .valid : .invalid("Passwords don't match")
    }
    
    private var isFormValid: Bool {
        nameValidation == .valid &&
        ageValidation == .valid &&
        !gender.isEmpty &&
        phoneValidation == .valid &&
        emailValidation == .valid &&
        addressValidation == .valid &&
        workValidation == .valid &&
        passwordValidation == .valid &&
        confirmPasswordValidation == .valid
    }
    
    // MARK: - Signup Function with Validation
    func signupPatient() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertTitle = "Invalid Name"
            alertMessage = "Please enter your full name"
            showAlert = true
            return
        }
        
        guard let ageInt = Int(age), ageInt > 0 && ageInt < 150 else {
            alertTitle = "Invalid Age"
            alertMessage = "Please enter a valid age (1-150)"
            showAlert = true
            return
        }
        
        guard !gender.isEmpty else {
            alertTitle = "Gender Required"
            alertMessage = "Please select your gender"
            showAlert = true
            return
        }
        
        let phoneDigits = phone.filter { $0.isNumber }
        guard phoneDigits.count == 10 else {
            alertTitle = "Invalid Phone"
            alertMessage = "Please enter a valid 10-digit phone number"
            showAlert = true
            return
        }
        
        guard let firstDigit = phoneDigits.first, ["6", "7", "8", "9"].contains(String(firstDigit)) else {
            alertTitle = "Invalid Phone Number"
            alertMessage = "Phone number must start with 6, 7, 8, or 9"
            showAlert = true
            return
        }
        
        guard email.contains("@") && email.contains(".") else {
            alertTitle = "Invalid Email"
            alertMessage = "Please enter a valid email address"
            showAlert = true
            return
        }
        
        guard !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertTitle = "Address Required"
            alertMessage = "Please enter your address"
            showAlert = true
            return
        }
        
        guard !work.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertTitle = "Work Required"
            alertMessage = "Please enter your nature of work"
            showAlert = true
            return
        }
        
        guard password.count >= 6 else {
            alertTitle = "Weak Password"
            alertMessage = "Password must be at least 6 characters long"
            showAlert = true
            return
        }
        
        guard password == confirmPassword else {
            alertTitle = "Password Mismatch"
            alertMessage = "Passwords do not match"
            showAlert = true
            return
        }
        
        callSignupAPI()
    }
    
    // MARK: - API Call
    func callSignupAPI() {
        let params: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "age": age,
            "gender": gender,
            "phone": phone,
            "email": email.lowercased().trimmingCharacters(in: .whitespaces),
            "address": address.trimmingCharacters(in: .whitespaces),
            "work": work.trimmingCharacters(in: .whitespaces),
            "password": password
        ]
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/psignup.php") else {
            alertTitle = "Error"
            alertMessage = "Invalid server URL"
            showAlert = true
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.alertTitle = "Network Error"
                    self.alertMessage = "Please check your internet connection"
                    self.showAlert = true
                }
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            if let data = data {
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Server response: \(responseString)")
                }
                
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    DispatchQueue.main.async {
                        if let status = json["status"] as? String, status == "success" {
                            let pid = json["pid"] as? String ?? ""
                            
                            UserDefaults.standard.set(pid, forKey: "patientPID")
                            UserDefaults.standard.set(self.name, forKey: "patientName")
                            UserDefaults.standard.set(self.email, forKey: "patientEmail")
                            
                            self.alertTitle = "Success"
                            self.alertMessage = "Account created successfully! Your Patient ID: \(pid)"
                            self.showAlert = true
                        } else {
                            self.alertTitle = "Signup Failed"
                            self.alertMessage = json["message"] as? String ?? "Unable to create account. Please try again."
                            self.showAlert = true
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        self.alertTitle = "Server Error"
                        self.alertMessage = "Invalid response from server"
                        self.showAlert = true
                    }
                }
            }
        }.resume()
    }
}

// MARK: - ValidatedTextField
struct ValidatedTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboardType: UIKeyboardType = .default
    @Binding var validation: ValidateResult
    let validator: (String) -> ValidateResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.teal.opacity(0.7))
                    .frame(width: 20)
                
                if isSecure {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 16))
                } else {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .keyboardType(keyboardType)
                        .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                }
                
                Spacer()
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .teal.opacity(0.1), radius: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1.5)
            )
            .animation(.easeInOut(duration: 0.2), value: validation)
            
            if case .invalid(let message) = validation {
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.horizontal, 18)
            }
        }
        .onChange(of: text) { newValue in
            validation = validator(newValue)
        }
    }
    
    private var borderColor: Color {
        switch validation {
        case .valid:
            return .teal.opacity(0.15)
        case .invalid:
            return .red.opacity(0.4)
        }
    }
}

// MARK: - PasswordStrengthView
struct PasswordStrengthView: View {
    let password: String
    
    private var strength: (level: Int, text: String, color: Color) {
        if password.count < 6 {
            return (1, "Weak", .red)
        } else if password.count < 8 {
            return (2, "Fair", .orange)
        } else if password.count < 10 {
            return (3, "Good", .yellow)
        } else {
            return (4, "Strong", .green)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(1...4, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(level <= strength.level ? strength.color : Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
            
            Text("Password Strength: \(strength.text)")
                .font(.caption)
                .foregroundColor(strength.color)
        }
    }
}

// MARK: - PREVIEW
struct PatientSignupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatientSignupView()
        }
    }
}
