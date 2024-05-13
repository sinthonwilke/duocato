import SwiftUI

struct Dialog: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @Binding var messages: [Message]
    @Binding var speechString: String
    
    var body: some View {
        VStack {
            if !messages.isEmpty {
                ScrollView {
                    ScrollViewReader { scrollView in
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(messages.indices, id: \.self) { index in
                                let message = messages[index]
                                MessageView(message: message)
                                    .id(message.id)
                                    .padding(.top, index == 0 ? 30 : 0)
                                    .padding(.bottom, index == messages.count - 1 ? 30 : 0)
                            }
                            .onChange(of: messages.count) {
                                withAnimation {
                                    scrollView.scrollTo(messages.last?.id)
                                }
                            }
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [userTheme.getBackgroundColor, Color.clear]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 30), alignment: .top)
                .overlay(
                    LinearGradient(gradient: Gradient(colors: [Color.clear, userTheme.getBackgroundColor]), startPoint: .top, endPoint: .bottom)
                        .frame(height: 30), alignment: .bottom)
            } else {
                VStack(spacing:20) {
                    Text("Start to talk with DuoCato!")
                        .foregroundColor(userTheme.getFontColor)
                        .bold()
                    Image(systemName: "arrowshape.down.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 30)
                        .foregroundColor(userTheme.getFontColor)
                }
                .frame(maxHeight: .infinity)
            }
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
                .clipShape(
                    .rect( topLeadingRadius: 20, bottomLeadingRadius: message.isSentByUser ? 20 : 0, bottomTrailingRadius: message.isSentByUser ? 0 : 20, topTrailingRadius: 20 )
                )
            if !message.isSentByUser {
                Spacer()
            }
        }
    }
}

struct Message: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let isSentByUser: Bool
}
