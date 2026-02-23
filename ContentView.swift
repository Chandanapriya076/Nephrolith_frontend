import SwiftUI

struct ContentView: View {
    @AppStorage("doctorDID") private var doctorDID: String = ""
    @AppStorage("patientPID") private var patientPID: String = ""
    @State private var showLogoScreen = true
    
    var body: some View {
        ZStack {
            // ✅ Check persistent login sessions
            if !doctorDID.isEmpty {
                // Doctor is logged in
                DoctorAppRootView()
            } else if !patientPID.isEmpty {
                // Patient is logged in
                PatientAppRootView()
            } else {
                // No one logged in
                if showLogoScreen {
                    LogoScreen()
                        .transition(.opacity)
                } else {
                    NavigationStack {
                        UserSelectionView()
                    }
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            // Show logo for 2 seconds, then transition to UserSelectionView
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showLogoScreen = false
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
