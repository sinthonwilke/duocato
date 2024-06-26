import SwiftUI

struct ModeSelect: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    @Binding var selectedMode: Mode

    var body: some View {
        
        HStack(spacing: 0) {
            ForEach(Mode.allCases, id: \.self) { mode in
                ModeButton(mode: mode, isSelected: mode == self.selectedMode) {
                    withAnimation {
                        self.selectedMode = mode
                    }
                }
            }
        }
        .background(userTheme.getMain)
        .cornerRadius(10)
        .overlay( RoundedRectangle(cornerRadius: 10)
            .stroke(userTheme.getFont, lineWidth: 3)
        )
    }
}

struct ModeButton: View {
    @AppStorage("user_theme") private var userTheme: Theme = .systemDefault
    let mode: Mode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(mode.rawValue.capitalized)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                .background(isSelected ? userTheme.getGPT: Color.clear)
                .foregroundStyle(userTheme.getFont)
                .bold()
        }
    }
}

enum Mode: String, CaseIterable {
    case easy
    case medium
    case hard
    
    func getModeStr() -> String {
        return self.rawValue
    }
}
