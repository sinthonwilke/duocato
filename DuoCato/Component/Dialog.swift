import SwiftUI

struct Dialog: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @State private var newMessageText = ""
    @State private var messages: [Message] = [
        Message(text: "Hello!", isSentByUser: false),
        Message(text: "Hi there!", isSentByUser: true),
        Message(text: "Hi there!", isSentByUser: true),
        Message(text: "Hi there!", isSentByUser: true),
        Message(text: "Hi there!", isSentByUser: true),
        Message(text: "Hi there!", isSentByUser: true),
        Message(text: "Hi there!", isSentByUser: true),
        Message(text: "Hi there!", isSentByUser: true),
        Message(text: "Hi there!", isSentByUser: true),
    ]
    
    func sendMessage() {
        guard !newMessageText.isEmpty else { return }
        let message = Message(text: newMessageText, isSentByUser: true)
        messages.append(message)
        newMessageText = ""
    }
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollView in
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(messages.indices, id: \.self) { index in
                            let message = messages[index]
                            MessageView(message: message)
                                .id(message.id)
                                .padding(.top, index == 0 ? 30 : 0)
                                .padding(.bottom, index == messages.count - 1 ? 30 : 0) // Add bottom padding only to the last message
                        }
                        .onChange(of: messages.count) { _ in
                            withAnimation {
                                scrollView.scrollTo(messages.last?.id)
                            }                        }
                    }
                }
            }
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [userTheme.getBackgroundColor, Color.clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 30),
                alignment: .top)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.clear, userTheme.getBackgroundColor]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 30)
                , alignment: .bottom)
//            HStack {
//                TextField("Type a message...", text: $newMessageText)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                
//                Button(action: sendMessage) {
//                    Text("Send")
//                }
//            }
        }
    }
}

struct MessageView: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    let message: Message
    
    var body: some View {
        HStack {
            if message.isSentByUser {
                Spacer()
            }
            
            Text(message.text)
                .padding(10)
                .foregroundColor(userTheme.getFontColor)
                .background(message.isSentByUser ? userTheme.getPrimaryColor : userTheme.getSecondaryColor)
                .cornerRadius(10)
        }
    }
}

struct Message: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isSentByUser: Bool
}
