import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 30) {
                    Spacer()

                    VStack(spacing: 16) {
                        Image(systemName: "heart.text.square.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120)
                            .foregroundColor(AppTheme.accent)

                        Text("Welcome to PillPal")
                            .font(.largeTitle.bold())
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)

                        Text("Your smart companion for staying healthy — set reminders, track progress, and manage your medication with ease.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 40)
                    }

                    Spacer()

                    NavigationLink(destination: PillDashboardView()) {
                        Text("Continue")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.accent)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: AppTheme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 32)
                    }

                    Spacer(minLength: 60)
                }
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    WelcomeView()
}
