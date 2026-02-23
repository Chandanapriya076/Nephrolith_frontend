import SwiftUI

// MARK: - DoctorValidationResult Enum
enum DoctorValidationResult: Equatable {
    case valid
    case invalid(String)
    
    var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .valid:
            return nil
        case .invalid(let message):
            return message
        }
    }
}

// MARK: - DoctorValidatedTextField Component
struct DoctorValidatedTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    @Binding var validation: DoctorValidationResult
    let validator: (String) -> DoctorValidationResult
    @FocusState.Binding var focusedField: DoctorSignupView.Field?
    var fieldType: DoctorSignupView.Field
    
    private var isFocused: Bool {
        focusedField == fieldType
    }
    
    private var borderColor: Color {
        if case .invalid = validation {
            return .red
        }
        return isFocused ? Color(red: 0.0, green: 0.6, blue: 0.65) : Color.clear
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFocused ? Color(red: 0.0, green: 0.6, blue: 0.65) : .gray)
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 16))
                    .keyboardType(keyboardType)
                    .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                    .focused($focusedField, equals: fieldType)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(isFocused ? 0.1 : 0.05), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: 2)
            )
            .animation(.spring(response: 0.3), value: isFocused)
            
            if case .invalid(let message) = validation {
                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
        .onChange(of: text) { newValue in
            validation = validator(newValue)
        }
    }
}

// MARK: - DoctorValidatedSecureField Component
struct DoctorValidatedSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    @Binding var validation: DoctorValidationResult
    let validator: (String) -> DoctorValidationResult
    @FocusState.Binding var focusedField: DoctorSignupView.Field?
    var fieldType: DoctorSignupView.Field
    
    private var isFocused: Bool {
        focusedField == fieldType
    }
    
    private var borderColor: Color {
        if case .invalid = validation {
            return .red
        }
        return isFocused ? Color(red: 0.0, green: 0.6, blue: 0.65) : Color.clear
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(isFocused ? Color(red: 0.0, green: 0.6, blue: 0.65) : .gray)
                    .frame(width: 20)
                
                if showPassword {
                    TextField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .focused($focusedField, equals: fieldType)
                } else {
                    SecureField(placeholder, text: $text)
                        .font(.system(size: 16))
                        .focused($focusedField, equals: fieldType)
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.3)) {
                        showPassword.toggle()
                    }
                }) {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(isFocused ? 0.1 : 0.05), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(borderColor, lineWidth: 2)
            )
            .animation(.spring(response: 0.3), value: isFocused)
            
            if case .invalid(let message) = validation {
                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
        .onChange(of: text) { newValue in
            validation = validator(newValue)
        }
    }
}

// MARK: - DoctorPasswordStrengthView
struct DoctorPasswordStrengthView: View {
    let password: String
    
    private var strength: (level: Int, text: String, color: Color) {
        if password.count < 6 {
            return (1, "Weak", .red)
        } else if password.count < 8 {
            return (2, "Fair", .orange)
        } else if password.count < 10 {
            return (3, "Good", .yellow)
        } else {
            let hasLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
            let hasNumber = password.range(of: "\\d", options: .regularExpression) != nil
            let hasSpecialChar = password.range(of: "[^a-zA-Z0-9]", options: .regularExpression) != nil
            
            if hasLetter && hasNumber && hasSpecialChar {
                return (4, "Strong", .green)
            } else if hasLetter && hasNumber {
                return (3, "Good", .yellow)
            } else {
                return (2, "Fair", .orange)
            }
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

// MARK: - Animation States (Added missing properties)
struct DoctorSignupView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var specialization = ""
    @State private var hospital = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var gender = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var navigateToLogin = false
    @State private var navigateToDashboard = false
    @State private var isLoading = false
    
    // Animation states
    @State private var headerScale: CGFloat = 0.5
    @State private var headerOpacity: Double = 0
    @State private var formOffset: CGFloat = 50
    @State private var formOpacity: Double = 0
    
    // Validation states
    @State private var nameValidation: DoctorValidationResult = .valid
    @State private var emailValidation: DoctorValidationResult = .valid
    @State private var specializationValidation: DoctorValidationResult = .valid
    @State private var hospitalValidation: DoctorValidationResult = .valid
    @State private var phoneValidation: DoctorValidationResult = .valid
    @State private var genderValidation: DoctorValidationResult = .valid
    @State private var passwordValidation: DoctorValidationResult = .valid
    @State private var confirmPasswordValidation: DoctorValidationResult = .valid
    
    // Focus states for field animations
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case name, email, specialization, hospital, phone, gender, password, confirmPassword
    }
    
    // Store doctor session data
    @AppStorage("doctorDID") var doctorDID: String = ""
    @AppStorage("doctorName") var doctorName: String = ""
    @AppStorage("doctorEmail") var doctorEmail: String = ""
    @AppStorage("doctorPhone") var doctorPhone: String = ""
    @AppStorage("doctorSpecialization") var doctorSpecialization: String = ""
    @AppStorage("doctorHospital") var doctorHospital: String = ""
    @AppStorage("doctorGender") var doctorGender: String = ""
    
    let genders = ["Male", "Female", "Other"]
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.5, blue: 0.55),
                    Color(red: 0.0, green: 0.35, blue: 0.45)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Animated circles background
            GeometryReader { geometry in
                Circle()
                    .fill(Color.white.opacity(0.05))
                    .frame(width: 300, height: 300)
                    .offset(x: -100, y: -50)
                
                Circle()
                    .fill(Color.white.opacity(0.03))
                    .frame(width: 200, height: 200)
                    .offset(x: geometry.size.width - 100, y: geometry.size.height - 150)
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Header Section with Animation
                    VStack(spacing: 16) {
                        ZStack {
                            // Outer glow ring
                            Circle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 110, height: 110)
                                .blur(radius: 8)
                            
                            // Icon background
                            Circle()
                                .fill(Color.white)
                                .frame(width: 90, height: 90)
                                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
                            
                            // Icon
                            Image(systemName: "stethoscope.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(red: 0.0, green: 0.6, blue: 0.65),
                                            Color(red: 0.0, green: 0.45, blue: 0.5)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .scaleEffect(headerScale)
                        .opacity(headerOpacity)
                        
                        VStack(spacing: 6) {
                            Text("Doctor Registration")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("Join our medical professional network")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        .opacity(headerOpacity)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 30)
                    
                    // Form Container with Glass Effect
                    formContainer
                        .offset(y: formOffset)
                        .opacity(formOpacity)
                }
            }
            
            // Hidden Navigation Links
            NavigationLink("", destination: DoctorAppRootView(), isActive: $navigateToDashboard)
                .hidden()
            
            NavigationLink("", destination: DoctorLoginView(), isActive: $navigateToLogin)
                .hidden()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .alert(alertTitle, isPresented: $showAlert) {
            alertButtons
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: name) { newValue in
            nameValidation = validateName(newValue)
        }
        .onChange(of: email) { newValue in
            emailValidation = validateEmail(newValue)
        }
        .onChange(of: specialization) { newValue in
            specializationValidation = validateSpecialization(newValue)
        }
        .onChange(of: hospital) { newValue in
            hospitalValidation = validateHospital(newValue)
        }
        .onChange(of: phone) { newValue in
            phoneValidation = validatePhone(newValue)
        }
        .onChange(of: gender) { newValue in
            genderValidation = validateGender(newValue)
        }
        .onChange(of: password) { newValue in
            passwordValidation = validatePassword(newValue)
            if !confirmPassword.isEmpty {
                confirmPasswordValidation = validateConfirmPassword(confirmPassword)
            }
        }
        .onChange(of: confirmPassword) { newValue in
            confirmPasswordValidation = validateConfirmPassword(newValue)
        }
    }
    
    // MARK: - Form Container
    private var formContainer: some View {
        VStack(spacing: 20) {
            formFields
            
            signupButton
            
            loginLink
        }
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(0.95))
                .shadow(color: Color.black.opacity(0.15), radius: 30, x: 0, y: -5)
        )
    }
    
    // MARK: - Form Fields
    private var formFields: some View {
        VStack(spacing: 18) {
            // Name Field
            DoctorValidatedTextField(
                icon: "person.fill",
                placeholder: "Full Name",
                text: $name,
                keyboardType: .default,
                validation: $nameValidation,
                validator: validateName,
                focusedField: $focusedField,
                fieldType: .name
            )
            .textContentType(.name)
            .autocapitalization(.words)
            .focused($focusedField, equals: .name)
            
            // Email Field
            DoctorValidatedTextField(
                icon: "envelope.fill",
                placeholder: "Email Address",
                text: $email,
                keyboardType: .emailAddress,
                validation: $emailValidation,
                validator: validateEmail,
                focusedField: $focusedField,
                fieldType: .email
            )
            .textContentType(.emailAddress)
            .autocapitalization(.none)
            .focused($focusedField, equals: .email)
            
            // Specialization Field
            DoctorValidatedTextField(
                icon: "cross.case.fill",
                placeholder: "Specialization / Nature of Work",
                text: $specialization,
                keyboardType: .default,
                validation: $specializationValidation,
                validator: validateSpecialization,
                focusedField: $focusedField,
                fieldType: .specialization
            )
            .autocapitalization(.words)
            .focused($focusedField, equals: .specialization)
            
            // Hospital Field
            DoctorValidatedTextField(
                icon: "building.2.fill",
                placeholder: "Hospital Name",
                text: $hospital,
                keyboardType: .default,
                validation: $hospitalValidation,
                validator: validateHospital,
                focusedField: $focusedField,
                fieldType: .hospital
            )
            .autocapitalization(.words)
            .focused($focusedField, equals: .hospital)
            
            // Phone Field
            DoctorValidatedTextField(
                icon: "phone.fill",
                placeholder: "Phone Number",
                text: $phone,
                keyboardType: .phonePad,
                validation: $phoneValidation,
                validator: validatePhone,
                focusedField: $focusedField,
                fieldType: .phone
            )
            .focused($focusedField, equals: .phone)
            
            // Gender Picker with Validation
            genderPicker
            
            // Password Field
            DoctorValidatedSecureField(
                icon: "lock.fill",
                placeholder: "Password (min. 6 characters)",
                text: $password,
                showPassword: $showPassword,
                validation: $passwordValidation,
                validator: validatePassword,
                focusedField: $focusedField,
                fieldType: .password
            )
            .focused($focusedField, equals: .password)
            
            // Confirm Password Field
            DoctorValidatedSecureField(
                icon: "lock.shield.fill",
                placeholder: "Confirm Password",
                text: $confirmPassword,
                showPassword: $showConfirmPassword,
                validation: $confirmPasswordValidation,
                validator: validateConfirmPassword,
                focusedField: $focusedField,
                fieldType: .confirmPassword
            )
            .focused($focusedField, equals: .confirmPassword)
            
            // Password Strength Indicator
            if !password.isEmpty {
                DoctorPasswordStrengthView(password: password)
                    .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Gender Picker
    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: 6) {
            Menu {
                ForEach(genders, id: \.self) { gen in
                    Button(action: {
                        withAnimation(.spring(response: 0.3)) {
                            gender = gen
                            genderValidation = validateGender(gen)
                        }
                    }) {
                        HStack {
                            Text(gen)
                            if gender == gen {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "figure.dress.line.vertical.figure")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(focusedField == .gender ? Color(red: 0.0, green: 0.6, blue: 0.65) : .gray)
                        .frame(width: 20)
                    
                    Text(gender.isEmpty ? "Select Gender" : gender)
                        .foregroundColor(gender.isEmpty ? .gray.opacity(0.7) : .primary)
                        .font(.system(size: 16))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.gray)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(focusedField == .gender ? 0.1 : 0.05), radius: 8, x: 0, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(genderBorderColor, lineWidth: 2)
                )
            }
            .focused($focusedField, equals: .gender)
            
            if case .invalid(let message) = genderValidation {
                Text(message)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.red)
                    .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Signup Button
    private var signupButton: some View {
        Button(action: {
            focusedField = nil
            validateAllFields()
            if isFormValid {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    signupDoctor()
                }
            }
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                }
                
                Text(isLoading ? "Creating Account..." : "Create Account")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
                
                if !isLoading {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.0, green: 0.6, blue: 0.65),
                        Color(red: 0.0, green: 0.5, blue: 0.55)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.4), radius: 15, x: 0, y: 8)
        }
        .disabled(!isFormValid || isLoading)
        .opacity((isFormValid && !isLoading) ? 1.0 : 0.5)
        .scaleEffect((isFormValid && !isLoading) ? 1.0 : 0.98)
        .padding(.horizontal, 24)
        .padding(.top, 8)
    }
    
    // MARK: - Login Link
    private var loginLink: some View {
        NavigationLink(destination: DoctorLoginView()) {
            HStack(spacing: 4) {
                Text("Already have an account?")
                    .foregroundColor(.black.opacity(0.8))
                    .font(.system(size: 15))
                Text("Login")
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .font(.system(size: 15))
            }
            .padding(.vertical, 20)
        }
    }
    
    // MARK: - Alert Buttons
    private var alertButtons: some View {
        Button("OK", role: .cancel) {
            if alertTitle == "Success" {
                withAnimation(.easeInOut(duration: 0.3)) {
                    navigateToDashboard = true
                }
            }
        }
    }
    
    // MARK: - Helper Properties
    private var genderBorderColor: Color {
        switch genderValidation {
        case .valid:
            return focusedField == .gender ? Color(red: 0.0, green: 0.6, blue: 0.65) : Color.clear
        case .invalid:
            return .red
        }
    }
    
    private var isFormValid: Bool {
        nameValidation == .valid &&
        emailValidation == .valid &&
        specializationValidation == .valid &&
        hospitalValidation == .valid &&
        phoneValidation == .valid &&
        genderValidation == .valid &&
        passwordValidation == .valid &&
        confirmPasswordValidation == .valid
    }
    
    // MARK: - Validation Functions
    private func validateName(_ name: String) -> DoctorValidationResult {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Name is required") }
        let nameRegex = "^[a-zA-Z\\s]+$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        guard predicate.evaluate(with: trimmed) else { return .invalid("Only alphabets allowed") }
        guard trimmed.count >= 2 else { return .invalid("At least 2 characters required") }
        return .valid
    }

    private func validateEmail(_ email: String) -> DoctorValidationResult {
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
    
    private func validateSpecialization(_ specialization: String) -> DoctorValidationResult {
        let trimmed = specialization.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Specialization is required") }
        guard trimmed.count >= 3 else { return .invalid("At least 3 characters required") }
        return .valid
    }
    
    private func validateHospital(_ hospital: String) -> DoctorValidationResult {
        let trimmed = hospital.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Hospital name is required") }
        guard trimmed.count >= 3 else { return .invalid("At least 3 characters required") }
        return .valid
    }
    
    private func validatePhone(_ phone: String) -> DoctorValidationResult {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .invalid("Phone number is required") }
        let cleanPhone = trimmed.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        guard cleanPhone.count == 10 else { return .invalid("Must be 10 digits") }
        guard let first = cleanPhone.first, "6789".contains(first) else {
            return .invalid("Must start with 6, 7, 8, or 9")
        }
        return .valid
    }
    
    private func validateGender(_ gender: String) -> DoctorValidationResult {
        return gender.isEmpty ? .invalid("Gender is required") : .valid
    }
    
    private func validatePassword(_ password: String) -> DoctorValidationResult {
        guard !password.isEmpty else { return .invalid("Password is required") }
        guard password.count >= 6 else { return .invalid("Minimum 6 characters required") }
        guard password.count <= 20 else { return .invalid("Maximum 20 characters allowed") }
        
        // Optional: Add more password strength checks
        let hasLetter = password.range(of: "[a-zA-Z]", options: .regularExpression) != nil
        let hasNumber = password.range(of: "\\d", options: .regularExpression) != nil
        
        if !hasLetter {
            return .invalid("Password must contain at least one letter")
        }
        if !hasNumber {
            return .invalid("Password must contain at least one number")
        }
        
        return .valid
    }
    
    private func validateConfirmPassword(_ confirmPassword: String) -> DoctorValidationResult {
        guard !confirmPassword.isEmpty else { return .invalid("Please confirm your password") }
        return confirmPassword == password ? .valid : .invalid("Passwords don't match")
    }
    
    // MARK: - Form Validation
    private func validateAllFields() {
        nameValidation = validateName(name)
        emailValidation = validateEmail(email)
        specializationValidation = validateSpecialization(specialization)
        hospitalValidation = validateHospital(hospital)
        phoneValidation = validatePhone(phone)
        genderValidation = validateGender(gender)
        passwordValidation = validatePassword(password)
        confirmPasswordValidation = validateConfirmPassword(confirmPassword)
    }
    
    // MARK: - Animation Functions
    private func startAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            headerScale = 1.0
            headerOpacity = 1.0
        }
        
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
            formOffset = 0
            formOpacity = 1.0
        }
    }
    
    // MARK: - Signup Function with Validation
    func signupDoctor() {
        // Validate all fields before proceeding
        validateAllFields()
        
        if !isFormValid {
            alertTitle = "Validation Error"
            alertMessage = "Please fix all validation errors before submitting"
            showAlert = true
            return
        }
        
        callSignupAPI()
    }
    
    // MARK: - API Call
    func callSignupAPI() {
        isLoading = true
        
        let params: [String: Any] = [
            "name": name.trimmingCharacters(in: .whitespaces),
            "email": email.lowercased().trimmingCharacters(in: .whitespaces),
            "specialization": specialization.trimmingCharacters(in: .whitespaces),
            "hospital": hospital.trimmingCharacters(in: .whitespaces),
            "phone": phone,
            "gender": gender,
            "password": password
        ]
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/dsignup.php") else {
            alertTitle = "Error"
            alertMessage = "Invalid server URL"
            showAlert = true
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        request.timeoutInterval = 15
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    alertTitle = "Network Error"
                    alertMessage = "Please check your internet connection"
                    showAlert = true
                }
                print("❌ Network error: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    DispatchQueue.main.async {
                        alertTitle = "Server Error"
                        alertMessage = "Server returned status code: \(httpResponse.statusCode)"
                        showAlert = true
                    }
                    return
                }
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    alertTitle = "Server Error"
                    alertMessage = "No data received from server"
                    showAlert = true
                }
                return
            }
            
            if let responseString = String(data: data, encoding: .utf8) {
                print("📥 Server response: \(responseString)")
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    DispatchQueue.main.async {
                        alertTitle = "Server Error"
                        alertMessage = "Invalid JSON response from server"
                        showAlert = true
                    }
                    return
                }
                
                print("✅ Parsed JSON: \(json)")
                
                DispatchQueue.main.async {
                    if let status = json["status"] as? String, status == "success" {
                        let did = json["did"] as? String ?? ""
                        
                        doctorDID = did
                        doctorName = name.trimmingCharacters(in: .whitespaces)
                        doctorEmail = email.lowercased().trimmingCharacters(in: .whitespaces)
                        doctorPhone = phone
                        doctorSpecialization = specialization.trimmingCharacters(in: .whitespaces)
                        doctorHospital = hospital.trimmingCharacters(in: .whitespaces)
                        doctorGender = gender
                        
                        print("✅ Doctor data saved - DID: \(did), Name: \(doctorName)")
                        
                        alertTitle = "Success"
                        alertMessage = "Account created successfully! Your Doctor ID: \(did)"
                        showAlert = true
                    } else {
                        alertTitle = "Signup Failed"
                        alertMessage = json["message"] as? String ?? "Unable to create account. Please try again."
                        showAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    alertTitle = "Server Error"
                    alertMessage = "Failed to parse server response"
                    showAlert = true
                }
                print("❌ JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// MARK: - PREVIEW
struct DoctorSignupView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DoctorSignupView()
        }
    }
}
