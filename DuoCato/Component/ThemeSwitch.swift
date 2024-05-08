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
        .background(userTheme.getSecondaryColor)
        .cornerRadius(10)
        .overlay( RoundedRectangle(cornerRadius: 10)
            .stroke(userTheme.getPrimaryColor, lineWidth: 3)
        )
    }
}

enum Theme: String, CaseIterable {
    case systemDefault
    case light
    case dark
    
    var getPrimaryColor: Color {
        Color(getColorName(for: self) + "PrimaryColor")
    }
    
    var getSecondaryColor: Color {
        Color(getColorName(for: self) + "SecondaryColor")
    }
    
    var getBackgroundColor: Color {
        Color(getColorName(for: self) + "BackgroundColor")
    }
    
    var getFontColor: Color {
        Color(getColorName(for: self) + "FontColor")
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
