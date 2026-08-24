//
//  VoiceEffectManager.swift
//  SwiftUILearning
//
//  Created by [Your Name] on [Date].
//
//  Description:
//  This class manages audio playback, recording, and conversion with various
//  voice-changing effects such as male, female, echo, and robot. It also handles
//  sharing of converted audio files.
//

import Foundation
import AVFoundation
import UIKit
import Combine

// MARK: - Singleton Setup

class VoiceEffectManager: ObservableObject {
    
    static let shared = VoiceEffectManager()
    private init() {}
    
    // MARK: - Voice Effect Types
    
    enum VoiceEffect {
        case normal
        case male
        case female
        case robot
        case echo
    }
    
    // MARK: - Audio Properties
    
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
    public var currentConvertedURL: URL?
    
    @Published var playbackTime: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    private var playbackTimer: Timer?
    
    // MARK: - Public Playback Methods
    
    /// Plays a voice file with the given audio effect.
    func playVoice(from url: URL, effect: VoiceEffect) {
        playAudio(from: url, effect: effect)
    }
    
    // MARK: - Internal Playback Logic
    
    /// Internal function to setup and play audio with the specified effect.
    private func playAudio(from url: URL, effect: VoiceEffect) {
        stopPlayback()
        
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let player = audioPlayerNode else { return }
        
        engine.attach(player)
        
        // Attach and connect audio effects based on the selected voice effect
        switch effect {
        case .normal:
            // No effect, play original audio
            break
        case .male:
            let pitchEffect = AVAudioUnitTimePitch()
            pitchEffect.pitch = -600
            engine.attach(pitchEffect)
            engine.connect(player, to: pitchEffect, format: nil)
            engine.connect(pitchEffect, to: engine.mainMixerNode, format: nil)
        case .female:
            let pitchEffect = AVAudioUnitTimePitch()
            pitchEffect.pitch = 900
            engine.attach(pitchEffect)
            engine.connect(player, to: pitchEffect, format: nil)
            engine.connect(pitchEffect, to: engine.mainMixerNode, format: nil)
        case .robot:
            let distortion = AVAudioUnitDistortion()
            distortion.loadFactoryPreset(.speechCosmicInterference)
            distortion.wetDryMix = 50
            engine.attach(distortion)
            engine.connect(player, to: distortion, format: nil)
            engine.connect(distortion, to: engine.mainMixerNode, format: nil)
        case .echo:
            let delay = AVAudioUnitDelay()
            delay.delayTime = 0.3
            delay.feedback = 50
            delay.wetDryMix = 50
            engine.attach(delay)
            engine.connect(player, to: delay, format: nil)
            engine.connect(delay, to: engine.mainMixerNode, format: nil)
        }
        
        do {
            audioFile = try AVAudioFile(forReading: url)
            guard let file = audioFile else { return }
            
            // Configure audio session for playback
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            
            // Ensure final connection to output node before starting engine
            let format = file.processingFormat
            if engine.mainMixerNode.outputFormat(forBus: 0).channelCount == 0 {
                engine.connect(engine.mainMixerNode, to: engine.outputNode, format: format)
            }
            
            // Start audio engine safely
            if !engine.isRunning {
                try engine.start()
            }
            
            // Schedule audio file for playback
            player.scheduleFile(file, at: nil)
            
            // Delay play slightly to ensure routing is ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                player.play()
                print("🎧 Playing with effect \(effect)")
                self.playbackTime = 0
                self.totalDuration = file.durationSeconds()
                self.startPlaybackTimer()
            }
        } catch {
            print("❌ Playback error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Stop Playback
    
    /// Stops current audio playback and resets playback timer.
    func stopPlayback() {
        stopPlaybackTimer()
        playbackTime = 0
        audioEngine?.stop()
        audioEngine?.reset()
    }
    
    // MARK: - Conversion (Save new voice with effect)
    
    /// Converts the input audio file applying the selected effect and saves the output.
    func convertVoice(from inputURL: URL, effect: VoiceEffect, completion: @escaping (URL?) -> Void) {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        engine.attach(player)
        
        // Attach and connect audio effects based on the selected voice effect
        switch effect {
        case .normal:
            // No effect
            break
        case .male:
            let pitchEffect = AVAudioUnitTimePitch()
            pitchEffect.pitch = -600
            engine.attach(pitchEffect)
            engine.connect(player, to: pitchEffect, format: nil)
            engine.connect(pitchEffect, to: engine.mainMixerNode, format: nil)
        case .female:
            let pitchEffect = AVAudioUnitTimePitch()
            pitchEffect.pitch = 900
            engine.attach(pitchEffect)
            engine.connect(player, to: pitchEffect, format: nil)
            engine.connect(pitchEffect, to: engine.mainMixerNode, format: nil)
        case .robot:
            let distortion = AVAudioUnitDistortion()
            distortion.loadFactoryPreset(.speechCosmicInterference)
            distortion.wetDryMix = 50
            engine.attach(distortion)
            engine.connect(player, to: distortion, format: nil)
            engine.connect(distortion, to: engine.mainMixerNode, format: nil)
        case .echo:
            let delay = AVAudioUnitDelay()
            delay.delayTime = 0.3
            delay.feedback = 50
            delay.wetDryMix = 50
            engine.attach(delay)
            engine.connect(player, to: delay, format: nil)
            engine.connect(delay, to: engine.mainMixerNode, format: nil)
        }
        
        do {
            let inputFile = try AVAudioFile(forReading: inputURL)
            
            // Prepare output file URL
            let effectName: String
            switch effect {
            case .normal: effectName = "normal"
            case .male: effectName = "male"
            case .female: effectName = "female"
            case .robot: effectName = "robot"
            case .echo: effectName = "echo"
            }
            let outputURL = getDocumentsDirectory().appendingPathComponent("converted_\(effectName).m4a")
            
            // Setup output file with main mixer node's output format
            let format = engine.mainMixerNode.outputFormat(forBus: 0)
            let outputFile = try AVAudioFile(forWriting: outputURL, settings: format.settings)
            
            // Schedule input file for playback
            player.scheduleFile(inputFile, at: nil)
            
            // Install tap to capture audio to output file
            engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                do {
                    try outputFile.write(from: buffer)
                } catch {
                    print("Error writing buffer: \(error)")
                }
            }
            
            try engine.start()
            player.play()
            
            // Calculate duration to stop engine and finalize file
            let duration = Double(inputFile.length) / inputFile.processingFormat.sampleRate
            DispatchQueue.global().asyncAfter(deadline: .now() + duration) {
                engine.stop()
                engine.mainMixerNode.removeTap(onBus: 0)
                self.currentConvertedURL = outputURL
                DispatchQueue.main.async {
                    print("✅ Saved converted file at: \(outputURL.lastPathComponent)")
                    completion(outputURL)
                }
            }
        } catch {
            print("❌ Conversion failed: \(error)")
            completion(nil)
        }
    }
    
    // MARK: - Sharing Converted Audio
    
    /// Presents a share sheet to share the converted audio file.
    func shareConvertedVoice(from viewController: UIViewController) {
        guard let url = currentConvertedURL else {
            let alert = UIAlertController(title: "No Converted File",
                                          message: "Please convert a voice first.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            viewController.present(alert, animated: true)
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        viewController.present(activityVC, animated: true)
    }
    
    // MARK: - Helper Methods
    
    /// Returns the documents directory URL for the app.
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Playback Timer Helpers
    
    /// Starts a timer to update playback time every second.
    private func startPlaybackTimer() {
        stopPlaybackTimer()
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.playbackTime += 1
            if self.playbackTime >= self.totalDuration {
                self.stopPlaybackTimer()
            }
        }
    }
    
    /// Stops the playback timer if running.
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
}

// MARK: - AVAudioFile Extension

extension AVAudioFile {
    /// Calculates the duration of the audio file in seconds.
    func durationSeconds() -> TimeInterval {
        return Double(length) / processingFormat.sampleRate
    }
}

// MARK: - Example Usage (UIKit ViewController)

import UIKit

class VoiceChangerViewController: UIViewController {
    
    var recordedFileURL: URL! // Your existing .m4a file path
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        // Example usage:
        // VoiceChangerManager.shared.playVoice(from: recordedFileURL, effect: .male)
    }
    
    @IBAction func playNormalTapped(_ sender: UIButton) {
        VoiceEffectManager.shared.playVoice(from: recordedFileURL, effect: .normal)
    }
    
    @IBAction func playMaleTapped(_ sender: UIButton) {
        VoiceEffectManager.shared.playVoice(from: recordedFileURL, effect: .male)
    }
    
    @IBAction func playFemaleTapped(_ sender: UIButton) {
        VoiceEffectManager.shared.playVoice(from: recordedFileURL, effect: .female)
    }
    
    @IBAction func playRobotTapped(_ sender: UIButton) {
        VoiceEffectManager.shared.playVoice(from: recordedFileURL, effect: .robot)
    }
    
    @IBAction func playEchoTapped(_ sender: UIButton) {
        VoiceEffectManager.shared.playVoice(from: recordedFileURL, effect: .echo)
    }
    
    @IBAction func convertTapped(_ sender: UIButton) {
        // Example: Convert with male effect
        VoiceEffectManager.shared.convertVoice(from: recordedFileURL, effect: .male) { url in
            print("Converted file at: \(url?.absoluteString ?? "nil")")
        }
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        VoiceEffectManager.shared.shareConvertedVoice(from: self)
    }
}


//✅ Features of VoiceChangerManager
/*
Function                                                                                Description
playVoice(from:effect:)                                                                 Plays audio with selected voice effect
convertVoice(from:effect:completion:)                                                   Converts and saves new modified audio file with selected effect
shareConvertedVoice(from:)                                                              Opens iOS Share Sheet for converted file
stopPlayback()                                                                          Stops current playback
*/

//🧩 Info.plist (Add if not already)
/*
<key>NSMicrophoneUsageDescription</key>
<string>We need access to record and modify your voice.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>We need access to save your converted voice.</string>
*/
