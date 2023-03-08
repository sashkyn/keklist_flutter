import SwiftUI

struct ContentView: View {
    
    private var manager = WatchCommunicationManager()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, Flutter!")
            Button("PING") {
                manager.obtainTodayMinds()
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
