import Foundation
import SwiftUI
import Combine

final class MindCreatorViewModel: ObservableObject {
    
    @Published
    var textToCreateMind: String? = nil
    
    @Published
    var pickedEmoji: String? = nil
    
    @Published
    var isLoading: Bool = false
    
    @Published
    var needToDismiss: Bool = false
    
    let service: MindService
    let onCreate: (Mind) -> Void
    
    private var cancellable: AnyCancellable?
    
    init(
        service: MindService,
        onCreate: @escaping (Mind) -> Void
    ) {
        self.service = service
        self.onCreate = onCreate
    }
    
    func subscribeToData() {
        cancellable?.cancel()
        cancellable = nil
        
        cancellable = Publishers.CombineLatest(
            $textToCreateMind
                .compactMap { $0 },
            $pickedEmoji
                .compactMap { $0 }
                .filter { !$0.isEmpty }
        )
            .flatMap { [unowned self] text, emoji in
                self.isLoading = true
                return self.service.createNewMind(
                    text: text,
                    emoji: emoji
                )
            }
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in }, // TODO: сделать обработку ошибок
                receiveValue: { [weak self] mind in
                    self?.needToDismiss = true
                    self?.onCreate(mind)
                }
            )
    }
    
    func showEnterText() {
        WKExtension.shared()
            .visibleInterfaceController?
            .presentTextInputController(
                withSuggestions: [],
                allowedInputMode: .plain
            ) { [weak self] result in
                guard let result = result as? [String],
                      let resultText = result.first else {
                    self?.textToCreateMind = ""
                    self?.needToDismiss = true
                    
                    return
                }
                
                self?.textToCreateMind = resultText
            }
    }
}

struct MindCreatorView: View {

    @Environment(\.presentationMode)
    private var presentationMode: Binding<PresentationMode>
    
    @ObservedObject
    var viewModel: MindCreatorViewModel
    
    var body: some View {
        NavigationView {
            if viewModel.isLoading {
                LoadingView(text: "Creating...")
                    .navigationTitle("")
            } else if let mindText = viewModel.textToCreateMind {
                EmojiPickerView(
                    onSelect: { emoji in
                        viewModel.pickedEmoji = emoji
                    },
                    viewModel: EmojiPickerViewModel(
                        service: viewModel.service,
                        mindText: mindText
                    )
                )
            }
        }
            .onChange(of: viewModel.needToDismiss) { needToDismiss in
                if needToDismiss {
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .onAppear {
                viewModel.showEnterText()
                viewModel.subscribeToData()
            }
    }
}
