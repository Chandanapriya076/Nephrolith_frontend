import SwiftUI

struct PatientForgotPasswordView: View {
    @State private var emailOrPhone = ""
    @State private var verificationMessage = ""
    @State private var verificationColor = Color.clear
    @State private var isVerified = false
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var resetMessage = ""
    @State private var showResetAlert = false
    @State private var navigateToLogin = false
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 22) {

            Text("Reset Password")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.teal)
                .padding(.top, 40)

            Text("Enter your registered email or phone to verify your account for password reset.")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            TextField("Email or Phone", text: $emailOrPhone)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .disabled(isVerified)

            Button(action: {
                verifyAccount()
            }) {
                Text(isVerified ? "Verified" : "Verify Account")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isVerified ? Color.gray : Color.teal)
                    .cornerRadius(14)
                    .padding(.horizontal)
            }
            .disabled(emailOrPhone.isEmpty || isVerified)

            if !verificationMessage.isEmpty {
                Text(verificationMessage)
                    .fontWeight(.semibold)
                    .foregroundColor(verificationColor)
                    .padding(.top, 10)
            }

            // Show password fields only if verified
            if isVerified {
                SecureField("New Password", text: $newPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                SecureField("Confirm New Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)

                Button(action: {
                    updatePassword()
                }) {
                    Text(isLoading ? "Saving..." : "Save and Continue")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .cornerRadius(14)
                        .padding(.horizontal)
                }
                .disabled(newPassword.isEmpty || confirmPassword.isEmpty || isLoading)

                NavigationLink("", destination: PatientLoginView(), isActive: $navigateToLogin).hidden()
            }

            Spacer()
        }
        .navigationBarTitle("Forgot Password", displayMode: .inline)
        .alert("Password Reset", isPresented: $showResetAlert) {
            Button("OK", role: .cancel) {
                if resetMessage == "Password updated successfully!" {
                    navigateToLogin = true
                }
            }
        } message: {
            Text(resetMessage)
        }
    }
    
    // MARK: - Account Verification (email or phone)
    func verifyAccount() {
        verificationMessage = ""
        verificationColor = .clear
        isLoading = true
        guard !emailOrPhone.isEmpty else { return }
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/pforgot.php") else { return }

        var body: [String: Any] = ["mode": "verify"]
        if emailOrPhone.contains("@") {
            body["email"] = emailOrPhone.trimmingCharacters(in: .whitespaces)
        } else {
            body["phone"] = emailOrPhone.trimmingCharacters(in: .whitespaces)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async { isLoading = false }
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    verificationMessage = "Verification failed. Try again."
                    verificationColor = .red
                }
                return
            }
            DispatchQueue.main.async {
                if json["status"] as? String == "success" {
                    verificationMessage = "Successfully Verified ✅"
                    verificationColor = .green
                    isVerified = true
                } else {
                    verificationMessage = json["message"] as? String ?? "Account Not Verified ❌"
                    verificationColor = .red
                }
            }
        }.resume()
    }
    
    // MARK: - Password Update (calls pforgot.php)
    func updatePassword() {
        resetMessage = ""
        guard !newPassword.isEmpty, !confirmPassword.isEmpty else { return }
        guard newPassword == confirmPassword else {
            resetMessage = "Passwords do not match"
            showResetAlert = true
            return
        }
        guard newPassword.count >= 6 else {
            resetMessage = "Password must be at least 6 characters"
            showResetAlert = true
            return
        }
        isLoading = true
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/pforgot.php") else { return }
        var body: [String: Any] = ["mode": "reset", "password": newPassword]
        if emailOrPhone.contains("@") {
            body["email"] = emailOrPhone.trimmingCharacters(in: .whitespaces)
        } else {
            body["phone"] = emailOrPhone.trimmingCharacters(in: .whitespaces)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            DispatchQueue.main.async { isLoading = false }
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    resetMessage = "Failed to update password"
                    showResetAlert = true
                }
                return
            }
            DispatchQueue.main.async {
                if json["status"] as? String == "success" {
                    resetMessage = "Password updated successfully!"
                } else {
                    resetMessage = json["message"] as? String ?? "Failed to update password"
                }
                showResetAlert = true
            }
        }.resume()
    }
}

struct PatientForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        PatientForgotPasswordView()
    }
}
