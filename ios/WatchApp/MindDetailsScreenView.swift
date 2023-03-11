import SwiftUI

struct MindDetailsScreenView: View {
    
    let mind: Mind
    
    var body: some View {
        ScrollView {
            VStack {
                Text(mind.emoji.description).font(.largeTitle)
                Text(mind.note).font(.body)
            }
        }
    }
}
