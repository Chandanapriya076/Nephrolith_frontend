import SwiftUI

// MARK: - Case Item Model (Updated to match backend response EXACTLY)
struct CaseItem: Identifiable, Codable {
    let id: String
    let patientEmail: String
    let patientName: String
    let age: Int
    let gender: String
    let doctor: String
    let stoneCount: Int
    let stoneSizes: [String]
    let stoneLocations: [String]
    let image: String  // Base64 URL format
    let pid: String
    let diagnosisNotes: String
    let diagnosisConfirmed: Int  // 0 = in-review, 1 = completed
    
    // MARK: - Manual Initializer
    init(
        id: String,
        patientEmail: String,
        patientName: String,
        age: Int,
        gender: String,
        doctor: String,
        stoneCount: Int,
        stoneSizes: [String],
        stoneLocations: [String],
        image: String,
        pid: String,
        diagnosisNotes: String,
        diagnosisConfirmed: Int
    ) {
        self.id = id
        self.patientEmail = patientEmail
        self.patientName = patientName
        self.age = age
        self.gender = gender
        self.doctor = doctor
        self.stoneCount = stoneCount
        self.stoneSizes = stoneSizes
        self.stoneLocations = stoneLocations
        self.image = image
        self.pid = pid
        self.diagnosisNotes = diagnosisNotes
        self.diagnosisConfirmed = diagnosisConfirmed
    }
    
    // Computed properties for UI compatibility
    var uploadedOn: Double {
        // You can add a timestamp field to your backend if needed
        return Date().timeIntervalSince1970
    }
    
    var status: String {
        return diagnosisConfirmed == 1 ? "completed" : "pending"
    }
    
    var ctImageName: String {
        return image.isEmpty ? "" : "CT Scan Image"
    }
    
    var aiDetected: Bool {
        return stoneCount > 0
    }
    
    // In your CaseItem struct, update the aiSizeMM computed property:
    var aiSizeMM: Double {
        guard !stoneSizes.isEmpty else { return 0 }
        
        // Get the largest stone size
        var maxSize: Double = 0
        for sizeString in stoneSizes {
            let cleanSize = sizeString.replacingOccurrences(of: "mm", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let size = Double(cleanSize), size > maxSize {
                maxSize = size
            }
        }
        
        return maxSize
    }

    // Add a computed property for average stone size
    var averageStoneSize: Double {
        guard !stoneSizes.isEmpty else { return 0 }
        
        var totalSize: Double = 0
        var validCount: Int = 0
        
        for sizeString in stoneSizes {
            let cleanSize = sizeString.replacingOccurrences(of: "mm", with: "", options: .caseInsensitive)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let size = Double(cleanSize) {
                totalSize += size
                validCount += 1
            }
        }
        
        return validCount > 0 ? totalSize / Double(validCount) : 0
    }
    
    var aiLocation: String {
        guard !stoneLocations.isEmpty else { return "Not specified" }
        return stoneLocations[0]
    }
    
    var aiCount: Int {
        return stoneCount
    }
    
    // MARK: - Computed Properties for URL Handling
    var fullImageUrl: String {
        if image.hasPrefix("http") {
            return image
        } else {
            return "http://14.139.187.229:8081/oct/renal/\(image)"
        }
    }
    
    var fullAnnotatedImageUrl: String {
        if annotatedImage.hasPrefix("http") {
            return annotatedImage
        } else {
            return "http://14.139.187.229:8081/oct/renal/\(annotatedImage)"
        }
    }

    var aiScore: Int {
        // Calculate based on stone count
        let baseScore = 85
        let stoneBonus = min(stoneCount * 3, 14)
        return min(baseScore + stoneBonus, 99)
    }
    
    var reportFilename: String {
        return "Report_\(patientName)_\(id).pdf"
    }
    
    var sentToDoctorAt: Double? {
        return diagnosisConfirmed == 1 ? Date().timeIntervalSince1970 : nil
    }
    
    var annotatedImage: String {
        return image // Same as image for now
    }
    
    // MARK: - Custom Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case patientEmail
        case patientName
        case age
        case gender
        case doctor
        case stoneCount
        case stoneSizes
        case stoneLocations
        case image
        case pid
        case diagnosisNotes
        case diagnosisConfirmed
    }
    
    // MARK: - Initialization from JSON
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        patientEmail = try container.decode(String.self, forKey: .patientEmail)
        patientName = try container.decode(String.self, forKey: .patientName)
        age = try container.decode(Int.self, forKey: .age)
        gender = try container.decode(String.self, forKey: .gender)
        doctor = try container.decode(String.self, forKey: .doctor)
        stoneCount = try container.decode(Int.self, forKey: .stoneCount)
        stoneSizes = try container.decode([String].self, forKey: .stoneSizes)
        stoneLocations = try container.decode([String].self, forKey: .stoneLocations)
        image = try container.decode(String.self, forKey: .image)
        pid = try container.decode(String.self, forKey: .pid)
        diagnosisNotes = try container.decode(String.self, forKey: .diagnosisNotes)
        diagnosisConfirmed = try container.decode(Int.self, forKey: .diagnosisConfirmed)
    }
    
    // MARK: - Encode function
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(patientEmail, forKey: .patientEmail)
        try container.encode(patientName, forKey: .patientName)
        try container.encode(age, forKey: .age)
        try container.encode(gender, forKey: .gender)
        try container.encode(doctor, forKey: .doctor)
        try container.encode(stoneCount, forKey: .stoneCount)
        try container.encode(stoneSizes, forKey: .stoneSizes)
        try container.encode(stoneLocations, forKey: .stoneLocations)
        try container.encode(image, forKey: .image)
        try container.encode(pid, forKey: .pid)
        try container.encode(diagnosisNotes, forKey: .diagnosisNotes)
        try container.encode(diagnosisConfirmed, forKey: .diagnosisConfirmed)
    }
}

// MARK: - Extension for creating updated diagnosis
extension CaseItem {
    // Method to create a copy with updated diagnosis
    func withUpdatedDiagnosis(notes: String, confirmed: Int) -> CaseItem {
        return CaseItem(
            id: self.id,
            patientEmail: self.patientEmail,
            patientName: self.patientName,
            age: self.age,
            gender: self.gender,
            doctor: self.doctor,
            stoneCount: self.stoneCount,
            stoneSizes: self.stoneSizes,
            stoneLocations: self.stoneLocations,
            image: self.image,
            pid: self.pid,
            diagnosisNotes: notes,
            diagnosisConfirmed: confirmed
        )
    }
    
    var uniqueStoneLocations: [String] {
        return Array(Set(stoneLocations))
    }
    
    var stoneDetails: [(index: Int, size: String, location: String)] {
        var details: [(Int, String, String)] = []
        for i in 0..<min(stoneSizes.count, stoneLocations.count) {
            details.append((i + 1, stoneSizes[i], stoneLocations[i]))
        }
        return details
    }
}

// MARK: - Patients Store
class PatientsStore: ObservableObject {
    @Published var selectedPatients: [CaseItem] = []
    @Published var currentDoctorDID: String = ""
}

// MARK: - Doctor Profile
class DoctorProfile: ObservableObject {
    @Published var did: String = ""
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var gender: String = "Male"
    @Published var specialization: String = ""
    @Published var hospital: String = ""
    @Published var phone: String = ""
    @Published var originalData: [String: Any] = [:]
    
    func hasChanges() -> Bool {
        return name != (originalData["name"] as? String ?? "") ||
               email != (originalData["email"] as? String ?? "") ||
               gender != (originalData["gender"] as? String ?? "") ||
               specialization != (originalData["specialization"] as? String ?? "") ||
               hospital != (originalData["hospital"] as? String ?? "") ||
               phone != (originalData["phone"] as? String ?? "")
    }
    
    func saveOriginalData() {
        originalData = [
            "name": name,
            "email": email,
            "gender": gender,
            "specialization": specialization,
            "hospital": hospital,
            "phone": phone
        ]
    }
}
