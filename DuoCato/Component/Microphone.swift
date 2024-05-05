import SwiftUI

struct Microphone: View {
    
    func handleClick() {
        
    }
    
    var body: some View {
        Button(action: {
            handleClick()
        }) {
            Image(systemName: "mic.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)

        }
        .frame(width: 100)
    }
}

#Preview {
    Microphone()
}
