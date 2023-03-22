import SwiftUI

// TODO: начать 

struct LoadingView: View {
    var body: some View {
        ZStack {
            VStack {
                Text("Loading...")
                ProgressView()
            }
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
