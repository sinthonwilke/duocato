import SwiftUI

struct Avatar: View {
    var body: some View {
        Image("Test")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    Avatar()
}
