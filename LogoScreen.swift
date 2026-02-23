import SwiftUI

struct LogoScreen: View {
    @State private var scale: CGFloat = 0.6

    var body: some View {
        ZStack {
            Color(.systemTeal)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 180, height: 180)
                    .scaleEffect(scale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.65)) {
                            scale = 1.1
                        }
                        withAnimation(.spring().delay(0.3)) {
                            scale = 1.0
                        }
                    }
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 56, style: .continuous))

                Text("NEPHROLITH")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)

                Text(" ")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
            }
        }
    }
}

#Preview {
    LogoScreen()
}
