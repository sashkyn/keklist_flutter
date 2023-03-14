import Foundation
import SwiftUI
import Combine

final class MindCreatorViewModel: ObservableObject {
    
    @Published
    var textToCreateMind: String? = nil
    
    @Published
    var pickedEmoji: String? = nil
    
    var needToDismiss: Bool = false
    
    let service: MindService
    
    private var cancellable: AnyCancellable?
    
    init(service: MindService) {
        self.service = service
    }
    
    func subscribeToData() {
        cancellable?.cancel()
        cancellable = nil
        
        self.cancellable = Publishers.CombineLatest(
            $textToCreateMind
                .compactMap { $0 },
            $pickedEmoji
                .compactMap { $0 }
                .filter { !$0.isEmpty }
        )
            .flatMap { [unowned self] text, emoji in
                self.service.createNewMind(
                    text: text,
                    emoji: emoji
                )
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
            if let mindText = viewModel.textToCreateMind {
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
