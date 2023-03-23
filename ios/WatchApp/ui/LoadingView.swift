import SwiftUI

struct LoadingView: View {
    let text: String
    
    var body: some View {
        ZStack {
            VStack {
                Text(text)
                ProgressView()
            }
        }
    }
}

#if DEBUG
struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView(text: "Connecting...")
    }
}
#endif
