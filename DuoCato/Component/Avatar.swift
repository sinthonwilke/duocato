import SwiftUI

struct Avatar: View {
    var body: some View {
        Image("Cato")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 250)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.3), radius: 2, x: 5, y: 5)
            .padding(.leading, 50)
    }
}
