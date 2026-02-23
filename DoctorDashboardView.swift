import SwiftUI

// MARK: - Enhanced Doctor Dashboard View with Modern UI/UX

struct DoctorDashboardView: View {
    @EnvironmentObject var profile: DoctorProfile
    @EnvironmentObject var patientsStore: PatientsStore
    @Binding var showSidebar: Bool
    @Binding var selectedTab: Int
    
    @State private var cases: [CaseItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @AppStorage("doctorName") var doctorName: String = ""
    @AppStorage("doctorDID") private var doctorDID: String = ""
    
    // ✅ Computed properties using diagnosisConfirmed
    var allCasesCount: Int {
        cases.count
    }
    
    var inReviewCasesCount: Int {
        cases.filter { $0.diagnosisConfirmed == 0 }.count
    }
    
    var completedCount: Int {
        cases.filter { $0.diagnosisConfirmed == 1 }.count
    }
    
    var inReviewCases: [CaseItem] {
        cases.filter { $0.diagnosisConfirmed == 0 }
    }
    
    var completedCases: [CaseItem] {
        cases.filter { $0.diagnosisConfirmed == 1 }
    }
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(UIColor { $0.userInterfaceStyle == .dark
                        ? UIColor(red: 0.08, green: 0.09, blue: 0.11, alpha: 1)
                        : UIColor(red: 0.97, green: 0.98, blue: 1.00, alpha: 1)
                    }),
                    Color(UIColor { $0.userInterfaceStyle == .dark
                        ? UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1)
                        : UIColor(red: 0.95, green: 0.97, blue: 0.99, alpha: 1)
                    })
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // MARK: - Enhanced Header
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            // Hamburger Menu
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    showSidebar = true
                                }
                            }) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .frame(width: 40, height: 40)
                                    .background(Color(.systemBackground).opacity(0.6))
                                    .cornerRadius(10)
                            }
                            
                            // Welcome Text
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Good morning,")
                                    .font(.system(.caption, design: .rounded))
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                
                                Text(doctorName.isEmpty ? "Doctor" : doctorName)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            // Stethoscope Icon Badge
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.teal.opacity(0.2),
                                                Color.blue.opacity(0.15)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                Image(systemName: "stethoscope")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.teal)
                            }
                            .frame(width: 48, height: 48)
                        }
                        .padding(16)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground).opacity(0.7))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(12)
                    
                    // MARK: - Content Area
                    if isLoading {
                        LoadingStateView()
                    } else if !errorMessage.isEmpty {
                        ErrorStateView(message: errorMessage) {
                            fetchPendingReviews()
                        }
                    } else if cases.isEmpty {
                        EmptyStateView()
                    } else {
                        // MARK: - Stats Cards
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                EnhancedStatCard(
                                    title: "All Cases",
                                    value: allCasesCount,
                                    icon: "folder.fill",
                                    color: .teal,
                                    gradient: LinearGradient(
                                        gradient: Gradient(colors: [Color.teal.opacity(0.2), Color.blue.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                
                                EnhancedStatCard(
                                    title: "In-review",
                                    value: inReviewCasesCount,
                                    icon: "hourglass.circle.fill",
                                    color: .orange,
                                    gradient: LinearGradient(
                                        gradient: Gradient(colors: [Color.orange.opacity(0.2), Color.red.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                
                                EnhancedStatCard(
                                    title: "Completed",
                                    value: completedCount,
                                    icon: "checkmark.circle.fill",
                                    color: .green,
                                    gradient: LinearGradient(
                                        gradient: Gradient(colors: [Color.green.opacity(0.2), Color.teal.opacity(0.1)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            }
                            .padding(12)
                        }
                        .padding(.top, 8)
                        
                        // MARK: - In-Review Cases Section
                        CaseSectionView(
                            title: "In-review Cases",
                            count: inReviewCasesCount,
                            isEmpty: inReviewCases.isEmpty,
                            emptyMessage: "No in-review cases",
                            emptyIcon: "checkmark.circle.fill",
                            emptyColor: .green,
                            cases: Array(inReviewCases.prefix(3))
                        )
                        
                        // MARK: - Completed Cases Section
                        CaseSectionView(
                            title: "Completed Cases",
                            count: completedCount,
                            isEmpty: completedCases.isEmpty,
                            emptyMessage: "No completed cases yet",
                            emptyIcon: "inbox",
                            emptyColor: .gray,
                            cases: Array(completedCases.prefix(3))
                        )
                        
                        Spacer(minLength: 20)
                    }
                }.padding(.bottom, 160)
            }
            .scrollIndicators(.hidden)
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
        .onAppear {
            if doctorDID.isEmpty {
                errorMessage = "Doctor ID not found. Please log in again."
            } else {
                print("🔑 Dashboard loaded for Doctor: \(doctorDID)")
                fetchPendingReviews()
            }
        }
    }
    
    // MARK: - Fetch Cases
    private func fetchPendingReviews() {
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/get_pending_reviews.php") else {
            errorMessage = "Invalid server URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        print("📤 Fetching cases for Doctor: \(doctorDID)")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Network error: \(error.localizedDescription)")
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }
                
                guard let data = data else {
                    print("❌ No data received")
                    self.errorMessage = "No data received from server"
                    self.isLoading = false
                    return
                }
                
                struct APIResponse: Codable {
                    let success: Bool
                    let cases: [CaseItem]?
                    let count: Int?
                }
                
                do {
                    let decoded = try JSONDecoder().decode(APIResponse.self, from: data)
                    if decoded.success {
                        self.cases = decoded.cases ?? []
                        print("✅ Loaded \(self.cases.count) cases for Doctor: \(self.doctorDID)")
                        
                        let inReviewCount = self.cases.filter { $0.diagnosisConfirmed == 0 }.count
                        let completedCount = self.cases.filter { $0.diagnosisConfirmed == 1 }.count
                        let unknownCount = self.cases.filter { $0.diagnosisConfirmed > 1 }.count
                        
                        print(" In-review (0): \(inReviewCount)")
                        print(" Completed (1): \(completedCount)")
                        print(" Other/Unknown: \(unknownCount)")
                        
                        if let firstCase = self.cases.first {
                            print(" 📋 Sample case: \(firstCase.patientName) - diagnosis_confirmed: \(firstCase.diagnosisConfirmed)")
                        }
                    } else {
                        self.cases = []
                        print("ℹ️ No cases found")
                    }
                    
                    self.isLoading = false
                } catch {
                    print("❌ JSON decode error: \(error.localizedDescription)")
                    self.errorMessage = "Failed to parse data"
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

// MARK: - Enhanced Stat Card Component
struct EnhancedStatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    let gradient: LinearGradient
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack {
                Text("\(value)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding(12)
        .background(gradient)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Case Section View Component
struct CaseSectionView: View {
    let title: String
    let count: Int
    let isEmpty: Bool
    let emptyMessage: String
    let emptyIcon: String
    let emptyColor: Color
    let cases: [CaseItem]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: isEmpty ? emptyIcon : "list.clipboard")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isEmpty ? emptyColor : .teal)
                    
                    Text(title)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                if !isEmpty {
                    ZStack {
                        Circle()
                            .fill(isEmpty ? emptyColor.opacity(0.1) : Color.teal.opacity(0.1))
                        
                        Text("\(count)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(isEmpty ? emptyColor : .teal)
                    }
                    .frame(width: 28, height: 28)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            if isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: emptyIcon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(emptyColor)
                    
                    Text(emptyMessage)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding(12)
                .background(emptyColor.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 12)
            } else {
                VStack(spacing: 8) {
                    ForEach(cases, id: \.id) { item in
                        NavigationLink {
                            CaseReviewView(caseItem: item)
                        } label: {
                            RecentCaseRow(caseItem: item)
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
            
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 0)
        .background(Color(.systemBackground).opacity(0.5))
        .cornerRadius(14)
        .padding(.horizontal, 12)
        .padding(.top, 8)
    }
}

// MARK: - Loading State View
struct LoadingStateView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.teal.opacity(0.2), lineWidth: 8)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.teal, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 70, height: 70)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            }
            
            VStack(spacing: 6) {
                Text("Loading cases...")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Please wait while we fetch your cases")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding(24)
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.orange)
            }
            
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            Button(action: retryAction) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .semibold))
                    
                    Text("Retry")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity)
                .padding(12)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.teal, Color.teal.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(color: Color.teal.opacity(0.3), radius: 6, x: 0, y: 2)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(24)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.1))
                    .frame(width: 90, height: 90)
                
                Image(systemName: "tray")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.teal)
            }
            
            VStack(spacing: 6) {
                Text("No pending reviews")
                    .font(.system(.headline, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("You're all caught up! Check back soon for new cases to review.")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxHeight: .infinity)
        .padding(24)
    }
}

// MARK: - Preview
#Preview {
    DoctorDashboardView(showSidebar: .constant(false), selectedTab: .constant(0))
        .environmentObject(DoctorProfile())
        .environmentObject(PatientsStore())
}
