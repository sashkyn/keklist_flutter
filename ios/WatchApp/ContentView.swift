import SwiftUI

struct ContentView: View {
    
    private var manager = WatchCommunicationManager()
    
    @State
    private var minds: [Mind] = []
    
    @State
    private var isLoading: Bool = true
    
    var body: some View {
        if isLoading {
            ProgressView()
                .onAppear {
//                    manager.onReceiveMinds = { minds in
//                        isLoading = false
//                        self.minds = minds
//                    }
//                    manager.obtainTodayMinds()
                    
                    let emojis: [Character] = ["😊", "🤔", "😍", "🤯", "🧘‍♀️"]
                    let notes: [String] = ["Feeling great today!", "Can't seem to focus on anything.", "Just got some exciting news!", "Mind blown by the latest tech.", "Meditated for 20 minutes."]
                    var minds: [Mind] = []
                    
                    for i in 0..<30 {
                        let uuid = UUID().uuidString
                        let emoji = emojis.randomElement()!
                        let note = notes.randomElement()!
                        let dayIndex = i % 7
                        let sortIndex = Int.random(in: 0..<100)
                        let mind = Mind(uuid: uuid, emoji: emoji, note: note, dayIndex: dayIndex, sortIndex: sortIndex)
                        minds.append(mind)
                    }
                    isLoading = false
                    self.minds = minds
                }
        } else {
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ]
                ) {
                    ForEach($minds, id: \.uuid) { mind in
                        MindRow(mind: mind)
                    }
                    Button("+") {
                        print("+")
                    }
                }
                .padding()
            }
        }
    }
}

struct MindRow: View {
    @Binding var mind: Mind

    var body: some View {
        ZStack {
            Button(action: {
                print(mind.emoji.description)
            }) {
                Text(mind.emoji.description).font(.system(size: 30))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
