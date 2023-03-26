import SwiftUI
import Combine

final class EmojiPickerViewModel: ObservableObject {

    @Published
    var emojies: [String] = []
    
    @Published
    var errorText: String? = nil
    
    @Published
    var isLoading: Bool = true
    
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
                    self?.isLoading = false
                },
                receiveValue: { [weak self] emojies in
                    self?.emojies = emojies
                    self?.isLoading = false
                }
            )
    }
}

struct EmojiPickerView: View {
    
    var onSelect: (String) -> Void
    
    @ObservedObject
    var viewModel: EmojiPickerViewModel
    
    var body: some View {
        if viewModel.isLoading {
            LoadingView(text: "Analyzing text...")
                .onAppear {
                    viewModel.obtainPredictedEmojies()
                }
        } else if let errorText = viewModel.errorText {
            ErrorView(
                retryAction: { viewModel.obtainPredictedEmojies() },
                errorLabel: { Text("\(errorText)") }
            )
        } else {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.emojies, id: \.self) { emoji in
                        Button(
                            action: { onSelect(emoji) },
                            label: { Text(emoji).font(.headline) }
                        )
                    }
                }
            }
                .navigationTitle(!viewModel.isLoading ? "Select an emoji" : "") // INFO: какой то баг с висящим Select an emoji
        }
    }
}
