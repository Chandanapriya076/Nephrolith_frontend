import SwiftUI

struct DoctorForgotPasswordView: View {
    @State private var email = ""
    @State private var phone = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    @State private var verificationMessage = ""
    @State private var verificationColor = Color.clear
    
    @State private var step = 1 // 1: Verification, 2: Reset Password
    @State private var isLoading = false
    @State private var doctorName = ""
    
    var body: some View {
        VStack(spacing: 22) {
            Text("Reset Password")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.teal)
                .padding(.top, 40)
            
            if step == 1 {
                // 🔹 Step 1: Verification
                verificationStepView()
            } else {
                // 🔹 Step 2: Reset Password
                resetPasswordStepView()
            }
            
            if !verificationMessage.isEmpty {
                Text(verificationMessage)
                    .fontWeight(.semibold)
                    .foregroundColor(verificationColor)
                    .padding(.top, 10)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .navigationBarTitle("Forgot Password", displayMode: .inline)
    }
    
    // 🔹 MARK: Step 1 - Verification View
    @ViewBuilder
    private func verificationStepView() -> some View {
        Text("Enter your registered email or phone number to verify your account.")
            .font(.body)
            .foregroundColor(.gray)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
        
        TextField("Email", text: $email)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .autocapitalization(.none)
            .keyboardType(.emailAddress)
            .disabled(isLoading)
        
        Text("OR")
            .font(.caption)
            .foregroundColor(.gray)
            .padding(.vertical, 5)
        
        TextField("Phone (10 digits)", text: $phone)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .keyboardType(.numberPad)
            .disabled(isLoading)
        
        Button(action: {
            verifyDoctor()
        }) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Verify Account")
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.teal)
        .cornerRadius(14)
        .padding(.horizontal)
        .disabled(isLoading || (email.isEmpty && phone.isEmpty))
    }
    
    // 🔹 MARK: Step 2 - Reset Password View
    @ViewBuilder
    private func resetPasswordStepView() -> some View {
        VStack(spacing: 16) {
            Text("Welcome, \(doctorName)")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundColor(.teal)
            
            Text("Enter your new password")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        
        SecureField("New Password (min 6 chars)", text: $newPassword)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .disabled(isLoading)
        
        SecureField("Confirm Password", text: $confirmPassword)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal)
            .disabled(isLoading)
        
        Button(action: {
            resetPassword()
        }) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Reset Password")
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.teal)
        .cornerRadius(14)
        .padding(.horizontal)
        .disabled(isLoading || newPassword.isEmpty || confirmPassword.isEmpty)
        
        Button(action: {
            step = 1
            resetForm()
        }) {
            Text("← Back to Verification")
                .foregroundColor(.teal)
        }
        .padding(.top, 10)
    }
    
    // ✅ MARK: Verify Doctor Account
    private func verifyDoctor() {
        // Validation
        if email.isEmpty && phone.isEmpty {
            verificationMessage = "Enter email or phone ❌"
            verificationColor = .red
            return
        }
        
        if !email.isEmpty && !email.contains("@") {
            verificationMessage = "Enter valid email ❌"
            verificationColor = .red
            return
        }
        
        if !phone.isEmpty && phone.count != 10 {
            verificationMessage = "Phone must be 10 digits ❌"
            verificationColor = .red
            return
        }
        
        isLoading = true
        let urlString = "http://14.139.187.229:8081/oct/renal/dforgot.php" // Update with your IP
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var payload: [String: String] = ["mode": "verify"]
        if !email.isEmpty {
            payload["email"] = email.lowercased()
        } else {
            payload["phone"] = phone
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { isLoading = false }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    verificationMessage = "Network error ❌"
                    verificationColor = .red
                }
                return
            }
            
            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = response["status"] as? String {
                
                DispatchQueue.main.async {
                    if status == "success" {
                        doctorName = (response["name"] as? String) ?? "Doctor"
                        verificationMessage = "Account verified! ✅"
                        verificationColor = .green
                        
                        // Move to step 2 after 1 second
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            step = 2
                        }
                    } else {
                        let msg = response["message"] as? String ?? "Verification failed"
                        verificationMessage = msg + " ❌"
                        verificationColor = .red
                    }
                }
            }
        }.resume()
    }
    
    // ✅ MARK: Reset Password
    private func resetPassword() {
        // Validation
        if newPassword.count < 6 {
            verificationMessage = "Password must be at least 6 characters ❌"
            verificationColor = .red
            return
        }
        
        if newPassword != confirmPassword {
            verificationMessage = "Passwords do not match ❌"
            verificationColor = .red
            return
        }
        
        isLoading = true
        let urlString = "http://14.139.187.229:8081/oct/renal/dforgot.php" // Update with your IP
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var payload: [String: String] = [
            "mode": "reset",
            "password": newPassword
        ]
        
        if !email.isEmpty {
            payload["email"] = email.lowercased()
        } else {
            payload["phone"] = phone
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { isLoading = false }
            
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    verificationMessage = "Network error ❌"
                    verificationColor = .red
                }
                return
            }
            
            if let response = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let status = response["status"] as? String {
                
                DispatchQueue.main.async {
                    if status == "success" {
                        verificationMessage = "Password reset successfully! ✅"
                        verificationColor = .green
                        
                        // Show success and dismiss after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            resetForm()
                            // Navigate back to login
                        }
                    } else {
                        let msg = response["message"] as? String ?? "Password reset failed"
                        verificationMessage = msg + " ❌"
                        verificationColor = .red
                    }
                }
            }
        }.resume()
    }
    
    // 🔹 MARK: Reset Form
    private func resetForm() {
        email = ""
        phone = ""
        newPassword = ""
        confirmPassword = ""
        doctorName = ""
        verificationMessage = ""
        step = 1
    }
}

struct DoctorForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        DoctorForgotPasswordView()
    }
}
                   
