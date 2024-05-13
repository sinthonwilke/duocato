import SwiftUI

struct Main: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @State private var selectedMode: Mode? = .easy
    @State var speechString: String = ""
    @State var isUserTurn: Bool = true
    @State var isBotSpeaking: Bool = false
    @State private var messages: [Message] = []
    @ObservedObject var networkManager = NetworkManager()
    private var textToSpeechManager = TextToSpeechManager()
    
    func handleUserInput() {
        if (isUserTurn) {
            guard !speechString.isEmpty else { return }
            let message = Message(text: speechString, isSentByUser: isUserTurn)
            messages.append(message)
            isUserTurn.toggle()
            Task {
                await handleBotResponse(text: message.text, mode: selectedMode!.getModeStr())
            }
            speechString = ""
        }
    }
    
    func handleBotResponse(text: String, mode: String) async {
        if (!isUserTurn) {
            do {
                let apiUrl = URL(string: "http://localhost:8000/")!
                let requestBody = ["message": text, "mode": mode]
                let json = try await fetchData(from: apiUrl, method: "POST", requestBody: requestBody)
                guard let jsonDictionary = json as? [String: Any],
                      let message = jsonDictionary["message"] as? String else {
                    throw NSError(domain: "Invalid JSON format", code: 0, userInfo: nil)
                }
                
                let newMessage = message
                let messageObject = Message(text: newMessage, isSentByUser: false)
                messages.append(messageObject)
                self.isBotSpeaking = true
                
                textToSpeechManager.speak(messageObject.text, mode: selectedMode) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isUserTurn.toggle()
                        self.isBotSpeaking = false
                    }
                }
            } catch {
                print("Error: \(error)")
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
        } else {
            ZStack{
                userTheme.getBackgroundColor
                    .ignoresSafeArea(.all)
                VStack(spacing: 50) {
                    Image("catoSad")
                        .cornerRadius(10)
                    HStack(spacing: 20) {
                        Spacer()
                        Image(systemName: "wifi.exclamationmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 50)
                            .foregroundStyle(userTheme.getFontColor)
                        Text("No internet connection.")
                            .foregroundColor(userTheme.getFontColor)
                            .bold()
                        Spacer()
                    }
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
