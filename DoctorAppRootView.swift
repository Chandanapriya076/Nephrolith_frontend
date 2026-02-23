import SwiftUI

// MARK: - Main App Root with DID Persistence & Helper Functions

struct DoctorAppRootView: View {
    @StateObject var profile = DoctorProfile()
    @StateObject var patientsStore = PatientsStore()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    // ✅ PERSISTENT DID - Survives app restarts until logout
    @AppStorage("doctorDID") private var doctorDID: String = ""
    @AppStorage("doctorName") private var doctorName: String = ""
    @AppStorage("doctorEmail") private var doctorEmail: String = ""
    @AppStorage("doctorPhone") private var doctorPhone: String = ""
    @AppStorage("doctorSpecialization") private var doctorSpecialization: String = ""
    @AppStorage("doctorHospital") private var doctorHospital: String = ""
    @AppStorage("doctorGender") private var doctorGender: String = ""
    
    @State private var selectedTab = 0
    @State private var showSidebar = false
    @State private var navigateToUserSelection = false
    @State private var isAppReady = false
    
    var body: some View {
        ZStack {
            if !isAppReady {
                // ✅ INITIALIZATION CHECK
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading doctor portal...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    initializeApp()
                }
                
            } else if navigateToUserSelection {
                // ✅ NAVIGATE TO USER SELECTION AFTER LOGOUT
                UserSelectionView()
                
            } else {
                ZStack(alignment: .bottom) {
                    // Main Content - takes full space
                    TabView(selection: $selectedTab) {
                        // Dashboard Tab (Tab 0)
                        DoctorDashboardView(showSidebar: $showSidebar, selectedTab: $selectedTab)
                            .environmentObject(profile)
                            .environmentObject(patientsStore)
                            .navigationBarHidden(true)
                            .tag(0)
                        
                        // Patients Tab (Tab 1) - Shows AllCasesView
                        AllCasesView()
                            .environmentObject(profile)
                            .navigationBarHidden(true)
                            .tag(1)
                        
                        // Profile Tab (Tab 2)
                        DoctorProfileView()
                            .environmentObject(profile)
                            .navigationBarHidden(true)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // ✨ FIXED TAB BAR AT BOTTOM - Only icons float, bar stays fixed
                    LiquidBar(selectedTab: $selectedTab)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                }
                
                .preferredColorScheme(isDarkMode ? .dark : .light)
                
                // Twitter-style Sidebar Overlay
                if showSidebar {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                showSidebar = false
                            }
                        }
                    
                    HStack {
                        DoctorSidebarView(
                            showSidebar: $showSidebar,
                            navigateToUserSelection: $navigateToUserSelection,
                            onLogout: handleLogout
                        )
                        .environmentObject(profile)
                        .frame(width: 280)
                        .background(Color(.systemBackground))
                        .shadow(radius: 10)
                        .transition(.move(edge: .leading))
                        
                        Spacer()
                    }
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
    
    // ✅ INITIALIZATION - Load doctor data from AppStorage
    func initializeApp() {
        print("🔑 Initializing Doctor Portal...")
        if !doctorDID.isEmpty {
            print("✅ Found existing session for: \(doctorDID)")
            profile.did = doctorDID
            profile.name = doctorName
            profile.email = doctorEmail
            profile.phone = doctorPhone
            profile.specialization = doctorSpecialization
            profile.hospital = doctorHospital
            profile.gender = doctorGender
            patientsStore.currentDoctorDID = doctorDID
            print("📱 Doctor data restored: \(profile.name) (\(doctorDID))")
        } else {
            print("⚠️ No active session found")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.3)) {
                isAppReady = true
            }
        }
    }
    
    // ✅ LOGOUT - Clear all AppStorage values FIRST, then navigate
    func handleLogout() {
        print("🚪 Logging out doctor: \(doctorDID)")
        doctorDID = ""
        doctorName = ""
        doctorEmail = ""
        doctorPhone = ""
        doctorSpecialization = ""
        doctorHospital = ""
        doctorGender = ""
        profile.did = ""
        profile.name = ""
        profile.email = ""
        profile.phone = ""
        profile.specialization = ""
        profile.hospital = ""
        profile.gender = ""
        patientsStore.selectedPatients = []
        patientsStore.currentDoctorDID = ""
        print("🗑️ All user data cleared")
        print("🔄 Navigating to User Selection...")
        withAnimation {
            navigateToUserSelection = true
        }
    }
}

// MARK: - Fixed Liquid Bar Component (Bar stays fixed, only icons float)

struct LiquidBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation
    
    let tabs: [DoctorTabItem] = [
        DoctorTabItem(icon: "chart.bar.doc.horizontal", title: "Dashboard", tag: 0),
        DoctorTabItem(icon: "person.3", title: "Patients", tag: 1),
        DoctorTabItem(icon: "person.crop.circle", title: "Profile", tag: 2)
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.tag) { tab in
                LiquidBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab.tag,
                    namespace: animation
                ) {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        selectedTab = tab.tag
                    }
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            ZStack {
                // Glassmorphism effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.8),
                                        Color.white.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                // Shimmer border effect
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.teal.opacity(0.5),
                                Color.cyan.opacity(0.3),
                                Color.teal.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            }
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 6)
            .shadow(color: Color.teal.opacity(0.3), radius: 8, x: 0, y: 3)
        )
    }
}

// MARK: - Liquid Bar Button (Only icon floats, button stays fixed)

struct LiquidBarButton: View {
    let tab: DoctorTabItem
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var floatOffset: CGFloat = 0
    
    var body: some View {
        Button(action: {
            action()
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        // Compact liquid blob with ripple effect
                        ZStack {
                            // Outer ripple - smaller
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.teal.opacity(0.3),
                                            Color.cyan.opacity(0.2),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 14,
                                        endRadius: 28
                                    )
                                )
                                .frame(width: 56, height: 56)
                            
                            // Main liquid blob - compact
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.teal,
                                            Color.cyan.opacity(0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .matchedGeometryEffect(id: "LIQUID_BLOB", in: namespace)
                                .frame(width: 48, height: 48)
                                .shadow(color: Color.teal.opacity(0.6), radius: 6, x: 0, y: 3)
                            
                            // Glossy highlight
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.6),
                                            Color.clear
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .center
                                    )
                                )
                                .frame(width: 48, height: 48)
                                .blur(radius: 2)
                        }
                    }
                    
                    // Icon - FLOATS ONLY WHEN SELECTED
                    Image(systemName: isSelected ? "\(tab.icon).fill" : tab.icon)
                        .font(.system(size: 20, weight: isSelected ? .bold : .regular))
                        .foregroundStyle(
                            isSelected
                            ? LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                              )
                            : LinearGradient(
                                colors: [Color.gray.opacity(0.7), Color.gray.opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                              )
                        )
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .offset(y: isSelected ? floatOffset : 0)  // Icon floats vertically
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isSelected)
                }
                .frame(height: 52)
                
                // Label - compact
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(
                        isSelected
                        ? LinearGradient(
                            colors: [Color.teal, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                        : LinearGradient(
                            colors: [Color.gray, Color.gray.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                          )
                    )
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                    .offset(y: isSelected ? -1 : 0)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(LiquidButtonStyle())
        .onAppear {
            if isSelected {
                // Icon float animation
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    floatOffset = -2
                }
            }
        }
        .onChange(of: isSelected) { newValue in
            if newValue {
                // Start floating when selected
                withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                    floatOffset = -2
                }
            } else {
                // Stop floating when deselected
                floatOffset = 0
            }
        }
    }
}

// MARK: - Custom Button Style

struct LiquidButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Doctor Tab Item Model

struct DoctorTabItem {
    let icon: String
    let title: String
    let tag: Int
}

// MARK: - Preview

#Preview {
    DoctorAppRootView()
}
