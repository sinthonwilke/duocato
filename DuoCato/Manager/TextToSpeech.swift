import AVFoundation

class TextToSpeechManager: NSObject, AVSpeechSynthesizerDelegate {
    let synthesizer = AVSpeechSynthesizer()
    var completion: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String, mode: Mode?, completion: (() -> Void)?) {
        self.completion = completion
        let utterance = AVSpeechUtterance(string: text)
        
        if let mode = mode {
            switch mode {
            case .easy:
                utterance.pitchMultiplier = 2.0
            case .medium:
                utterance.pitchMultiplier = 1.5
            case .hard:
                utterance.pitchMultiplier = 1.0
            }
        }
        synthesizer.speak(utterance)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        completion?()
    }
}
