import SwiftUI

struct Main: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @State private var selectedMode: Mode? = .easy
    @State var speechString: String = ""
    @State var isUserTurn: Bool = true
    @State var isBotSpeaking: Bool = false
    @State private var messages: [Message] = [Message(text: "Hello!", isSentByUser: false)]
    @ObservedObject var networkManager = NetworkManager()
    private var textToSpeechManager = TextToSpeechManager()
    private var meowSpeech = [
        "Hi",
    ]
    
    func handleUserInput() {
        if (isUserTurn) {
            guard !speechString.isEmpty else { return }
            let message = Message(text: speechString, isSentByUser: isUserTurn)
            messages.append(message)
            isUserTurn.toggle()
            speechString = ""
        }
    }
    
    func handleBotResponse() {
        if (!isUserTurn) {
            if let randomMeow = meowSpeech.randomElement() {
                let message = Message(text: randomMeow, isSentByUser: false)
                messages.append(message)
                
                self.isBotSpeaking = true
                textToSpeechManager.speak(message.text, mode: selectedMode) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isUserTurn.toggle()
                        self.isBotSpeaking = false
                    }
                }
            }
        }
    }
    
    var body: some View {
        if networkManager.isConnected {
            ZStack{
                userTheme.getBackgroundColor
                    .ignoresSafeArea(.all)
                VStack(spacing: 20) {
                    HStack(spacing: 20) {
                        ModeSelect(selectedMode: $selectedMode)
                        ThemeSwitch()
                    }
                    Avatar(selectedMode: $selectedMode, isSpeaking: $isBotSpeaking)
                    Dialog( messages: $messages, speechString: $speechString)
                    Microphone(speechString: $speechString, isUserTurn: $isUserTurn)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
            .onChange(of: speechString) {
                if (isUserTurn) {
                    handleUserInput()
                }
            }
            .onChange(of: isUserTurn) {
                if (!isUserTurn) {
                    handleBotResponse()
                }
            }
        } else {
            ZStack{
                userTheme.getBackgroundColor
                    .ignoresSafeArea(.all)
                VStack(spacing: 20) {
                    Image("catoSad")
                        .cornerRadius(10)
                    Text("No internet connection.")
                        .foregroundColor(userTheme.getFontColor)
                        .bold()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
            }
        }
    }
}

#Preview {
    Main()
}
