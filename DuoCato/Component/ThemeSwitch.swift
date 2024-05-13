import SwiftUI

struct ThemeSwitch: View {
    @Environment(\.colorScheme) private var scheme
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    
    func handleClick() {
        switch userTheme {
        case .light:
            userTheme = .dark
        case .dark:
            userTheme = .light
        case .systemDefault:
            userTheme = (scheme == .dark) ? .light : .dark
        }
    }
    
    var body: some View {
        Button(action: {
            handleClick()
        }) {
            Image(systemName: (userTheme == .dark) ? "moon.fill" : "circle.fill")
                .font(.system(size: 30))
        }
        .foregroundColor(.yellow)
        .frame(width: 50, height: 50)
        .background(userTheme.getMain)
        .cornerRadius(10)
        .overlay( RoundedRectangle(cornerRadius: 10)
            .stroke(userTheme.getFont, lineWidth: 3)
        )
    }
}

enum Theme: String, CaseIterable {
    case systemDefault
    case light
    case dark
    
    var getMain: Color {
        Color(getColorName(for: self) + "Main")
    }
    
    var getGPT: Color {
        Color(getColorName(for: self) + "GPT")
    }
    
    var getUser: Color {
        Color(getColorName(for: self) + "User")
    }
    
    var getFont: Color {
        Color(getColorName(for: self) + "Font")
    }
    
    private func getColorName(for theme: Theme) -> String {
        switch theme {
        case .systemDefault:
            return self == .light ? "light" : "dark"
        case .light:
            return "light"
        case .dark:
            return "dark"
        }
    }
}
