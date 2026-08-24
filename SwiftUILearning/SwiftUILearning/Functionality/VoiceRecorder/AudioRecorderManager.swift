//
//  AudioRecorderManager.swift
//  SwiftUILearning
//
//  Created by Nexios Technologies on 04/11/25.
//

import Foundation
import AVFAudio

class AudioRecorderManager: NSObject, ObservableObject {
    static let shared = AudioRecorderManager()
    var audioRecorder: AVAudioRecorder?
    @Published var recordingTime: TimeInterval = 0
    private var timer: Timer?
    var recordedFileURL: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documents.appendingPathComponent("recordedVoice.m4a")
    }

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        session.requestRecordPermission { granted in
            DispatchQueue.main.async {
                if granted {
                    do {
                        try session.setCategory(.playAndRecord, mode: .default)
                        try session.setActive(true)
                        let settings: [String: Any] = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        self.audioRecorder = try AVAudioRecorder(url: self.recordedFileURL, settings: settings)
                        self.audioRecorder?.record()
                        self.startTimer()
                        print("🎙️ Recording started at: \(self.recordedFileURL.path)")
                    } catch {
                        print("❌ Recording failed: \(error)")
                    }
                } else {
                    print("🚫 Microphone permission denied.")
                }
            }
        }
    }

    func stopRecording() {
        audioRecorder?.stop()
        audioRecorder = nil
        stopTimer()
        print("🛑 Recording stopped. File saved at: \(recordedFileURL.path)")
    }
    
    private func startTimer() {
        stopTimer() // prevent multiple timers
        recordingTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
