import SwiftUI

private let emojis = (0x1F601...0x1F64F).compactMap { Unicode.Scalar($0) }.map { String($0) }

struct EmojiPickerView: View {
    
    @Environment(\.presentationMode)
    private var presentationMode
    
    @State
    private var selectedEmoji: String?
    
    var onSelect: (String) -> Void

    var body: some View {
        Picker(
            "Select an emoji",
            selection: $selectedEmoji
        ) {
            ForEach(emojis, id: \.self) { emoji in
                Text(emoji).font(.largeTitle)
            }
        }
            .pickerStyle(WheelPickerStyle())
            .onChange(
                of: selectedEmoji,
                perform: { newValue in
                    guard let newValue else { return }
                    
                    onSelect(newValue)
                    presentationMode.wrappedValue.dismiss()
                }
            )
    }
}
