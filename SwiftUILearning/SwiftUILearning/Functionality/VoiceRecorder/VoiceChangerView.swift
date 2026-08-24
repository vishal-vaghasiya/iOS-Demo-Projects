import SwiftUI
import AVFoundation

struct VoiceChangerView: View {
    @ObservedObject var recorder = AudioRecorderManager.shared
    @ObservedObject var player = VoiceEffectManager.shared
    @State private var isRecording = false
    @State private var recordedURL: URL?

    var body: some View {
        ZStack {
            VStack(spacing: 30) {
                Text("🎙️ Voice Recorder")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                VStack(spacing: 20) {
                    Button(action: {
                        if isRecording {
                            AudioRecorderManager.shared.stopRecording()
                            recordedURL = AudioRecorderManager.shared.recordedFileURL
                        } else {
                            AudioRecorderManager.shared.startRecording()
                        }
                        isRecording.toggle()
                    }) {
                        Label(isRecording ? "Stop Recording" : "Start Recording",
                              systemImage: isRecording ? "stop.circle.fill" : "mic.circle.fill")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isRecording ? Color.red.opacity(0.8) : Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    if isRecording {
                        Text("Recording: \(formatTime(recorder.recordingTime))")
                            .font(.headline)
                            .foregroundColor(.red)
                    }

                    if let url = recordedURL {
                        Button(action: {
                            VoiceEffectManager.shared.playVoice(from: url, effect: .female)
                        }) {
                            Label("Play Recording", systemImage: "play.circle.fill")
                                .font(.title2)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        if player.totalDuration > 0 && player.playbackTime < player.totalDuration {
                            Text("Playing: \(formatTime(player.playbackTime)) / \(formatTime(player.totalDuration))")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                    } else {
                        Text("No recording available yet.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, 30)

                Spacer()
            }
            .padding(.top, 50)
        }
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VoiceChangerView()
}
