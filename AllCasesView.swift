import SwiftUI

// MARK: - All Cases View with Enhanced UI/UX Design - FIXED LOOPING ISSUE - STAT CARDS AS NAVIGATION

struct AllCasesView: View {
    @State private var allCases: [CaseItem] = []
    @State private var inReviewCases: [CaseItem] = []
    @State private var completedCases: [CaseItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var doctorDID: String = ""
    @State private var selectedTab: CaseTab = .all
    
    // ✅ FIX: Add flag to prevent repeated fetches
    @State private var hasLoadedOnce = false
    
    enum CaseTab: String, CaseIterable {
        case all = "All"
        case inReview = "In-review"
        case completed = "Completed"
    }
    
    private var filteredCases: [CaseItem] {
        switch selectedTab {
        case .all:
            return allCases
        case .inReview:
            return inReviewCases
        case .completed:
            return completedCases
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background Gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor { $0.userInterfaceStyle == .dark
                            ? UIColor(red: 0.12, green: 0.13, blue: 0.15, alpha: 1)
                            : UIColor(red: 0.97, green: 0.98, blue: 0.99, alpha: 1)
                        }),
                        Color(UIColor { $0.userInterfaceStyle == .dark
                            ? UIColor(red: 0.15, green: 0.16, blue: 0.19, alpha: 1)
                            : UIColor(red: 0.95, green: 0.97, blue: 0.98, alpha: 1)
                        })
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // MARK: - Enhanced Header with Stats
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("All Cases")
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundColor(.primary)
                                
                                Text("Review and manage patient cases")
                                    .font(.system(.subheadline, design: .rounded))
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        
                        // ✅ STAT CARDS NOW WORK AS NAVIGATION FILTERS
                        HStack(spacing: 12) {
                            // All Cases Card (Clickable)
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = .all
                                }
                            }) {
                                StatsCard(
                                    label: "Total",
                                    value: allCases.count,
                                    icon: "chart.bar.fill",
                                    color: .blue,
                                    isSelected: selectedTab == .all
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // In-Review Cases Card (Clickable)
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = .inReview
                                }
                            }) {
                                StatsCard(
                                    label: "In-review",
                                    value: inReviewCases.count,
                                    icon: "hourglass.circle.fill",
                                    color: .orange,
                                    isSelected: selectedTab == .inReview
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // Completed Cases Card (Clickable)
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedTab = .completed
                                }
                            }) {
                                StatsCard(
                                    label: "Completed",
                                    value: completedCases.count,
                                    icon: "checkmark.circle.fill",
                                    color: .green,
                                    isSelected: selectedTab == .completed
                                )
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemBackground).opacity(0.5))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
                    )
                    .padding(12)
                    
                    // MARK: - Content Area with Proper State Management
                    ZStack {
                        if isLoading {
                            LoadingView()
                        } else if !errorMessage.isEmpty {
                            ErrorView(message: errorMessage) {
                                fetchCases()
                            }
                        } else if filteredCases.isEmpty {
                            EmptyCasesView(tab: selectedTab)
                        } else {
                            // Cases List with enhanced styling
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredCases, id: \.id) { caseItem in
                                        NavigationLink {
                                            CaseReviewView(caseItem: caseItem)
                                        } label: {
                                            RecentCaseRow(caseItem: caseItem)
                                                .transition(.opacity.combined(with: .scale))
                                        }
                                    }
                                }
                                .padding(12)
                                .padding(.bottom, 160)
                            }
                            .scrollIndicators(.hidden)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                            .refreshable {
                                await refreshCases()
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            // ✅ FIX: Only fetch once on initial load
            .onAppear {
                if !hasLoadedOnce {
                    hasLoadedOnce = true
                    fetchCases()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: - Helper Functions
    private func countForTab(_ tab: CaseTab) -> Int {
        switch tab {
        case .all: return allCases.count
        case .inReview: return inReviewCases.count
        case .completed: return completedCases.count
        }
    }
    
    // MARK: - Fetch & Categorize Cases
    private func fetchCases() {
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/get_pending_reviews.php") else {
            errorMessage = "Invalid server URL"
            isLoading = false
            return
        }
        
        print("📤 Fetching cases from: \(url)")
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Network Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    print("❌ No data received from server")
                    return
                }
                
                let rawResponse = String(data: data, encoding: .utf8) ?? "nil"
                print("📥 Raw Response: \(rawResponse)")
                
                struct APIResponse: Codable {
                    let success: Bool
                    let cases: [CaseItem]?
                }
                
                do {
                    let response = try JSONDecoder().decode(APIResponse.self, from: data)
                    guard let cases = response.cases else {
                        print("⚠️ No cases in response")
                        self.allCases = []
                        self.inReviewCases = []
                        self.completedCases = []
                        return
                    }
                    
                    print("\n📋 === CATEGORIZING CASES ===")
                    print("Total cases received: \(cases.count)")
                    
                    // ✅ Categorize by diagnosisConfirmed flag
                    self.allCases = cases
                    self.inReviewCases = cases.filter { caseItem in
                        let isInReview = caseItem.diagnosisConfirmed == 0
                        print(" Case: \(caseItem.patientName)")
                        print(" - diagnosisConfirmed: \(caseItem.diagnosisConfirmed)")
                        print(" - Status: \(caseItem.status)")
                        print(" - aiCount: \(caseItem.aiCount)") // ✅ Debug stone count
                        print(" - Category: \(isInReview ? "IN-REVIEW ⏳" : "COMPLETED ✅")")
                        return isInReview
                    }
                    
                    self.completedCases = cases.filter { caseItem in
                        caseItem.diagnosisConfirmed == 1
                    }
                    
                    print("\n✅ Categorization Complete:")
                    print(" - In-review (diagnosisConfirmed=0): \(self.inReviewCases.count)")
                    print(" - Completed (diagnosisConfirmed=1): \(self.completedCases.count)")
                    print("=" + String(repeating: "=", count: 39) + "\n")
                    
                } catch {
                    self.errorMessage = "Failed to parse data: \(error.localizedDescription)"
                    print("❌ Decode error: \(error)")
                }
            }
        }.resume()
    }
    
    private func refreshCases() async {
        return await withCheckedContinuation { continuation in
            fetchCases()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                continuation.resume()
            }
        }
    }
}

// MARK: - Enhanced Recent Case Row with Better Animations
struct RecentCaseRow: View {
    let caseItem: CaseItem
    @State private var isHovered = false
    
    var statusBadge: (label: String, color: Color, icon: String) {
        if caseItem.diagnosisConfirmed == 1 {
            return (label: "Completed", color: .green, icon: "checkmark.circle.fill")
        } else {
            return (label: "In-review", color: .orange, icon: "hourglass")
        }
    }
    
    // Helper to format stone sizes for display
    var formattedStoneSizes: String {
        guard !caseItem.stoneSizes.isEmpty else { return "—" }
        
        // Format each size (remove "mm" and keep only number with 1 decimal)
        let formattedSizes = caseItem.stoneSizes.map { sizeString in
            // Remove "mm" and trim
            let cleanSize = sizeString.replacingOccurrences(of: "mm", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Convert to Double and format with 1 decimal
            if let size = Double(cleanSize) {
                return String(format: "%.1f", size)
            }
            return cleanSize
        }
        
        // Join with comma or show first 2 sizes if many
        if formattedSizes.count <= 3 {
            return formattedSizes.joined(separator: ", ") + " mm"
        } else {
            let firstTwo = Array(formattedSizes.prefix(2))
            return firstTwo.joined(separator: ", ") + " mm (+\(formattedSizes.count - 2) more)"
        }
    }
    
    // Helper to get the largest stone size
    var largestStoneSize: String {
        guard !caseItem.stoneSizes.isEmpty else { return "—" }
        
        var maxSize: Double = 0
        for sizeString in caseItem.stoneSizes {
            let cleanSize = sizeString.replacingOccurrences(of: "mm", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let size = Double(cleanSize), size > maxSize {
                maxSize = size
            }
        }
        
        return String(format: "%.1f mm", maxSize)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Section with gradient background
            HStack(spacing: 12) {
                // Avatar Placeholder with animation
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.teal.opacity(0.2),
                                    Color.blue.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.teal)
                }
                .frame(width: 48, height: 48)
                .scaleEffect(isHovered ? 1.05 : 1.0)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(caseItem.patientName)
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        
                        Text("ID: \(caseItem.id)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                // Status Badge with enhanced styling
                HStack(spacing: 6) {
                    Image(systemName: statusBadge.icon)
                        .font(.system(size: 11, weight: .bold))
                    
                    Text(statusBadge.label)
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(statusBadge.color.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(statusBadge.color.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(statusBadge.color)
            }
            .padding(12)
            
            // Divider
            Divider()
                .padding(.horizontal, 12)
            
            // Details Section - Enhanced Grid
            VStack(spacing: 12) {
                // Row 1: Age, Gender, AI Score
                HStack(spacing: 12) {
                    DetailBox(
                        icon: "calendar",
                        label: "Age",
                        value: "\(caseItem.age)",
                        color: .blue
                    )
                    
                    DetailBox(
                        icon: "person.fill",
                        label: "Gender",
                        value: caseItem.gender,
                        color: .purple
                    )
                    
                    DetailBox(
                        icon: "sparkles",
                        label: "AI Score",
                        value: "\(caseItem.aiScore)%",
                        color: .teal
                    )
                }
                
                // Row 2: Stone Detection - UPDATED FOR MULTIPLE STONES
                HStack(spacing: 12) {
                    if caseItem.aiDetected {
                        DetectionBox(
                            icon: "checkmark.circle.fill",
                            text: "Stone Found",
                            color: .green
                        )
                        
                        // ✅ Display largest stone size
                        DetectionBox(
                            icon: "ruler",
                            text: largestStoneSize,
                            color: .teal
                        )
                        
                        // ✅ Display stone count
                        DetectionBox(
                            icon: "number.circle.fill",
                            text: "\(caseItem.stoneCount) stones",
                            color: .orange
                        )
                    } else {
                        DetectionBox(
                            icon: "xmark.circle.fill",
                            text: "No Stone Detected",
                            color: .red
                        )
                        
                        Spacer()
                    }
                }
                
                // Row 3: Stone Sizes Summary (if multiple stones)
                if caseItem.stoneCount > 1 {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.grid.2x2.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.blue)
                        
                        Text("Sizes: \(formattedStoneSizes)")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // Row 4: Location (only if stones detected)
                if caseItem.aiDetected && !caseItem.stoneLocations.isEmpty {
                    // Get unique locations or first location
                    let uniqueLocations = Array(Set(caseItem.stoneLocations))
                    let locationText = uniqueLocations.count == 1 ?
                        uniqueLocations[0] :
                        "\(uniqueLocations.count) locations"
                    
                    DetectionBox(
                        icon: "mappin.circle.fill",
                        text: locationText,
                        color: .purple
                    )
                }
                
                // Row 5: Diagnosis Status
                if caseItem.diagnosisConfirmed == 1 {
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.green)
                        
                        Text("Result submitted")
                            .font(.system(.caption, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .onHover { hovered in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovered
            }
        }
    }
}

// MARK: - Detail Box Component
struct DetailBox: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - Detection Box Component
struct DetectionBox: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .semibold))
            
            Text(text)
                .font(.system(.caption, design: .rounded))
                .fontWeight(.medium)
        }
        .foregroundColor(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(color.opacity(0.15))
        .cornerRadius(8)
    }
}

// MARK: - Stat Card Component (NOW CLICKABLE FOR NAVIGATION)
struct StatsCard: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color
    let isSelected: Bool
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            
            HStack {
                Text("\(value)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ?
                    LinearGradient(
                        gradient: Gradient(colors: [color, color.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        gradient: Gradient(colors: [color.opacity(0.1), color.opacity(0.05)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? color : color.opacity(0.2), lineWidth: isSelected ? 2 : 1)
        )
        .foregroundColor(isSelected ? .white : .primary)
        .shadow(color: isSelected ? color.opacity(0.3) : .clear, radius: 6, x: 0, y: 2)
        .scaleEffect(isAnimating ? 1.05 : 1.0)
        .onAppear {
            if isSelected {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    isAnimating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                        isAnimating = false
                    }
                }
            }
        }
    }
}

// MARK: - Loading View with Enhanced Animation
struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .stroke(Color.teal.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)
                
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.teal, Color.blue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            }
            .shadow(color: Color.teal.opacity(0.3), radius: 8, x: 0, y: 2)
            
            VStack(spacing: 6) {
                Text("Loading cases...")
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Please wait while we fetch your cases")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.secondary)
            }
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

// MARK: - Empty Cases View
struct EmptyCasesView: View {
    let tab: AllCasesView.CaseTab
    @State private var isAnimating = false
    
    var imageName: String {
        switch tab {
        case .all: return "tray"
        case .inReview: return "hourglass"
        case .completed: return "checkmark.circle"
        }
    }
    
    var title: String {
        switch tab {
        case .all: return "No cases yet"
        case .inReview: return "No in-review cases"
        case .completed: return "No completed cases"
        }
    }
    
    var subtitle: String {
        switch tab {
        case .all: return "Cases will appear here when available."
        case .inReview: return "All cases have been reviewed."
        case .completed: return "No cases have been completed yet."
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.teal.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: imageName)
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(.teal)
            }
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            
            Text(title)
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .frame(maxHeight: .infinity)
        .padding(24)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundColor(.orange)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            
            VStack(spacing: 8) {
                Text("Something went wrong")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(message)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                withAnimation(.spring()) {
                    retryAction()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14, weight: .semibold))
                    
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
                .scaleEffect(isPressed ? 0.95 : 1.0)
                .onLongPressGesture(minimumDuration: 0.01, perform: {}, onPressingChanged: { isPressing in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = isPressing
                    }
                })
            }
        }
        .frame(maxHeight: .infinity)
        .padding(24)
    }
}

// MARK: - Preview
#Preview {
    AllCasesView()
}
