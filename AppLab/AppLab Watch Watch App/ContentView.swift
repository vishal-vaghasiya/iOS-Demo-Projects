//
//  ContentView.swift
//  AppLab Watch Watch App
//
//  Created by Nexios Technologies on 18/09/25.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @StateObject private var timerManager = TimerManager()
    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingHistory = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            HStack {
                AnimatedButton(systemImage: "bell", backgroundOpacity: 0.2) {
                    scheduleNotification()
                }
                .padding(.leading, 10)
                Spacer()
                Text("AppLab")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                Spacer()
                AnimatedButton(systemImage: "list.bullet", backgroundOpacity: 0.2) {
                    showingHistory = true
                }
                .padding(.trailing, 10)
            }
            
            Spacer()
            // Timer Section
            VStack {
                Text("Timer")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(formattedTime)
                    .font(.title2)
                    .bold()
                
                HStack(spacing: 8) {
                    AnimatedButton(
                        title: timerManager.secondsElapsed == 0 ? "Start" : (timerManager.isPaused ? "Resume" : "Pause"),
                        backgroundOpacity: 0.3
                    ) {
                        if timerManager.secondsElapsed == 0 {
                            timerManager.start()
                            //                            HealthManager.shared.requestAuthorization { success, error in
                            //                                if success {
                            //                                    HealthManager.shared.getTodayStepCount { steps, error in
                            //                                        print("Today's steps: \(steps ?? 0)")
                            //                                    }
                            //                                } else {
                            //                                    print(error)
                            //                                }
                            //                            }
                        } else if timerManager.isPaused {
                            timerManager.start()
                        } else {
                            timerManager.pause()
                        }
                    }
                    
                    AnimatedButton(title: "Reset", backgroundOpacity: 0.2) {
                        timerManager.reset(context: viewContext)
                    }
                }.padding(.horizontal)
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
                    .environment(\.managedObjectContext, viewContext)
            }
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

#Preview {
    ContentView()
}

// MARK: - AnimatedButton
struct AnimatedButton: View {
    let title: String?
    let systemImage: String?
    let backgroundOpacity: Double
    let action: () -> Void
    @State private var isPressed = false
    
    init(title: String? = nil, systemImage: String? = nil, backgroundOpacity: Double, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.backgroundOpacity = backgroundOpacity
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack {
                if let systemImage = systemImage {
                    Image(systemName: systemImage)
                        .foregroundColor(.white)
                        .frame(width: 28, height: 28)
                        .font(.system(size: 16, weight: .semibold))
                        .background(Color.white.opacity(backgroundOpacity))
                        .cornerRadius(12)
                } else if let title = title {
                    Text(title)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .font(.system(size: 14, weight: .semibold))
                        .frame(height: 28)
                        .padding(6)
                        .background(Color.white.opacity(backgroundOpacity))
                        .cornerRadius(12)
                }
            }
            .contentShape(Rectangle())
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

extension ContentView {
    // Computed property to format secondsElapsed as HH:mm:ss
    var formattedTime: String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = [.pad]
        return formatter.string(from: TimeInterval(timerManager.secondsElapsed)) ?? "00:00:00"
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer Alert"
        content.body = "Your timer is still running!"
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
}
