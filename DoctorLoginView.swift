import SwiftUI

// MARK: - Doctor Login View
struct DoctorLoginResponse: Decodable {
    let status: String
    let message: String
    let data: DoctorData?
}

struct DoctorData: Decodable {
    let did: String
    let name: String
    let email: String
    let specialization: String
    let hospital: String
    let phone: String
    let gender: String
    let created_at: String
}

struct DoctorLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToDashboard = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @State private var showPassword = false
    @State private var animateGradient = false
    @State private var headerScale: CGFloat = 0.5
    @State private var headerOpacity: Double = 0
    @State private var formOffset: CGFloat = 50
    @State private var formOpacity: Double = 0
    
    @AppStorage("doctorDID") var doctorDID: String = ""
    @AppStorage("doctorName") var doctorName: String = ""
    @AppStorage("doctorEmail") var doctorEmail: String = ""
    @AppStorage("doctorPhone") var doctorPhone: String = ""
    @AppStorage("doctorSpecialization") var doctorSpecialization: String = ""
    @AppStorage("doctorHospital") var doctorHospital: String = ""
    @AppStorage("doctorGender") var doctorGender: String = ""
    @AppStorage("doctorLogin") var doctorLogin: Bool = false
    
    var body: some View {
        ZStack {
            // Animated Medical Gradient Background
            LinearGradient(
                colors: [
                    Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.15),
                    Color(red: 0.0, green: 0.6, blue: 0.65).opacity(0.2),
                    Color(red: 0.0, green: 0.45, blue: 0.5).opacity(0.15)
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
            
            // Floating medical icons background
            GeometryReader { geometry in
                ForEach(0..<3) { index in
                    Image(systemName: ["cross.case", "stethoscope", "heart.text.square"][index])
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.05))
                        .offset(
                            x: CGFloat([50, geometry.size.width - 100, 30][index]),
                            y: CGFloat([100, geometry.size.height - 200, geometry.size.height / 2][index])
                        )
                        .rotationEffect(.degrees(Double([15, -15, 30][index])))
                }
            }
            
            ScrollView {
                VStack(spacing: 30) {
                    // Enhanced Animated Header
                    VStack(spacing: 20) {
                        ZStack {
                            // Outer glow ring with pulse
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.0, green: 0.6, blue: 0.65).opacity(0.3),
                                            Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.2)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 140, height: 140)
                                .blur(radius: 10)
                                .scaleEffect(isLoading ? 1.1 : 1.0)
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isLoading)
                            
                            // Icon background circle
                            Circle()
                                .fill(Color.white)
                                .frame(width: 120, height: 120)
                                .shadow(color: Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            // Medical icon
                            Image(systemName: "stethoscope.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.0, green: 0.6, blue: 0.65),
                                            Color(red: 0.0, green: 0.45, blue: 0.5)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .scaleEffect(headerScale)
                        .opacity(headerOpacity)
                        .padding(.top, 60)
                        
                        VStack(spacing: 8) {
                            Text("Doctor Portal")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.0, green: 0.6, blue: 0.65),
                                            Color(red: 0.0, green: 0.5, blue: 0.55)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Text("Welcome back to your medical dashboard")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .opacity(headerOpacity)
                    }
                    
                    // Form Container with Glass Effect
                    VStack(spacing: 25) {
                        // Enhanced Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 0.0, green: 0.6, blue: 0.65))
                                    .frame(width: 24)
                                
                                TextField("Email / Phone Number", text: $email)
                                    .font(.system(size: 16))
                                    .autocapitalization(.none)
                                    .keyboardType(.emailAddress)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.0, green: 0.6, blue: 0.65).opacity(0.3),
                                                Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                        }
                        .padding(.horizontal)
                        
                        // Enhanced Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color(red: 0.0, green: 0.6, blue: 0.65))
                                    .frame(width: 24)
                                
                                if showPassword {
                                    TextField("Password", text: $password)
                                        .font(.system(size: 16))
                                } else {
                                    SecureField("Password", text: $password)
                                        .font(.system(size: 16))
                                }
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.3)) {
                                        showPassword.toggle()
                                    }
                                }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .frame(width: 32, height: 32)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.1), radius: 10, x: 0, y: 5)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.0, green: 0.6, blue: 0.65).opacity(0.3),
                                                Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.3)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                        }
                        .padding(.horizontal)
                        VStack{
                            Text("⚠️ Medical & Academic Disclaimer")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            
                            Text("This app is an academic student research project developed for educational purposes. It is not a medical device and does not provide medical diagnosis, treatment, or clinical advice. Always consult qualified healthcare professionals for medical decisions.")

                                .font(.caption2)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                        }
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(10)
                        .padding()
                        // Forgot Password Link
                        HStack {
                            Spacer()
                            NavigationLink(destination: DoctorForgotPasswordView()) {
                                HStack(spacing: 4) {
                                    Image(systemName: "questionmark.circle.fill")
                                        .font(.caption)
                                    Text("Forgot Password?")
                                }
                                .font(.callout)
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.0, green: 0.6, blue: 0.65),
                                            Color(red: 0.0, green: 0.5, blue: 0.55)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Enhanced Login Button
                        Button(action: {
                            withAnimation {
                                handleLogin()
                            }
                        }) {
                            HStack(spacing: 12) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                } else {
                                    Image(systemName: "lock.open.fill")
                                        .font(.title3)
                                }
                                Text(isLoading ? "Authenticating..." : "Login to Portal")
                                    .fontWeight(.semibold)
                                    .font(.system(size: 17))
                                if !isLoading {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 14, weight: .bold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: (email.isEmpty || password.isEmpty || isLoading) ?
                                    [.gray, .gray.opacity(0.8)] :
                                    [
                                        Color(red: 0.0, green: 0.6, blue: 0.65),
                                        Color(red: 0.0, green: 0.5, blue: 0.55)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(
                                color: (email.isEmpty || password.isEmpty || isLoading) ?
                                .clear : Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.4),
                                radius: 15,
                                x: 0,
                                y: 10
                            )
                        }
                        .disabled(email.isEmpty || password.isEmpty || isLoading)
                        .padding(.horizontal)
                        .scaleEffect(isLoading ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3), value: isLoading)
                    }
                    .padding(.vertical, 30)
                    .offset(y: formOffset)
                    .opacity(formOpacity)
                    
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
                        
                        NavigationLink(destination: DoctorSignupView()) {
                            HStack(spacing: 6) {
                                Image(systemName: "person.badge.plus")
                                    .font(.callout)
                                Text("New medical professional?")
                                    .foregroundColor(.secondary)
                                Text("Register Here")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.0, green: 0.6, blue: 0.65),
                                                Color(red: 0.0, green: 0.5, blue: 0.55)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            }
                            .font(.subheadline)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.0, green: 0.6, blue: 0.65).opacity(0.5),
                                                Color(red: 0.0, green: 0.5, blue: 0.55).opacity(0.5)
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                        }
                    }
                    .padding(.bottom, 30)
                }
            }
            
            NavigationLink(destination: DoctorAppRootView(), isActive: $navigateToDashboard) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .alert("Login Failed", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                headerScale = 1.0
                headerOpacity = 1.0
            }
            
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                formOffset = 0
                formOpacity = 1.0
            }
        }
    }

    func handleLogin() {
        guard !email.isEmpty, !password.isEmpty else {
            alertMessage = "Please fill in all fields"
            showAlert = true
            return
        }

        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/dlogin.php") else {
            alertMessage = "Invalid server URL"
            showAlert = true
            return
        }

        isLoading = true

        let isEmail = email.contains("@")
        var body: [String: Any] = ["password": password]

        if isEmail {
            body["email"] = email
        } else {
            body["phone"] = email
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            isLoading = false
            alertMessage = "Failed to create request"
            showAlert = true
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
                    alertMessage = "Network error: \(error.localizedDescription)"
                    showAlert = true
                    return
                }

                guard let data = data else {
                    alertMessage = "No data from server"
                    showAlert = true
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let loginResponse = try decoder.decode(DoctorLoginResponse.self, from: data)

                    if loginResponse.status == "success", let doctorData = loginResponse.data {
                        self.doctorDID = doctorData.did
                        self.doctorName = doctorData.name
                        self.doctorEmail = doctorData.email
                        self.doctorPhone = doctorData.phone
                        self.doctorSpecialization = doctorData.specialization
                        self.doctorHospital = doctorData.hospital
                        self.doctorGender = doctorData.gender
                        self.doctorLogin = true
                        print("✅ Doctor logged in: \(doctorData.did)")
                        navigateToDashboard = true
                    } else {
                        alertMessage = loginResponse.message
                        showAlert = true
                    }
                } catch {
                    alertMessage = "Invalid response from server"
                    showAlert = true
                }
            }
        }.resume()
    }
}

// MARK: - PREVIEW
struct DoctorLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            DoctorLoginView()
        }
    }
}
