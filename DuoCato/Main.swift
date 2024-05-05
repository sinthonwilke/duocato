import SwiftUI

struct Main: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @State private var selectedMode: Mode? = nil

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
                Dialog()
                Microphone()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
    }
}

#Preview {
    Main()
}
