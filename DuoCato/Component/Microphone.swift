import SwiftUI
import Foundation
import AVFoundation
import Speech
import Foundation
import Accelerate

struct Microphone: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @Binding var speechString: String
    @Binding var isUserTurn: Bool
    @State var isRecording: Bool = false
    
    var body: some View {
        HStack {
            if isUserTurn {
                Image(systemName: "mic.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .foregroundStyle(userTheme.getFont)
                    .onTapGesture {
                        isRecording.toggle()
                    }
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: userTheme.getFont))
                    .frame(width: 100, height: 100)
                    .controlSize(.large)
                    .scaleEffect(2.5)
            }
        }
        .sheet(isPresented: $isRecording) {
            MicrophoneView(isRecording: self.$isRecording, searchText: self.$speechString, dismiss: {
                self.isRecording = false
            })
            .presentationDetents([.medium, .fraction(0.5)])
            .presentationDragIndicator(.visible)
        }
    }
}


struct MicrophoneView: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var isRecording:Bool
    @Binding var searchText:String
    var dismiss: () -> Void
    
    var body: some View {
        VStack{
            Spacer()
            Text("\((isRecording == false) ? "":((speechRecognizer.transcript == "") ? "Speak Now": speechRecognizer.transcript))")
                .foregroundColor(userTheme.getFont)
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: userTheme.getFont))
                .scaleEffect(2)
            Spacer()
            Button(action: {
                self.dismiss()
            }) {
                Text("Finish")
                    .foregroundStyle(userTheme.getFont)
                    .bold()
                    .padding(20)
            }
            .background(userTheme.getGPT)
            .frame(height: 60)
            .cornerRadius(10)
        }
        .padding(.bottom, 20)
        .frame(maxWidth: .infinity)
        .background(userTheme.getMain)
        .onAppear{
            speechRecognizer.transcribe()
        }
        .onDisappear{
            speechRecognizer.stopTranscribing()
            searchText = speechRecognizer.transcript
        }
    }
}


class SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "Can't initialize speech recognizer"
            case .notAuthorizedToRecognize: return "Not authorized to recognize speech"
            case .notPermittedToRecord: return "Not permitted to record audio"
            case .recognizerIsUnavailable: return "Recognizer is unavailable"
            }
        }
    }
    
    @Published public var transcript: String = ""
    
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private var recognizer: SFSpeechRecognizer? = nil
    
    public init(localeIdentifier: String = Locale.current.identifier) {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier))
        
        Task(priority: .background) {
            do {
                guard recognizer != nil else {
                    throw RecognizerError.nilRecognizer
                }
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                speakError(error)
            }
        }
    }
    
    deinit {
        reset()
    }
    
    func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
    }
    
    public func transcribe() {
        DispatchQueue(label: "Speech Recognizer Queue", qos: .userInteractive).async { [weak self] in
            guard let self = self, let recognizer = self.recognizer, recognizer.isAvailable else {
                self?.speakError(RecognizerError.recognizerIsUnavailable)
                return
            }
            
            do {
                let (audioEngine, request) = try Self.prepareEngine()
                self.audioEngine = audioEngine
                self.request = request
                
                self.task = recognizer.recognitionTask(with: request) { result, error in
                    let receivedFinalResult = result?.isFinal ?? false
                    let receivedError = error != nil // != nil mean there's error (true)
                    
                    if receivedFinalResult || receivedError {
                        audioEngine.stop()
                        audioEngine.inputNode.removeTap(onBus: 0)
                    }
                    
                    if let result = result {
                        self.speak(result.bestTranscription.formattedString)
                    }
                }
            } catch {
                self.reset()
                self.speakError(error)
            }
        }
    }
    
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest) {
        let audioEngine = AVAudioEngine()
        
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        let inputNode = audioEngine.inputNode
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
        }
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request)
    }
    /// Stop transcribing audio.
    public func stopTranscribing() {
        reset()
    }
    
    private func speakError(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        transcript = "<< \(errorMessage) >>"
    }
    private func speak(_ message: String) {
        transcript = message
    }
}

@available(macOS 10.15, *)
extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        await withCheckedContinuation { continuation in
            requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
        }
    }
}
