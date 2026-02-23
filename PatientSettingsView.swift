import SwiftUI

struct PatientSettingsView: View {
    let pid: String
    
    @AppStorage("patientPID") private var patientPID: String = ""
    @AppStorage("patientName") private var patientName: String = ""
    @AppStorage("patientEmail") private var patientEmail: String = ""
    @AppStorage("patientPhone") private var patientPhone: String = ""
    @AppStorage("patientAge") private var patientAge: String = ""
    @AppStorage("patientGender") private var patientGender: String = ""
    @AppStorage("patientAddress") private var patientAddress: String = ""
    @AppStorage("patientWork") private var patientWork: String = ""
    
    @AppStorage("doctorLogin") var doctorLogin: Bool = false
    @AppStorage("patientLogin") var patientLogin: Bool = false
    
    @State private var showLogoutAlert = false
    @State private var navigateToUserSelection = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.teal.opacity(0.08), Color.blue.opacity(0.05), Color.cyan.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Card with Avatar
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.teal.opacity(0.2), Color.blue.opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.teal, .teal.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        VStack(spacing: 6) {
                            Text(patientName.isEmpty ? "Patient" : patientName)
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text(patientEmail.isEmpty ? "No email" : patientEmail)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .strokeBorder(Color.teal.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 16)
                    
                    // Settings Sections
                    VStack(spacing: 20) {
                        // General Settings Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.teal.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "gear")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.teal)
                                }
                                
                                Text("General Settings")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            
                            SettingsRow(
                                icon: "number.circle.fill",
                                label: "Patient ID",
                                value: pid,
                                color: .teal
                            )
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.teal.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        
                        // Account Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                                
                                Text("Account Information")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            
                            VStack(spacing: 10) {
                                SettingsRow(
                                    icon: "person.text.rectangle.fill",
                                    label: "Name",
                                    value: patientName.isEmpty ? "Not set" : patientName,
                                    color: .blue
                                )
                                
                                Divider()
                                    .overlay(Color.gray.opacity(0.2))
                                
                                SettingsRow(
                                    icon: "envelope.fill",
                                    label: "Email",
                                    value: patientEmail.isEmpty ? "Not set" : patientEmail,
                                    color: .blue
                                )
                                
                                if !patientPhone.isEmpty {
                                    Divider()
                                        .overlay(Color.gray.opacity(0.2))
                                    
                                    SettingsRow(
                                        icon: "phone.fill",
                                        label: "Phone",
                                        value: patientPhone,
                                        color: .blue
                                    )
                                }
                                
                                if !patientAge.isEmpty {
                                    Divider()
                                        .overlay(Color.gray.opacity(0.2))
                                    
                                    SettingsRow(
                                        icon: "calendar.badge.plus",
                                        label: "Age",
                                        value: patientAge,
                                        color: .blue
                                    )
                                }
                            }
                            .padding(12)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(12)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.blue.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        
                        NavigationLink(destination: AboutNephrolithView()) {
                            HStack(spacing: 16) {
                                // Icon Container with Gradient
                                ZStack {
                                    // Background glow effect
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.teal.opacity(0.2), .blue.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 48, height: 48)
                                        .shadow(color: .teal.opacity(0.3), radius: 4, x: 0, y: 2)
                                    
                                    // Icon
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.teal, .blue],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                        .shadow(color: .teal.opacity(0.3), radius: 2, x: 0, y: 1)
                                }
                                
                                // Text Content
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("About Nephrolith")
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("App Information & Details")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                // Chevron with animation
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.gray.opacity(0.7))
                                    .padding(.trailing, 4)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                            .background(
                                // Background with subtle gradient and shadow
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white,
                                                Color(.systemGray6)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(
                                        color: .black.opacity(0.05),
                                        radius: 8,
                                        x: 0,
                                        y: 4
                                    )
                                    .overlay(
                                        // Border with gradient
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [
                                                        .gray.opacity(0.1),
                                                        .gray.opacity(0.05)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1
                                            )
                                    )
                            )
                            .contentShape(Rectangle())
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        // Danger Zone Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 10) {
                                ZStack {
                                    Circle()
                                        .fill(Color.red.opacity(0.12))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.red)
                                }
                                
                                Text("Account Actions")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 4)
                            
                            Button(action: { showLogoutAlert = true }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "arrow.right.to.line")
                                        .font(.system(size: 14, weight: .semibold))
                                    
                                    Text("Logout")
                                        .font(.system(size: 15, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(
                                    LinearGradient(
                                        colors: [Color.red.opacity(0.1), Color.red.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.red)
                                .cornerRadius(12)
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .strokeBorder(Color.red.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 16)
                    
                    // Footer Info
                    VStack(spacing: 8) {
                        Text("Version 1.0.0")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text("© 2025 NEPHROLITH.")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    
                    Color.clear.frame(height: 80)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                handleLogout()
            }
        } message: {
            Text("Are you sure you want to logout? You'll need to log in again to access your account.")
        }
        
        NavigationLink(
            destination: LogoScreen(),
            isActive: $navigateToUserSelection
        ) {
            EmptyView()
        }
        .hidden()
    }
    
    func handleLogout() {
        print("🚪 Logging out - PID: \(pid)")
        patientPID = ""
        patientName = ""
        patientEmail = ""
        patientPhone = ""
        patientAge = ""
        patientGender = ""
        patientAddress = ""
        patientWork = ""
        print("🗑️ All data cleared")
        doctorLogin = false
        patientLogin = false
        navigateToUserSelection = true
    }
    
}

// MARK: - Settings Row Component
struct SettingsRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                
                Text(value)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        PatientSettingsView(pid: "PID001")
    }
}
