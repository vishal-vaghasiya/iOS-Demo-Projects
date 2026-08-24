import Foundation
import AVFoundation
import UIKit

class VoiceChangerManager {
    
    static let shared = VoiceChangerManager()
    private init() {}
    
    enum VoiceEffect {
        case normal
        case male
        case female
        case robot
        case echo
    }
    
    // MARK: - Audio properties
    private var audioEngine: AVAudioEngine?
    private var audioPlayerNode: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
    private var currentConvertedURL: URL?
    
    // MARK: - Public playback methods
    func playVoice(from url: URL, effect: VoiceEffect) {
        playAudio(from: url, effect: effect)
    }
    
    // MARK: - Internal playback logic
    private func playAudio(from url: URL, effect: VoiceEffect) {
        stopPlayback()
        
        audioEngine = AVAudioEngine()
        audioPlayerNode = AVAudioPlayerNode()
        
        guard let engine = audioEngine, let player = audioPlayerNode else { return }
        
        engine.attach(player)
        
        switch effect {
        case .normal:
            // No effect, just play original
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
            player.scheduleFile(file, at: nil)
            try engine.start()
            player.play()
            print("🎧 Playing with effect \(effect)")
        } catch {
            print("❌ Playback error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Stop playback
    func stopPlayback() {
        audioEngine?.stop()
        audioEngine?.reset()
    }
    
    // MARK: - Conversion (Save new voice)
    func convertVoice(from inputURL: URL, effect: VoiceEffect, completion: @escaping (URL?) -> Void) {
        let engine = AVAudioEngine()
        let player = AVAudioPlayerNode()
        
        engine.attach(player)
        
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
            let effectName: String
            switch effect {
            case .normal: effectName = "normal"
            case .male: effectName = "male"
            case .female: effectName = "female"
            case .robot: effectName = "robot"
            case .echo: effectName = "echo"
            }
            let outputURL = getDocumentsDirectory().appendingPathComponent("converted_\(effectName).m4a")
            let format = engine.mainMixerNode.outputFormat(forBus: 0)
            let outputFile = try AVAudioFile(forWriting: outputURL, settings: format.settings)
            
            player.scheduleFile(inputFile, at: nil)
            engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
                do {
                    try outputFile.write(from: buffer)
                } catch {
                    print("Error writing buffer: \(error)")
                }
            }
            
            try engine.start()
            player.play()
            
            DispatchQueue.global().asyncAfter(deadline: .now() + inputFile.duration) {
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
    
    // MARK: - Share converted file
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
    
    // MARK: - Helper
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

//💡 How to Use in Your ViewController

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
        VoiceChangerManager.shared.playVoice(from: recordedFileURL, effect: .normal)
    }
    
    @IBAction func playMaleTapped(_ sender: UIButton) {
        VoiceChangerManager.shared.playVoice(from: recordedFileURL, effect: .male)
    }
    
    @IBAction func playFemaleTapped(_ sender: UIButton) {
        VoiceChangerManager.shared.playVoice(from: recordedFileURL, effect: .female)
    }
    
    @IBAction func playRobotTapped(_ sender: UIButton) {
        VoiceChangerManager.shared.playVoice(from: recordedFileURL, effect: .robot)
    }
    
    @IBAction func playEchoTapped(_ sender: UIButton) {
        VoiceChangerManager.shared.playVoice(from: recordedFileURL, effect: .echo)
    }
    
    @IBAction func convertTapped(_ sender: UIButton) {
        // Example: Convert with male effect
        VoiceChangerManager.shared.convertVoice(from: recordedFileURL, effect: .male) { url in
            print("Converted file at: \(url?.absoluteString ?? "nil")")
        }
    }
    
    @IBAction func shareTapped(_ sender: UIButton) {
        VoiceChangerManager.shared.shareConvertedVoice(from: self)
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
