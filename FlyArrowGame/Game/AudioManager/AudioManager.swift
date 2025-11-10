import Foundation
import AVFoundation
import UIKit

class AudioManager {
    
    static let shared = AudioManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [AVAudioPlayer] = []
    
    var isSoundEnabled: Bool {
        didSet {
            // Новая, упрощенная и рабочая логика
            if isSoundEnabled {
                playBackgroundMusic()
            } else {
                backgroundMusicPlayer?.stop()
                soundEffectPlayers.forEach { $0.stop() }
                soundEffectPlayers.removeAll()
            }
        }
    }
    
    var isVibrationEnabled: Bool = true
    
    private init() {
        self.isSoundEnabled = !UserDefaults.standard.bool(forKey: "isSoundEnabled_userDisabled")
        self.isVibrationEnabled = !UserDefaults.standard.bool(forKey: "isVibrationEnabled_userDisabled")
    }

    func saveSettings() {
        UserDefaults.standard.set(!isSoundEnabled, forKey: "isSoundEnabled_userDisabled")
        UserDefaults.standard.set(!isVibrationEnabled, forKey: "isVibrationEnabled_userDisabled")
    }
    
    // MARK: - Background Music
    
    func playBackgroundMusic() {
        guard isSoundEnabled, backgroundMusicPlayer?.isPlaying != true,
              let url = Bundle.main.url(forResource: "background_music", withExtension: "mp3") else { return }
   
        do {
            backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
            backgroundMusicPlayer?.numberOfLoops = -1
            backgroundMusicPlayer?.volume = 0.3
            backgroundMusicPlayer?.play()
        } catch {
            print("Could not load background music file: \(error)")
        }
    }
    
    // MARK: - Sound Effects
    
    func playSoundEffect(named name: String, extension ext: String = "mp3") {
        guard isSoundEnabled, let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: url)
            soundEffectPlayers.append(newPlayer)
            newPlayer.play()
            
            soundEffectPlayers = soundEffectPlayers.filter { $0.isPlaying }
            
        } catch {
            print("Could not load sound effect file: \(name).\(ext): \(error)")
        }
    }
    
    // MARK: - Vibration
    
    func vibrate(type: UINotificationFeedbackGenerator.FeedbackType) {
        guard isVibrationEnabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
    
    func impactVibrate(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        guard isVibrationEnabled else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }
}
