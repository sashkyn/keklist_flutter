import SwiftUI

struct LoadingView: View {
    let text: String
    
    var body: some View {
        VStack {
            Text(text).font(.title3)
            ProgressView()
                .scaleEffect(1.5)
                .frame(
                    width: .infinity,
                    height: 40.0
                )
        }
        .frame(
            width: .infinity,
            height: .infinity
        )
    }
}

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(text: "Connecting...")
    }
}
#endif
