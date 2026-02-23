import SwiftUI

// MARK: - Updated API responses to match PHP format
struct ReportsResponse: Codable {
    let status: String
    let pid: String
    let count: Int
    let history: [Report]
}

// MARK: - Report model that matches PHP response EXACTLY
struct Report: Identifiable, Codable {
    let id: Int
    let doctor: String
    let stone_count: String
    let stone_sizes: String
    let stone_locations: String
    let image: String
    let pid: String
    let diagnosis_notes: String?
    let diagnosis_confirmed: String?
    
    // Computed properties for easier access
    var stoneCountInt: Int {
        Int(stone_count) ?? 0
    }
    
    var stoneSizesArray: [String] {
        stone_sizes.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    var stoneLocationsArray: [String] {
        stone_locations.components(separatedBy: ", ").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    var fullImageUrl: String {
        if image.hasPrefix("http") {
            return image
        } else {
            return "http://14.139.187.229:8081/oct/renal/\(image)"
        }
    }
}

// MARK: - Reports History View (Main Entry Point)
struct ReportsHistoryView: View {
    @AppStorage("patientPID") var patientPID: String = ""
    @AppStorage("patientName") var patientName: String = ""
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Medical Reports")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("Patient: \(patientName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            
            ReportsHistoryContent(pid: patientPID)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Reports History Content
struct ReportsHistoryContent: View {
    let pid: String
    
    @State private var reports: [Report] = []
    @State private var offlineReports: [Report] = []
    @State private var isLoading = true
    @State private var errorMessage = ""
    @State private var selectedTab = 0
    @State private var rawResponseText = ""
    
    @AppStorage("patientPID") var patientPID: String = ""
    
    var body: some View {
        VStack {
            if !offlineReports.isEmpty {
                Picker("Report Type", selection: $selectedTab) {
                    Text("Server Reports").tag(0)
                    Text("Offline Reports (\(offlineReports.count))").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
            }
            
            if isLoading {
                ProgressView("Loading Reports...")
                    .scaleEffect(1.2)
                    .padding()
                
            } else if !errorMessage.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.red)
                    
                    Text("Error")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    
                    // Debug view
                    if !rawResponseText.isEmpty {
                        VStack(alignment: .leading) {
                            Text("Debug - Raw Response:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ScrollView {
                                Text(rawResponseText)
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .padding()
                                    .background(Color.black.opacity(0.05))
                                    .cornerRadius(8)
                            }
                            .frame(height: 120)
                        }
                        .padding()
                    }
                    
                    Button("Retry") {
                        fetchReports()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.teal)
                    .controlSize(.large)
                }
                .padding()
                
            } else if selectedTab == 0 {
                if reports.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No reports found")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Medical reports will appear here once available.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(reports) { report in
                        NavigationLink(destination: ReportDetailView(report: report)) {
                            ReportRowView(report: report)
                        }
                    }
                    .listStyle(.plain)
                }
                
            } else {
                if offlineReports.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "iphone.and.arrow.forward")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No offline reports")
                            .font(.title2)
                            .foregroundColor(.gray)
                        
                        Text("Offline analysis results will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List(offlineReports) { report in
                        NavigationLink(destination: ReportDetailView(report: report)) {
                            ReportRowView(report: report)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
        .navigationTitle("Medical Reports")
        .onAppear {
            fetchReports()
        }
    }
    
    // MARK: - Network API Call
    func fetchReports() {
        print("\n🔄 Starting fetchReports()...")
        
        guard !patientPID.isEmpty else {
            errorMessage = "No patient ID found. Please log in again."
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = ""
        rawResponseText = ""
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/gethistory.php") else {
            errorMessage = "Invalid server URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        
        let body: [String: String] = ["pid": patientPID]
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
            print("📤 Request body: \(body)")
        } catch {
            errorMessage = "Request preparation failed"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No response received"
                    return
                }
                
                // Save raw response for debugging
                self.rawResponseText = String(data: data, encoding: .utf8) ?? "Could not decode response"
                print("📥 Raw response: \(self.rawResponseText)")
                
                // Debug: Print first 500 characters of response
                let preview = String(self.rawResponseText.prefix(500))
                print("📥 Response preview: \(preview)")
                
                do {
                    // Try to decode the response
                    let decodedResponse = try JSONDecoder().decode(ReportsResponse.self, from: data)
                    
                    if decodedResponse.status == "success" {
                        self.reports = decodedResponse.history
                        print("✅ Successfully loaded \(self.reports.count) reports")
                        print("✅ PID searched: \(decodedResponse.pid)")
                    } else {
                        self.errorMessage = "Server returned error status"
                    }
                } catch let decodingError {
                    self.errorMessage = "Failed to parse server response"
                    print("❌ Decoding error: \(decodingError)")
                    
                    // Try to get more specific error
                    if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        if let errorMsg = json["message"] as? String {
                            self.errorMessage = errorMsg
                        }
                        print("📊 JSON object: \(json)")
                    }
                }
            }
        }.resume()
    }
}

// MARK: - Report Row View
struct ReportRowView: View {
    let report: Report
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Kidney Stone Analysis")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Doctor: \(report.doctor)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Status badge
                Text("Completed")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(20)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PID: \(String(report.pid.prefix(6)))...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.red)
                    
                    Text("\(report.stoneCountInt) stone(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Doctor Review Badge
            if let diagnosis = report.diagnosis_notes, !diagnosis.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(.green)
                    
                    Text("Doctor Review: \(diagnosis)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.12))
                .cornerRadius(8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
    }
}

// MARK: - Report Detail View
struct ReportDetailView: View {
    let report: Report
    @State private var imageLoadError = false
    @State private var showGlobalCitation = true
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                
                
                if !imageLoadError {
                    imageSection
                }
                
                detailsSection
                
                if let diagnosis = report.diagnosis_notes, !diagnosis.isEmpty {
                    doctorReviewSection(diagnosis: diagnosis)
                }
                
            }
            .padding()
        }
        .navigationTitle("Report Detail")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title
            Text("AI Kidney Stone Analysis")
                .font(.title2)
                .fontWeight(.bold)
            
            // Citation button with popover
            HStack {
                        Link(destination: URL(string: "https://www.niddk.nih.gov/health-information/urologic-diseases/kidney-stones")!) {
                            Image(systemName: "doc.fill")
                                .foregroundColor(.blue)
                                .font(.title3)
                            Text("Citation link")
                                .foregroundColor(.black)
                                .font(.title3)
                            
                        }
                        
                        Spacer()
                    }
            
            // Patient Info
            VStack(alignment: .leading, spacing: 4) {
                Text("Patient ID: \(report.pid)")
                    .font(.body)
                
                Text("Doctor: \(report.doctor)")
                    .font(.body)
                    .foregroundColor(.primary)
            }
            
            Divider()
        }
    }

    // MARK: - Supporting Views
    private var citationPopoverContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Source Citation")
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white)
            
            Text("EAU/AUA Urolithiasis Guidelines 2025")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.9))
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.black.opacity(0.85))
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .padding(16)
    }
    
    private var imageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Medical Scan")
                .font(.headline)
            
            AsyncImage(url: URL(string: report.fullImageUrl)) { phase in
                Group {
                    switch phase {
                    case .empty:
                        VStack {
                            ProgressView()
                                .scaleEffect(1.2)
                            Text("Loading scan image...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                        }
                        .frame(height: 240)
                    
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    case .failure:
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text("Scan image unavailable")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("URL: \(report.fullImageUrl)")
                                .font(.caption2)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(height: 200)
                        .onAppear { imageLoadError = true }
                    
                    @unknown default:
                        ProgressView()
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .background(Color(.systemGray6))
            .cornerRadius(16)
        }
    }
    
    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analysis Results")
                .font(.headline)
            
            DetailCard {
                VStack(spacing: 16) {
                    DetailRow(label: "Stone Count", value: "\(report.stoneCountInt)")
                    
                    if !report.stoneSizesArray.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Stone Sizes")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(Array(report.stoneSizesArray.enumerated()), id: \.offset) { index, size in
                                HStack {
                                    Text("• \(size)")
                                        .font(.body)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    if !report.stoneLocationsArray.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Locations")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(Array(report.stoneLocationsArray.enumerated()), id: \.offset) { index, location in
                                HStack {
                                    Text("• \(location)")
                                        .font(.body)
                                    Spacer()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func doctorReviewSection(diagnosis: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Doctor Review")
                .font(.headline)
            
            DetailCard {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "stethoscope.circle.fill")
                            .foregroundColor(.blue)
                        
                        Text("Review")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    Text(diagnosis)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.leading, 8)
                    
                    if let confirmed = report.diagnosis_confirmed, !confirmed.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.green)
                            
                            Text(confirmed)
                                .font(.caption)
                                .foregroundColor(.green)
                                .fontWeight(.medium)
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                }
            }
        }
    }
}

// MARK: - Helper Views
struct DetailCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.medium)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .foregroundColor(.primary)
                .fontWeight(.semibold)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        ReportsHistoryView()
    }
}
