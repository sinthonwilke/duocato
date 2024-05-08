import SwiftUI

struct Main: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @State private var selectedMode: Mode? = .easy
    @State var speechString: String = ""
    @State var isUserTurn: Bool = true
    @State private var messages: [Message] = [
        Message(text: "Hello!", isSentByUser: false),
    ]
    private var meowSpeech = [
        "Meow.",
        "Meow, meow.",
        "Meow meow meow.",
        "Meow! Meow!",
        "Meow? Meow!",
        "Meow, meow, meow, meow.",
        "Meow... Meow...",
        "Meow meow, meow meow.",
        "Meow meow? Meow!",
        "Meow meow! Meow meow!",
        "Meow, meow meow, meow!",
        "Meow meow meow meow meow.",
        "Meow meow meow, meow meow.",
        "Meow! Meow meow, meow?",
        "Meow meow meow? Meow!",
        "Meow meow meow meow! Meow.",
        "Meow meow, meow meow, meow meow.",
        "Meow, meow meow meow meow?",
        "Meow meow meow! Meow meow meow!",
        "Meow meow? Meow meow, meow!",
    ]
    
    func handleUserInput() {
        print("handleUserInput")
        if (isUserTurn) {
            guard !speechString.isEmpty else { return }
            let message = Message(text: speechString, isSentByUser: isUserTurn)
            messages.append(message)
            isUserTurn.toggle()
            speechString = ""
        }
    }
    
    func handleBotResponse() {
        print("handleBotResponse")
        if (!isUserTurn) {
            delay(seconds: 2) {
                if let randomMeow = meowSpeech.randomElement() {
                    let message = Message(text: randomMeow, isSentByUser: false)
                    messages.append(message)
                    isUserTurn.toggle()
                }
            }
        }
    }
    
    
    func delay(seconds: Double, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
    }
    
    var body: some View {
        ZStack{
            userTheme.getBackgroundColor
                .ignoresSafeArea(.all)
            VStack(spacing: 20) {
                HStack(spacing: 20) {
                    ModeSelect(selectedMode: $selectedMode)
                    ThemeSwitch()
                }
                Avatar()
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
    }
}

#Preview {
    Main()
}
