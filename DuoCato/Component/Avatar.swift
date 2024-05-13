import SwiftUI

struct Avatar: View {
    @Binding var selectedMode: Mode?
    @Binding var isSpeaking: Bool
    @State private var isMouthOpen = false
    
    var body: some View {
        ZStack{
            Image(selectedMode == .easy ? "catoEasy" : selectedMode == .medium ? "catoMedium" : "catoHard")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 250)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 5, y: 5)
                .padding(.leading, 50)
            
            if isSpeaking {
                Circle()
                    .fill(Color(#colorLiteral(red: 0.9450980425, green: 0.6078431606, blue: 0.6078431606, alpha: 1)))
                    .frame(height: 15)
                    .offset(x: -40, y: -12)
                    .scaleEffect(isSpeaking ? (isMouthOpen ? 1.05 : 1.0) : 1.0)
                    .animation(Animation.easeInOut(duration: 0.15).repeatForever())
            }
        }
        .onAppear {
            startMouthAnimation()
        }
        .onChange(of: isSpeaking) {
            if isSpeaking {
                startMouthAnimation()
            } else {
                withAnimation {
                    isMouthOpen = false
                }
            }
        }
    }
    
    func startMouthAnimation() {
        withAnimation {
            isMouthOpen.toggle()
        }
    }
}
