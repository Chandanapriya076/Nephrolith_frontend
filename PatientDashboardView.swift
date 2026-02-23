import SwiftUI

// --------------------------------------------------
// MARK: - LAST REPORT MODELS
// --------------------------------------------------
struct LastReport: Codable {
    let size: [String]
    let count: Int
    let location: [String]
}

struct LastReportResponse: Codable {
    let success: Bool
    let last_report: LastReport?
    let debug_pid_searched: String?
}

// ✅ NEW: Doctor Review Notification Model
struct DoctorReviewNotification: Identifiable {
    let id = UUID()
    let message: String
    let timestamp: Date
}

// --------------------------------------------------
// MARK: - TAB IDENTIFIER (SINGLE SOURCE OF TRUTH)
// --------------------------------------------------
enum LiquidTab: Int, CaseIterable {
    case home = 0
    case reports
    case profile
    case settings

    var title: String {
        switch self {
        case .home: return "Home"
        case .reports: return "Reports"
        case .profile: return "Profile"
        case .settings: return "Settings"
        }
    }

    var systemImageName: String {
        switch self {
        case .home: return "house"
        case .reports: return "doc.text"
        case .profile: return "person"
        case .settings: return "gearshape"
        }
    }

    var systemImageNameFilled: String {
        switch self {
        case .home: return "house.fill"
        case .reports: return "doc.text.fill"
        case .profile: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// --------------------------------------------------
// MARK: - MAIN PATIENT DASHBOARD VIEW
// --------------------------------------------------
struct PatientDashboardView: View {
    @State private var selectedTab: LiquidTab = .home
    @State private var navigateToUserSelection = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Namespace private var tabNamespace
    @AppStorage("patientPID") var patientPID: String = ""
    @State private var patientName: String = ""

    // ✅ NEW: Doctor review notification state
    @State private var doctorReviewNotifications: [DoctorReviewNotification] = []
    @AppStorage("hasSeenDoctorReviewNotification") private var hasSeenNotification = false

    var body: some View {
        NavigationView {
            ZStack {
                // MARK: - Main Tab Content
                Group {
                    switch selectedTab {
                    case .home:
                        PatientDashboardContent(
                            pid: patientPID,
                            patientName: $patientName,
                            doctorReviewNotifications: $doctorReviewNotifications,
                            hasSeenNotification: $hasSeenNotification
                        )

                    case .reports:
                        ReportsHistoryContent(pid: patientPID)
                    case .profile:
                        PatientProfileContent(pid: patientPID)
                    case .settings:
                        PatientSettingsView(pid: patientPID)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .transition(.opacity.combined(with: .scale))

                // MARK: - Floating Tab Bar (only on main tabs)
                VStack {
                    Spacer()
                    if [.home, .reports, .profile, .settings].contains(selectedTab) {
                        LiquidTabBar(
                            selectedTab: $selectedTab,
                            namespace: tabNamespace,
                            notificationCount: doctorReviewNotifications.count
                        )
                            .padding(.horizontal, 18)
                            .padding(.bottom, 10)
                    }
                }

                // MARK: - Hidden NavigationLink
                NavigationLink(
                    "",
                    destination: LogoScreen(),
                    isActive: $navigateToUserSelection
                )
                .hidden()
            }
            .frame(maxWidth: .infinity)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}


// --------------------------------------------------
// MARK: - LIQUID TAB BAR COMPONENT (WITH BADGE)
// --------------------------------------------------
struct LiquidTabBar: View {
    @Binding var selectedTab: LiquidTab
    var namespace: Namespace.ID
    var notificationCount: Int

    private let capsuleHeight: CGFloat = 72
    private let iconSize: CGFloat = 22
    private let selectedIconSize: CGFloat = 28

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let tabCount = CGFloat(LiquidTab.allCases.count)
            let itemWidth = width / tabCount

            ZStack {
                // Background with gradient & glow
                ZStack {
                    RoundedRectangle(cornerRadius: capsuleHeight / 2 + 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.teal.opacity(0.3), Color.blue.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blur(radius: 8)
                        .frame(height: capsuleHeight + 4)

                    RoundedRectangle(cornerRadius: capsuleHeight / 2 + 6)
                        .fill(.ultraThinMaterial)
                        .frame(height: capsuleHeight)
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                }

                // Animated Bubble
                HStack(spacing: 0) {
                    ForEach(LiquidTab.allCases, id: \.self) { _ in
                        Color.clear.frame(width: itemWidth)
                    }
                }
                .overlay(
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [Color.teal.opacity(0.6), Color.teal.opacity(0.0)],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 45
                                )
                            )
                            .frame(width: 80, height: 80)
                            .blur(radius: 10)

                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.teal, Color.teal.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 64, height: 64)
                            .shadow(color: Color.teal.opacity(0.5), radius: 12, x: 0, y: 6)
                    }
                    .matchedGeometryEffect(id: "bubble", in: namespace)
                    .offset(x: bubbleOffset(width: width, itemWidth: itemWidth), y: -20)
                )

                // Tab Icons
                HStack(spacing: 0) {
                    ForEach(LiquidTab.allCases, id: \.self) { tab in
                        Button {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()

                            withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                                selectedTab = tab
                            }
                        } label: {
                            VStack(spacing: 6) {
                                ZStack(alignment: .topTrailing) {
                                    if selectedTab == tab {
                                        Image(systemName: tab.systemImageNameFilled)
                                            .font(.system(size: selectedIconSize, weight: .semibold))
                                            .foregroundColor(.white)
                                            .offset(y: -10)
                                            .matchedGeometryEffect(id: "icon\(tab.rawValue)", in: namespace)
                                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    } else {
                                        Image(systemName: tab.systemImageName)
                                            .font(.system(size: iconSize))
                                            .foregroundColor(.secondary)
                                    }

                                    // ✅ Badge on reports tab
                                    if tab == .reports && notificationCount > 0 {
                                        ZStack {
                                            Circle()
                                                .fill(Color.red)
                                                .frame(width: 18, height: 18)

                                            Text("\(notificationCount)")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        .offset(x: 6, y: -6)
                                    }
                                }

                                Text(tab.title)
                                    .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .medium))
                                    .foregroundColor(selectedTab == tab ? .primary : .secondary)
                                    .offset(y: selectedTab == tab ? 2 : 0)
                            }
                            .frame(width: itemWidth, height: capsuleHeight)
                        }
                    }
                }
            }
        }
        .frame(height: 115)
    }

    private func bubbleOffset(width: CGFloat, itemWidth: CGFloat) -> CGFloat {
        let index = CGFloat(selectedTab.rawValue)
        return (itemWidth * index + itemWidth / 2) - width / 2
    }
}

// --------------------------------------------------
// MARK: - PATIENT DASHBOARD CONTENT (WITH API INTEGRATION)
// --------------------------------------------------
struct PatientDashboardContent: View {
    var pid: String
    @Binding var patientName: String
    @Binding var doctorReviewNotifications: [DoctorReviewNotification]
    @Binding var hasSeenNotification: Bool
    
    @State private var showHeader = false
    @State private var showCards = false
    @State private var lastReport: LastReport?
    @State private var isLoadingReport = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.teal.opacity(0.08), Color.blue.opacity(0.05), Color.cyan.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Welcome, \(patientName.isEmpty ? "Patient" : patientName) 👋")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.primary, .primary.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("Your Health, Our Priority.")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(colors: [Color.teal.opacity(0.15), Color.teal.opacity(0.08)],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                    )
                                    .frame(width: 56, height: 56)
                                    .scaleEffect(showHeader ? 1 : 0)

                                Image(systemName: "heart.text.square.fill")
                                    .font(.system(size: 26))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.teal, .teal.opacity(0.8)],
                                                       startPoint: .topLeading,
                                                       endPoint: .bottomTrailing)
                                    )
                                    .scaleEffect(showHeader ? 1 : 0)
                                    .rotationEffect(.degrees(showHeader ? 0 : -45))
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .scaleEffect(showHeader ? 1 : 0.8)
                    .opacity(showHeader ? 1 : 0)

                    // Upload Card
                    VStack(spacing: 16) {
                        NavigationLink(destination: UploadCTScanView()) {
                            EnhancedDashboardCard(
                                title: "Upload CT Scan",
                                icon: "arrow.up.doc.fill",
                                color: .teal,
                                showCard: $showCards
                            )
                        }
                        .buttonStyle(CardPressStyle())
                    }
                    .padding(.horizontal, 20)
                    .scaleEffect(showCards ? 1 : 0.9)
                    .opacity(showCards ? 1 : 0)

                    // Recent Report Summary
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.teal.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "chart.bar.doc.horizontal.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.teal)
                            }
                            Text("Last Report Summary")
                                .font(.system(size: 20, weight: .bold))
                            Spacer()
                        }

                        Divider()
                            .overlay(
                                LinearGradient(
                                    colors: [Color.teal.opacity(0.5), Color.teal.opacity(0.1)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 1.5)

                        VStack(spacing: 14) {
                            if let report = lastReport {
                                EnhancedReportRow(
                                    icon: "number.circle.fill",
                                    label: "Stone Count",
                                    value: "\(report.count)",
                                    color: .teal,
                                    index: 0
                                )
                                
                                EnhancedReportRow(
                                    icon: "ruler.fill",
                                    label: "Stone Sizes",
                                    value: report.size.isEmpty ? "N/A" : report.size.joined(separator: ", "),
                                    color: .teal,
                                    index: 1
                                )
                                
                                EnhancedReportRow(
                                    icon: "location.fill",
                                    label: "Locations",
                                    value: report.location.isEmpty ? "N/A" : report.location.joined(separator: ", "),
                                    color: .teal,
                                    index: 2
                                )
                            } else if isLoadingReport {
                                HStack(spacing: 12) {
                                    ProgressView()
                                        .tint(.teal)
                                    Text("Loading report...")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 15))
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                            } else if let error = errorMessage {
                                VStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.orange)
                                    Text(error)
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 14))
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 32))
                                        .foregroundColor(.gray)
                                    Text("No reports available")
                                        .foregroundColor(.secondary)
                                        .font(.system(size: 15))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                    )
                    .padding(.horizontal, 20)
                    .scaleEffect(showCards ? 1 : 0.9)
                    .opacity(showCards ? 1 : 0)

                    // Bottom padding for tab bar
                    Color.clear.frame(height: 100)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { showHeader = true }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) { showCards = true }
            fetchLastReport()
            fetchPatientName()
            
            if !hasSeenNotification {
                checkForDoctorReview()
            }
        }
    }
    
    // ✅ Fetch Patient Name
    private func fetchPatientName() {
        guard !pid.isEmpty else { return }
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/pprofile.php?pid=\(pid)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }
            
            if let status = json["status"] as? String, status == "success",
               let dataDict = json["data"] as? [String: Any] {
                DispatchQueue.main.async {
                    self.patientName = dataDict["name"] as? String ?? ""
                    print("✅ Patient name fetched: \(self.patientName)")
                }
            }
        }.resume()
    }

    // ✅ Check if any report has a doctor review
    private func checkForDoctorReview() {
        guard !pid.isEmpty else { return }
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/report.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["pid": pid]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                struct ReportItem: Codable {
                    let diagnosis_notes: String?
                    let created_at: String?
                }
                
                struct ReportCheck: Codable {
                    let history: [ReportItem]?
                }
                
                let decoded = try JSONDecoder().decode(ReportCheck.self, from: data)
                
                DispatchQueue.main.async {
                    if let reports = decoded.history {
                        for report in reports {
                            if let notes = report.diagnosis_notes,
                               !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                let notification = DoctorReviewNotification(
                                    message: "Your latest kidney stone analysis has been reviewed by a doctor.",
                                    timestamp: Date()
                                )
                                
                                if !self.doctorReviewNotifications.contains(where: { $0.message == notification.message }) {
                                    self.doctorReviewNotifications.append(notification)
                                    self.hasSeenNotification = true
                                }
                                
                                return
                            }
                        }
                    }
                }
            } catch {
                print("Error checking for doctor review: \(error.localizedDescription)")
            }
        }.resume()
    }

    // --------------------------------------------------
    // MARK: - FETCH LAST REPORT
    // --------------------------------------------------
    private func fetchLastReport() {
        guard !pid.isEmpty else {
            errorMessage = "Patient ID not found"
            return
        }
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/last_report.php") else {
            errorMessage = "Invalid API URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = ["pid": pid]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        isLoadingReport = true
        errorMessage = nil
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            defer { DispatchQueue.main.async { isLoadingReport = false } }
            
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Network error"
                    print("❌ API error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received"
                }
                return
            }
            
            // Debug: Print raw response
            if let jsonString = String(data: data, encoding: .utf8) {
                print("📥 API Response: \(jsonString)")
            }
            
            do {
                let decoded = try JSONDecoder().decode(LastReportResponse.self, from: data)
                DispatchQueue.main.async {
                    if decoded.success, let report = decoded.last_report {
                        self.lastReport = report
                        self.errorMessage = nil
                        print("✅ Report loaded - Count: \(report.count), Sizes: \(report.size), Locations: \(report.location)")
                    } else {
                        self.errorMessage = "No reports available"
                        print("⚠️ No reports found for PID: \(decoded.debug_pid_searched ?? "unknown")")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to parse report"
                    print("❌ Decode error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

// --------------------------------------------------
// MARK: - ENHANCED DASHBOARD CARD
// --------------------------------------------------
struct EnhancedDashboardCard: View {
    var title: String
    var icon: String
    var color: Color = .teal
    @Binding var showCard: Bool

    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 85, height: 85)
                    .scaleEffect(showCard ? 1 : 0.8)
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 75, height: 75)
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
            }

            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 180)
        .background(
            ZStack {
                LinearGradient(gradient: Gradient(colors: [color, color.opacity(0.75)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                GeometryReader { geometry in
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        path.move(to: CGPoint(x: width * 0.8, y: 0))
                        path.addCurve(to: CGPoint(x: width, y: height * 0.3),
                                      control1: CGPoint(x: width * 0.9, y: height * 0.1),
                                      control2: CGPoint(x: width, y: height * 0.2))
                        path.addLine(to: CGPoint(x: width, y: 0))
                        path.closeSubpath()
                    }.fill(Color.white.opacity(0.1))
                }
            }
        )
        .cornerRadius(24)
        .shadow(color: color.opacity(0.35), radius: 20, x: 0, y: 12)
    }
}

// --------------------------------------------------
// MARK: - CARD PRESS STYLE
// --------------------------------------------------
struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// --------------------------------------------------
// MARK: - ENHANCED REPORT ROW
// --------------------------------------------------
struct EnhancedReportRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let index: Int

    @State private var showRow = false

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [color.opacity(0.15), color.opacity(0.08)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 42, height: 42)

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            .scaleEffect(showRow ? 1 : 0.5)
            .rotationEffect(.degrees(showRow ? 0 : -180))

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            .offset(x: showRow ? 0 : -20)
            .opacity(showRow ? 1 : 0)

            Spacer()

            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 4, height: 30)
                .scaleEffect(y: showRow ? 1 : 0)
        }
        .padding(.vertical, 4)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(Double(index) * 0.1)) {
                showRow = true
            }
        }
    }
}
