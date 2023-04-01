import SwiftUI

struct EmojiView: View {
    let emoji: String
    
    init(_ emoji: String) {
        self.emoji = emoji
    }

    var body: some View {
        Text(emoji).font(.system(size: 30))
    }
}
