import SwiftUI

struct Main: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @State private var selectedMode: Mode? = nil

    var body: some View {
        ZStack{
            userTheme.getBackgroundColor
                .ignoresSafeArea(.all)
            
            VStack {
                HStack(spacing: 20) {
                    ModeSelect(selectedMode: $selectedMode)
                    ThemeSwitch()
                }
                Spacer()
                Avatar()
                Dialog()
                Spacer()
                Microphone()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 50)
        }
    }
}

#Preview {
    Main()
}
