import SwiftUI
import Combine

final class EmojiPickerViewModel: ObservableObject {

    @Published
    var emojies: [String] = []
    
    @Published
    var errorText: String? = nil
    
    @Published
    var isLoading: Bool = false
    
    private var cancellable: AnyCancellable?
    
    private let service: MindService
    private let mindText: String
    
    init(service: MindService, mindText: String) {
        self.service = service
        self.mindText = mindText
    }
    
    func obtainPredictedEmojies() {
        cancellable?.cancel()
        cancellable = nil
        
        isLoading = true
        errorText = nil
        
        cancellable = service.obtainPredictedEmojies(text: mindText)
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.errorText = "\(error)"
                    default:
                        return
                    }
                },
                receiveValue: { [weak self] emojies in
                    self?.emojies = emojies
                }
            )
    }
}

struct EmojiPickerView: View {
    
    @State
    private var selectedEmoji: String?
    
    var onSelect: (String) -> Void
    
    @ObservedObject
    var viewModel: EmojiPickerViewModel

    var body: some View {
        LazyVStack {
            if viewModel.isLoading {
                ProgressView()
            } else if let errorText = viewModel.errorText {
                Text("\(errorText)")
            } else {
                ForEach(viewModel.emojies, id: \.self) { emoji in
                    Text(emoji).font(.largeTitle)
                        .onTapGesture {
                            onSelect(emoji)
                        }
                }
            }
        }.onAppear {
            viewModel.obtainPredictedEmojies()
        }
    }
}
