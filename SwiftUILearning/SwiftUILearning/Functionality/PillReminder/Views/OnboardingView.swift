import SwiftUI

struct OnboardingView: View {
    @Binding var isCompleted: Bool
    @State private var page = 0

    var body: some View {
        TabView(selection: $page) {
            OnboardingPage(title: "Welcome to PillPal", subtitle: "Take your meds on time, always.", image: "pills.fill")
                .tag(0)
            OnboardingPage(title: "Smart Reminders", subtitle: "Repeat rules, refill alerts, and history.", image: "bell.fill")
                .tag(1)
            OnboardingPermissionsView(completed: $isCompleted)
                .tag(2)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(
            Group {
                if page < 2 {
                    VStack {
                        HStack(spacing: 8) {
                            ForEach(0..<3, id: \.self) { index in
                                Circle()
                                    .fill(index == page ? AppTheme.accent : Color.gray.opacity(0.4))
                                    .frame(width: 8, height: 8)
                            }
                        }
                        .padding(.bottom, 8)

                        Button(action: {
                            if page < 2 { page += 1 } else { isCompleted = true }
                        }) {
                            Text(page < 2 ? "Next" : "Get Started")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppTheme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(color: AppTheme.accent.opacity(0.4), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 32)
                        .padding(.bottom, 30)
                    }
                }
            },
            alignment: .bottom
        )
    }
}

#Preview {
    // For demo, use a constant binding so the view can render
    OnboardingView(isCompleted: .constant(false))
}

struct OnboardingPage: View {
    var title: String
    var subtitle: String
    var image: String

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
            Text(title).font(.title).bold()
            Text(subtitle).multilineTextAlignment(.center).padding(.horizontal)
            Spacer()
        }
    }
}

struct OnboardingPermissionsView: View {
    @Binding var completed: Bool
    @State private var navigateToWelcome = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Spacer()
                Image(systemName: "hand.raised.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(AppTheme.accent)
                Text("Allow Notifications")
                    .font(.title2).bold()
                    .foregroundColor(.black)
                Text("To get pill reminders we recommend enabling notifications.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .foregroundColor(.gray)
                Spacer()

                NavigationLink(destination: WelcomeView(), isActive: $navigateToWelcome) { EmptyView() }

                Button(action: {
                    // In production, request notification permissions here
                    navigateToWelcome = true
                }) {
                    Text("Allow Notifications")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                Button("Skip for now") {
                    navigateToWelcome = true
                }
                .padding(.bottom)
            }
        }
    }
}
