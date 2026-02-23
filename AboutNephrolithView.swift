import SwiftUI

struct AboutNephrolithView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "heart.text.square.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.top, 8)
                    
                    Text("About Nephrolith")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    
                    Text("Academic Research Application")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
                
                // About Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About")
                        .font(.title2.bold())
                    
                    Text("This app is an academic student research project developed for educational purposes. It is not a medical device and does not provide medical diagnosis, treatment, or clinical advice. Always consult qualified healthcare professionals for medical decisions.")
                        .font(.body)
                        .lineSpacing(4)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Educational & research purposes only", systemImage: "book.closed.fill")
                        Label("Not for medical diagnosis or treatment", systemImage: "stethoscope.slash")
                        Label("Consult healthcare professionals for medical decisions", systemImage: "person.badge.shield.checkmark.fill")
                    }
                    .font(.subheadline)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.vertical, 8)
                    
                    Text("This application is part of ongoing academic research in nephrology and kidney health awareness.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Features Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("App Features")
                        .font(.title2.bold())
                    
                    ForEach(features, id: \.self) { feature in
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                                .padding(.top, 2)
                            
                            Text(feature)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                
                Divider()
                
                // Version & Info Section
                VStack(alignment: .center, spacing: 8) {
                    Text("Version 1.0")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("©2025 Nephrolith")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                
                // Disclaimer
                VStack(alignment: .center, spacing: 4) {
                    Text("For research and educational use only")
                        .font(.caption2)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private let features = [
        "Kidney health research support",
        "Educational image analysis tools",
        "Academic appointment coordination",
        "Health awareness guidance",
        "Research data collection",
        "Educational resources"
    ]
}

// MARK: - Preview
struct AboutNephrolithView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AboutNephrolithView()
        }
    }
}
