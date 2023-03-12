import SwiftUI

struct MindDetailsView: View {
    
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
