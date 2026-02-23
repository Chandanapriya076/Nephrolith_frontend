import SwiftUI

struct PatientLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var loginError = ""
    @State private var navigate = false
    @State private var retrievedPID = ""
    @State private var animateGradient = false
    @State private var fieldFocused = false
    
    // Store user session
    @AppStorage("patientPID") var patientPID: String = ""
    @AppStorage("patientName") var patientName: String = ""
    @AppStorage("patientEmail") var patientEmail: String = ""
    @AppStorage("patientPhone") var patientPhone: String = ""
    @AppStorage("patientAge") var patientAge: String = ""
    @AppStorage("patientGender") var patientGender: String = ""
    @AppStorage("patientAddress") var patientAddress: String = ""
    @AppStorage("patientWork") var patientWork: String = ""
    @AppStorage("patientLogin") var patientLogin: Bool = false
    
    @AppStorage("medicalDisclaimerAccepted")
    private var medicalDisclaimerAccepted: Bool = false
    
    var body: some View {
        ZStack {
            // Animated Gradient Background
            LinearGradient(
                colors: [
                    Color.teal.opacity(0.1),
                    Color.cyan.opacity(0.2),
                    Color.blue.opacity(0.1)
                ],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    animateGradient = true
                }
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    // Animated Header Icon with Pulse
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.teal.opacity(0.3), Color.cyan.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(isLoading ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isLoading)
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.teal, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .padding(.top, 60)
                    .shadow(color: .teal.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    VStack(spacing: 8) {
                        Text("Welcome Back")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.teal, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Sign in to continue")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 10)
                    
                    VStack(spacing: 20) {
                        // Enhanced Email/Phone Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.teal)
                                    .frame(width: 20)
                                TextField("Email / Phone Number", text: $email)
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .teal.opacity(0.1), radius: 10, x: 0, y: 5)
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
                        
                        // Enhanced Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(.teal)
                                    .frame(width: 20)
                                
                                if showPassword {
                                    TextField("Password", text: $password)
                                } else {
                                    SecureField("Password", text: $password)
                                }
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        showPassword.toggle()
                                    }
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                        .frame(width: 30, height: 30)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .teal.opacity(0.1), radius: 10, x: 0, y: 5)
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
                        
                        // Error Message with Animation
                        if !loginError.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text(loginError)
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal)
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        VStack(spacing: 6) {
                            Text("⚠️ Medical & Academic Disclaimer")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Text("This app is an academic student research project developed for educational purposes. It is not a medical device and does not provide medical diagnosis, treatment, or clinical advice. Always consult qualified healthcare professionals for medical decisions.")

                                .font(.caption2)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                            
                            
                            Toggle(isOn: $medicalDisclaimerAccepted) {
                                Text("I understand and agree")
                                    .font(.caption)
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .teal))
                        }
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                        .padding()
                        // Enhanced Login Button
                        Button(action: {
                            withAnimation {
                                loginUser()
                            }
                        }) {
                            HStack(spacing: 12) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.title3)
                                }
                                Text(isLoading ? "Logging in..." : "Login")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: (isLoading || email.isEmpty || password.isEmpty) ?
                                    [.gray, .gray.opacity(0.8)] :
                                    [.teal, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(
                                color: (isLoading || email.isEmpty || password.isEmpty) ?
                                .clear : .teal.opacity(0.4),
                                radius: 15,
                                x: 0,
                                y: 10
                            )
                        }
                        .disabled(isLoading || email.isEmpty || password.isEmpty)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .scaleEffect(isLoading ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3), value: isLoading)
                        
                        NavigationLink(
                            destination: PatientAppRootView(),
                            isActive: $navigate
                        ) {
                            EmptyView()
                        }
                        .hidden()
                        
                        // Forgot Password Link
                        NavigationLink(destination: PatientForgotPasswordView()) {
                            Text("Forgot Password?")
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.teal, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .font(.callout)
                                .fontWeight(.semibold)
                        }
                        .padding(.top, 5)
                    }
                    
                    Spacer(minLength: 40)
                    
                    // Enhanced Signup Link
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 1)
                        }
                        .padding(.horizontal, 40)
                        
                        NavigationLink(destination: PatientSignupView()) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.badge.plus")
                                    .font(.callout)
                                Text("New user?")
                                    .foregroundColor(.secondary)
                                Text("Create Account")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.teal, .cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .font(.subheadline)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        LinearGradient(
                                            colors: [.teal.opacity(0.5), .cyan.opacity(0.5)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                        }
                    }
                    .padding(.bottom, 30)
                    
                    // Disclaimer View moved inside the ScrollView
                    
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 8)
                    )
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .padding(.vertical)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
    
    // MARK: - Login API Call
    func loginUser() {
        loginError = ""
        
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            loginError = "Please enter email or phone number"
            return
        }
        
        guard !password.isEmpty else {
            loginError = "Please enter password"
            return
        }
        
        guard medicalDisclaimerAccepted else {
            loginError = "Please accept the medical disclaimer to continue"
            return
        }
        
        isLoading = true
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/plogin.php") else {
            loginError = "Invalid server URL"
            isLoading = false
            return
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let body: [String: Any] = [
            "email": trimmedEmail,
            "phone": trimmedEmail,
            "password": password
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            loginError = "Invalid request data"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    loginError = "Network error: \(error.localizedDescription)"
                    print("❌ Network error:", error.localizedDescription)
                    return
                }
                
                guard let data = data else {
                    loginError = "No response from server"
                    return
                }
                
                if let raw = String(data: data, encoding: .utf8) {
                    print("🔥 Server Response:", raw)
                }
                
                do {
                    let loginResponse = try JSONDecoder().decode(LoginMdoel.self, from: data)
                    
                    print("🟢 Decoded response:", loginResponse)
                    
                    if loginResponse.status.lowercased() == "success" {
                        
                        let user = loginResponse.data
                        
                        patientPID = user.pid
                        patientName = user.name
                        patientEmail = user.email
                        patientPhone = user.phone
                        patientAge = "\(user.age)"
                        patientGender = user.gender
                        patientAddress = user.address
                        patientWork = user.work
                        patientLogin = true
                        
                        print("✅ Saved PID:", patientPID)
                        
                        navigate = true
                        
                    } else {
                        loginError = loginResponse.message
                        print("❌ Server error:", loginResponse.message)
                    }
                    
                } catch {
                    loginError = "JSON decode error: \(error.localizedDescription)"
                    print("❌ Decode error:", error)
                }
            }
        }.resume()
    }
}

#Preview {
    PatientLoginView()
}

struct LoginMdoel: Codable {
    let status, message: String
    let data: LoginMdoelData
}

struct LoginMdoelData: Codable {
    let pid, name: String
    let age: Int
    let gender, phone, email, address: String
    let work, createdAt: String

    enum CodingKeys: String, CodingKey {
        case pid, name, age, gender, phone, email, address, work
        case createdAt = "created_at"
    }
}
