import Foundation
import SwiftUI
import Combine

final class MindCreatorViewModel: ObservableObject {
    
    @Published
    var textToCreateMind: String? = nil
    
    @Published
    var pickedEmoji: String? = nil
    
    @Published
    var needToDismiss: Bool = false
    
    let service: MindService
    private var cancellable: AnyCancellable?
    
    init(service: MindService) {
        self.service = service
        
        self.cancellable = Publishers.CombineLatest(
            textToCreateMind.publisher,
            pickedEmoji.publisher
        )
            .flatMap { text, emoji in
                service.createNewMind(text: text, emoji: emoji)
            }
            .replaceError(with: ()) // TODO: сделать обработку ошибок
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.needToDismiss = true
            }
    }
    
    func showEnterText() {
        WKExtension.shared()
            .visibleInterfaceController?
            .presentTextInputController(
                withSuggestions: [],
                allowedInputMode: .plain
            ) { result in
                guard let result = result as? [String],
                      let resultText = result.first else {
                    self.textToCreateMind = ""
                    return
                }
                
                self.textToCreateMind = resultText
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
            if let mindText = viewModel.textToCreateMind {
                EmojiPickerView(
                    onSelect: { emoji in viewModel.pickedEmoji = emoji },
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
        }
        
    }
}
