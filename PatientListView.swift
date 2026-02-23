import SwiftUI

struct PatientListView: View {
    @AppStorage("doctorDID") private var doctorDID: String = ""
    @State private var patients: [CaseItem] = []
    @State private var isLoading = true
    @State private var errorMessage = ""

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading cases...")
                    .scaleEffect(1.2)
            } else if !errorMessage.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title)
                        .foregroundColor(.red)
                    Text("Error")
                        .font(.headline)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                    Button("Retry") {
                        fetchPatients()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else if patients.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.crop.circle.badge.questionmark")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No cases assigned")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
            } else {
                List(patients) { patient in
                    NavigationLink {
                        // ✅ FIXED: No doctorDID parameter needed
                        CaseReviewView(caseItem: patient)
                    } label: {
                        PatientRow(patient: patient)
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Assigned Cases")
        .onAppear {
            print("📋 PatientListView appeared - Doctor DID: \(doctorDID)")
            fetchPatients()
        }
    }

    func fetchPatients() {
        isLoading = true
        errorMessage = ""
        
        guard let url = URL(string: "http://14.139.187.229:8081/oct/renal/get_cases.php") else {
            errorMessage = "Invalid server URL"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["doctor_id": doctorDID]
        request.httpBody = try? JSONEncoder().encode(body)

        print("📤 Fetching cases for Doctor: \(doctorDID)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("❌ Error:", error)
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received"
                    print("❌ No data")
                    return
                }

                if let rawResponse = String(data: data, encoding: .utf8) {
                    print("📥 Cases API Response:", rawResponse)
                }

                do {
                    let decoded = try JSONDecoder().decode([String: [CaseItem]].self, from: data)
                    self.patients = decoded["cases"] ?? []
                    print("✅ Loaded \(self.patients.count) cases")
                } catch {
                    self.errorMessage = "Failed to parse response"
                    print("❌ Decode error:", error)
                }
            }
        }.resume()
    }
}

// MARK: - Patient Row Component
struct PatientRow: View {
    let patient: CaseItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.patientName)
                        .font(.headline)
                        .fontWeight(.semibold)
                   
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(patient.status)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor(patient.status))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }

    func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "pending": return .orange
        case "completed": return .green
        case "in-review": return .blue
        default: return .gray
        }
    }
}

// MARK: - Preview
#Preview {
 
        PatientListView()
    
}
