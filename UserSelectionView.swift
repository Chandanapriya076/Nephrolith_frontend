import SwiftUI

struct UserSelectionView: View {
    @State private var isAppReady = false
    @State private var showContent = false
    @State private var selectedTab: Int? = nil
    @State private var pulseAnimation = false
    @State private var floatAnimation = false
    
    // ✅ PERSISTENT DOCTOR SESSION
    @AppStorage("doctorDID") private var doctorDID: String = ""
    
    // ✅ PERSISTENT PATIENT SESSION
    @AppStorage("patientPID") private var patientPID: String = ""

    var body: some View {
        ZStack {
            // ✅ PREMIUM GRADIENT BACKGROUND
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(red: 0.0, green: 0.48, blue: 0.58), location: 0.0),
                    .init(color: Color(red: 0.0, green: 0.65, blue: 0.75), location: 0.5),
                    .init(color: Color(red: 0.1, green: 0.72, blue: 0.82), location: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // ✅ ANIMATED FLOATING BACKGROUND ELEMENTS
            VStack {
                HStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ]),
                                center: .center,
                                startRadius: 0,        // ✅ required
                                endRadius: 100         // ✅ required
                            )
                        )

                        .frame(width: 250, height: 250)
                        .offset(x: -120, y: floatAnimation ? -30 : 30)
                        .animation(
                            Animation.easeInOut(duration: 4)
                                .repeatForever(autoreverses: true),
                            value: floatAnimation
                        )
                    Spacer()
                }
                .frame(height: 200)
                
                Spacer()
                
                HStack {
                    Spacer()
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.0)
                                ]),
                                center: .center,
                                startRadius: 0,        // ✅ required
                                endRadius: 80
                            )
                        )
                        .frame(width: 200, height: 200)
                        .offset(x: 100, y: floatAnimation ? 40 : -40)
                        .animation(
                            Animation.easeInOut(duration: 5)
                                .repeatForever(autoreverses: true),
                            value: floatAnimation
                        )
                }
            }
            .ignoresSafeArea()
            
            if !isAppReady {
                // ✅ ENHANCED LOADING SCREEN WITH PULSE
                VStack(spacing: 24) {
                    ZStack {
                        // Outer pulsing ring
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 100, height: 100)
                            .scaleEffect(pulseAnimation ? 1.3 : 1.0)
                            .opacity(pulseAnimation ? 0 : 1)
                            .animation(
                                Animation.easeOut(duration: 1.5)
                                    .repeatForever(autoreverses: false),
                                value: pulseAnimation
                            )
                        
                        // Middle ring
                        Circle()
                            .stroke(Color.white.opacity(0.5), lineWidth: 3)
                            .frame(width: 90, height: 90)
                        
                        // Rotating spinner
                        Circle()
                            .trim(from: 0, to: 0.75)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white.opacity(0.3)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 4
                            )
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(showContent ? 360 : 0))
                            .animation(
                                Animation.linear(duration: 1.8)
                                    .repeatForever(autoreverses: false),
                                value: showContent
                            )
                    }
                    
                    VStack(spacing: 8) {
                        Text("Initializing System")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Text("Preparing your medical records...")
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .onAppear {
                    pulseAnimation = true
                    showContent = true
                    initializeApp()
                }
            } else {
                // ✅ ENHANCED SELECTION SCREEN
                selectionScreen
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Enhanced Selection Screen UI
    var selectionScreen: some View {
        VStack(spacing: 0) {
            // ✅ PREMIUM HEADER WITH ANIMATIONS
            VStack(spacing: 20) {
                ZStack {
                    // Animated background glow
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 160, height: 160)
                        .scaleEffect(showContent ? 1.0 : 0.6)
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.8, dampingFraction: 0.6), value: showContent)
                    
                    // Kidney icon with shadow
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                        .foregroundColor(.white)
                        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                        .scaleEffect(showContent ? 1.0 : 0.5)
                        .rotationEffect(.degrees(showContent ? 0 : -20))
                        .opacity(showContent ? 1 : 0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.65), value: showContent)
                }
                .frame(height: 180)
                
                VStack(spacing: 8) {
                    Text("NEPHROLITH")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("AI Review System")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                        .letterSpacing(0.3)
                }
                .offset(y: showContent ? 0 : 30)
                .opacity(showContent ? 1 : 0)
                .animation(.easeOut(duration: 0.7).delay(0.2), value: showContent)
            }
            .padding(.top, 50)
            .padding(.bottom, 40)

            Spacer()

            // ✅ PREMIUM PORTAL BUTTONS
            VStack(spacing: 18) {
                // Doctor Portal Button
                NavigationLink(destination: DoctorLoginView()) {
                    ZStack {
                        // Background with gradient
                        RoundedRectangle(cornerRadius: 22)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white,
                                        Color.white.opacity(0.95)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(
                                color: Color.black.opacity(0.15),
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                        
                        // Content
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.0, green: 0.65, blue: 0.75),
                                                Color(red: 0.0, green: 0.55, blue: 0.65)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                Image(systemName: "stethoscope")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50, height: 50)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Doctor Portal")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 0.58))
                                
                                Text("Review & Diagnose Cases")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(red: 0.0, green: 0.48, blue: 0.58).opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.0, green: 0.65, blue: 0.75))
                                .offset(x: selectedTab == 0 ? 8 : 0)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    }
                    .frame(height: 78)
                }
                .scaleEffect(selectedTab == 0 ? 0.96 : 1.0)
                .offset(y: showContent ? 0 : 60)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: selectedTab == 0)
                .animation(.easeOut(duration: 0.7).delay(0.35), value: showContent)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = nil
                        }
                    }
                }

                // Patient Portal Button
                NavigationLink(destination: PatientLoginView()) {
                    ZStack {
                        // Glassmorphic background
                        RoundedRectangle(cornerRadius: 22)
                            .fill(Color.white.opacity(0.15))
                            .background(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            )
                            .blur(radius: 0.5)
                        
                        // Content
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.2))
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 50, height: 50)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Patient Portal")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("View Results & History")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white.opacity(0.8))
                                .offset(x: selectedTab == 1 ? 8 : 0)
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                    }
                    .frame(height: 78)
                }
                .scaleEffect(selectedTab == 1 ? 0.96 : 1.0)
                .offset(y: showContent ? 0 : 60)
                .opacity(showContent ? 1 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.75), value: selectedTab == 1)
                .animation(.easeOut(duration: 0.7).delay(0.45), value: showContent)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = 1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = nil
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // ✅ PREMIUM FOOTER
            VStack(spacing: 12) {
                Divider()
                    .opacity(0.3)
                    .padding(.horizontal, 40)
                
                VStack(spacing: 6) {
                    Text("© 2025 Nephrolith")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 20) {
                        Text("v1.0.0")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.white.opacity(0.6))
                            .letterSpacing(0.5)
                        
                    }
                }
            }
            .padding(.bottom, 28)
            .offset(y: showContent ? 0 : 20)
            .opacity(showContent ? 1 : 0)
            .animation(.easeOut(duration: 0.7).delay(0.55), value: showContent)
        }
    }

    // ✅ ENHANCED INITIALIZATION
    func initializeApp() {
        print("🔑 Initializing User Selection...")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                isAppReady = true
            }
        }
    }
}

#Preview {
    UserSelectionView()
}

// ✅ HELPER EXTENSION
extension Text {
    func letterSpacing(_ value: CGFloat) -> some View {
        self.tracking(value)
    }
}
