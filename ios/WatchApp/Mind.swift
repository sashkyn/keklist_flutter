import Foundation

struct Mind {
    let uuid: String
    let emoji: Character
    let note: String
    let dayIndex: Int
    let sortIndex: Int
}

extension Mind: Decodable {
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case emoji
        case note
        case dayIndex
        case sortIndex
    }
        
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.uuid = try container.decode(String.self, forKey: .uuid)
        let emojiString = try container.decode(String.self, forKey: .emoji)
        guard let emoji = emojiString.first else {
            throw DecodingError.dataCorruptedError(
                forKey: .emoji,
                in: container,
                debugDescription: "Failed to extract emoji from string"
            )
        }
        self.emoji = emoji
        self.note = try container.decode(String.self, forKey: .note)
        self.dayIndex = try container.decode(Int.self, forKey: .dayIndex)
        self.sortIndex = try container.decode(Int.self, forKey: .sortIndex)
    }
}
