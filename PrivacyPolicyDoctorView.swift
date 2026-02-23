//
//  PrivacyPolicyDoctorView.swift
//  RenalCalculi
//
//  Created by SAIL on 24/11/25.
//


//
// DoctorSupportingViews.swift
// RenalCalculi
//

import SwiftUI

// MARK: - Privacy Policy View
struct PrivacyPolicyDoctorView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 8)
                
                Text("Effective Date: February 2026")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Your privacy is important to us. This application is an academic student research project intended for educational purposes only. It does not provide medical diagnosis, treatment, or clinical advice.")
                    .padding(.vertical, 8)
                
                Text("Data Collection")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("We may collect user-provided information such as medical images, reports, or notes strictly for educational research and app functionality. Providing such data is optional.")
                
                Text("Data Usage")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("Collected data is used only for educational research support, app functionality, and improving user experience. We do not use this information for medical diagnosis or treatment.")
                
                Text("Security")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("We implement reasonable security practices such as encrypted storage and access controls to help protect your information.")
            }

            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
}

// MARK: - Terms & Conditions View
struct TermsConditionsDoctorView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms & Conditions")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 8)
                
                Text("Last Updated: February 2026")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("By using this app, you agree to the following terms and conditions:")
                    .padding(.vertical, 8)
                
                Text("Educational Purpose")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("This application is an academic student research project intended for educational and research purposes only. It is not a medical device and does not provide medical diagnosis, treatment, or clinical advice.")
                
                Text("Use of Information")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("Any information or analysis provided by the app is for general educational awareness only and should not be used for medical decision-making.")
                
                Text("Professional Consultation")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("Users should always consult qualified healthcare professionals for any medical concerns or treatment decisions.")
                
                Text("Liability")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("The developers are not responsible for any actions taken based on the information provided in this application.")
                
                Text("Updates")
                    .font(.headline)
                    .padding(.top, 8)
                
                Text("We may update these terms periodically. Continued use of the app indicates acceptance of any updated terms.")
            }

            .padding()
        }
        .navigationTitle("Terms & Conditions")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
    }
}
// MARK: - Help & Support View (EDUCATIONAL FOCUS)
struct HelpSupportDoctorView: View {
    @State private var showContactForm = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with Academic Focus
                VStack(alignment: .leading, spacing: 8) {
                    Text("Academic Resources")
                        .font(.title)
                        .bold()
                    
                    Text("Educational Research Project")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)

                // IMPORTANT DISCLAIMER BOX
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                            .font(.title2)
                        
                        Text("Academic Project Notice")
                            .font(.headline)
                            .foregroundColor(.orange)
                    }
                    
                    Text("This application is an educational research project developed at Saveetha Institute of Medical and Technical Sciences for academic purposes only.")
                        .font(.body)
                    
                    Text("It is intended SOLELY for studying renal calculi prediction algorithms and is NOT for medical diagnosis, treatment, or clinical use.")
                        .font(.body)
                        .foregroundColor(.orange)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.orange.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        )
                )

                // Academic Contact Information
                VStack(alignment: .leading, spacing: 12) {
                    Text("Research Team Contact")
                        .font(.headline)

                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.teal)

                        VStack(alignment: .leading) {
                            Text("Academic Inquiry Email")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("renalcalculi.ios@gmail.com")
                                .font(.subheadline)
                        }
                    }

                    Text("For academic inquiries, research collaboration, or educational discussions related to this research project.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        
                    Text("Note: Medical inquiries cannot be addressed through this channel.")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.top, 4)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground)))

                // Academic FAQs (NOT Medical FAQs)
                VStack(alignment: .leading, spacing: 12) {
                    Text("Academic & Research FAQs")
                        .font(.headline)

                    FAQItem(
                        question: "What is the purpose of this application?",
                        answer: "This is an educational research project developed to study machine learning algorithms for renal calculi prediction. It is for academic demonstration and research purposes only."
                    )

                    FAQItem(
                        question: "Can I use this for medical diagnosis?",
                        answer: "NO. This application is for educational and research purposes only. It does NOT provide medical diagnosis or treatment advice. Always consult qualified healthcare professionals."
                    )

                    FAQItem(
                        question: "How is my data being used?",
                        answer: "Data is used exclusively for academic research to improve educational algorithms. No data is used for medical purposes. Refer to privacy policy for details."
                    )
                    
                    FAQItem(
                        question: "Who developed this application?",
                        answer: "This application was developed by the academic research team at Saveetha Institute of Medical and Technical Sciences as an educational project."
                    )
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground)))

                // Contact Button with Academic Focus
                Button {
                    showContactForm = true
                } label: {
                    HStack {
                        Image(systemName: "graduationcap.fill") // Changed icon
                        Text("Send Academic Inquiry") // Changed text
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.teal))
                    .foregroundColor(.white)
                }
                .padding(.top, 8)
                
                // Footer Note
                Text("Saveetha Institute of Medical and Technical Sciences\nAcademic Research Project")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Academic Resources")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: BackButton())
        .sheet(isPresented: $showContactForm) {
            ContactSupportFormView()
        }
    }
}

// MARK: - FAQ Item Component (No changes needed to structure)
struct FAQItem: View {
    var question: String
    var answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(question)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.teal)
                }
            }
            
            if isExpanded {
                Text(answer)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemFill)))
    }
}

// MARK: - Contact Support Form (ACADEMIC INQUIRY FOCUS)
struct ContactSupportFormView: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var showSuccess = false
    @State private var showError = false
    
    var body: some View {
        NavigationView {
            Form {
                // Academic Notice
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                        Text("This form is for academic inquiries only")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                Section(header: Text("Contact Information")) {
                    TextField("Your Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Section(header: Text("Academic Inquiry")) {
                    TextField("Subject (e.g., Research Inquiry)", text: $subject)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Message")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextEditor(text: $message)
                            .frame(height: 150)
                    }
                    
                    Text("Please include your academic affiliation and purpose of inquiry")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Section {
                    Button {
                        if isValidEmail(email) && !subject.isEmpty && !message.isEmpty {
                            sendAcademicInquiry()
                            showSuccess = true
                        } else {
                            showError = true
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "graduationcap.fill")
                            Text("Send Academic Inquiry")
                            Spacer()
                        }
                    }
                    .disabled(email.isEmpty || subject.isEmpty || message.isEmpty)
                }
            }
            .navigationTitle("Academic Inquiry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Inquiry Sent", isPresented: $showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                Text("Your academic inquiry has been sent to renalcalculi.ios@gmail.com")
            }
            .alert("Please Check Form", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please ensure all fields are filled and email is valid.")
            }
        }
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func sendAcademicInquiry() {
        // Create email content
        let emailSubject = "Academic Inquiry: \(subject)"
        let emailBody = """
        From: \(email)
        
        Message:
        \(message)
        
        ---
        Sent from Nephrolith Academic Research App
        """
        
        // Create mailto URL
        let mailto = "mailto:renalcalculi.ios@gmail.com?subject=\(emailSubject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(emailBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        // Open default email client
        if let url = URL(string: mailto) {
            UIApplication.shared.open(url)
        }
    }
}
