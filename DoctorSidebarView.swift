import SwiftUI
import WebKit

// MARK: - WEBVIEW
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Custom Navigation Link Style
struct SidebarNavigationLinkStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
    }
}

// MARK: - Doctor Sidebar Button Component
struct SidebarButton: View {
    let icon: String
    let title: String
    let subtitle: String?
    let showChevron: Bool
    let action: () -> Void
    
    init(icon: String, title: String, subtitle: String? = nil, showChevron: Bool = true, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon Container
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.teal.opacity(0.15), .blue.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.teal, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Chevron or custom indicator
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.trailing, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.08), lineWidth: 1)
                    )
            )
        }
    }
}

// ------------------------------------------------------
// MARK: DOCTOR SIDEBAR VIEW (ENHANCED VERSION)
// ------------------------------------------------------

struct DoctorSidebarView: View {
    @EnvironmentObject var profile: DoctorProfile
    @Binding var showSidebar: Bool
    @Binding var navigateToUserSelection: Bool
    
    // MARK: Full-screen Navigation States
    @State private var showProfile = false
    @State private var showSettings = false
    @State private var showHelp = false
    @State private var showPrivacy = false
    @State private var showTerms = false
    @State private var showAbout = false
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @AppStorage("doctorLogin") var doctorLogin: Bool = false
    @AppStorage("patientLogin") var patientLogin: Bool = false
    
    @State private var showLogoutAlert = false
    var onLogout: (() -> Void)?
    
    // Animation states
    @State private var animateHeader = false
    
    var body: some View {
        ZStack {
            // Background with gradient
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.secondarySystemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // HEADER
                profileHeader
                    .opacity(animateHeader ? 1 : 0)
                    .offset(y: animateHeader ? 0 : -20)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.4)) {
                            animateHeader = true
                        }
                    }
                
                Divider()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .opacity(0.2)
                
                ScrollView {
                    VStack(spacing: 12) {
                        // MAIN SECTION
                        VStack(spacing: 12) {
                            // Profile Button
                            SidebarButton(
                                icon: "person.crop.square.fill",
                                title: "My Profile",
                                subtitle: "View & edit your profile"
                            ) {
                                showProfile = true
                            }
                            
                            // Help & Support
                            SidebarButton(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                subtitle: "Get help using the app"
                            ) {
                                showHelp = true
                            }
                            
                            // Privacy Policy
                            SidebarButton(
                                icon: "shield.fill",
                                title: "Privacy Policy",
                                subtitle: "View our privacy policy"
                            ) {
                                showPrivacy = true
                            }
                            
                            // Terms & Conditions
                            SidebarButton(
                                icon: "doc.text.fill",
                                title: "Terms & Conditions",
                                subtitle: "App terms of service"
                            ) {
                                showTerms = true
                            }
                            
                            // About Nephrolith
                            SidebarButton(
                                icon: "info.circle.fill",
                                title: "About Nephrolith",
                                subtitle: "App information & details"
                            ) {
                                showAbout = true
                            }
                        }
                        .padding(.horizontal, 16)
                        
                        Divider()
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .opacity(0.2)
                        
                        // SETTINGS SECTION
                        VStack(spacing: 12) {
                            // Theme Toggle
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: isDarkMode ?
                                                    [.purple.opacity(0.15), .indigo.opacity(0.1)] :
                                                    [.orange.opacity(0.15), .yellow.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: isDarkMode ?
                                                    [.purple, .indigo] :
                                                    [.orange, .yellow],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Appearance")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text(isDarkMode ? "Dark Mode" : "Light Mode")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isDarkMode)
                                    .toggleStyle(SwitchToggleStyle(tint: .teal))
                                    .scaleEffect(0.9)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
                            )
                        }
                        .padding(.horizontal, 16)
                        
                        // LOGOUT BUTTON
                        Button(action: { showLogoutAlert = true }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.red.opacity(0.2), .red.opacity(0.1)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: "power")
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.red, .orange],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Logout")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.primary)
                                    
                                    Text("Sign out from your account")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .red.opacity(0.05), radius: 6, x: 0, y: 3)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.red.opacity(0.1), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        
                        // FOOTER
                        VStack(spacing: 4) {
                            Text("©2025 Nephrolith v1.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        
        // LOGOUT ALERT
        .alert("Confirm Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) { performLogout() }
        } message: {
            Text("Are you sure you want to logout?")
        }
        
        // ------------------------------------------------------
        // MARK: FULL SCREEN COVERS
        // ------------------------------------------------------
        
        .fullScreenCover(isPresented: $showProfile) {
            NavigationStack {
                DoctorProfileView()
            }
        }
        
        .fullScreenCover(isPresented: $showHelp) {
            NavigationStack {
                HelpSupportDoctorView()
            }
        }
        
        .fullScreenCover(isPresented: $showPrivacy) {
            NavigationStack {
                PrivacyPolicyDoctorView()
            }
        }
        
        .fullScreenCover(isPresented: $showTerms) {
            NavigationStack {
                TermsConditionsDoctorView()
            }
        }
        
        .fullScreenCover(isPresented: $showAbout) {
            NavigationStack {
                AboutNephrolithView2()
            }
        }
    }
    
    // ------------------------------------------------------
    // MARK: ENHANCED PROFILE HEADER
    // ------------------------------------------------------
    
    var profileHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 16) {
                // Profile Image/Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.teal, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .shadow(color: .teal.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(profile.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(profile.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            
            // Specialization Badge
            HStack(spacing: 8) {
                Image(systemName: "stethoscope")
                    .font(.caption)
                    .foregroundColor(.white)
                
                Text(profile.specialization)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Status Indicator
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 6, height: 6)
                    
                    Text("Online")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                LinearGradient(
                    colors: [.teal.opacity(0.9), .blue.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(10)
        }
        .padding(20)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        )
    }
    
    // ------------------------------------------------------
    // MARK: LOGOUT
    // ------------------------------------------------------
    
    func performLogout() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showSidebar = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            doctorLogin = false
            patientLogin = false
            onLogout?()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                navigateToUserSelection = true
            }
        }
    }
}

