import SwiftUI
import Combine

final class MindDetailsViewModel: ObservableObject {
    
    @Published
    var isLoading: Bool = false
    
    @Published
    var needToDismiss: Bool = false
    
    let mind: Mind
    private let service: MindService
    
    private var cancellable: AnyCancellable?
    
    init(mind: Mind, service: MindService) {
        self.mind = mind
        self.service = service
    }
    
    func deleteMind() {
        cancellable?.cancel()
        cancellable = nil
        
        isLoading = true
        
        cancellable = service.deleteMind(id: mind.uuid)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.needToDismiss = true
                }
            )
    }
}

struct MindDetailsView: View {
    
    @Environment(\.presentationMode)
    private var presentationMode: Binding<PresentationMode>
    
    @ObservedObject
    private var viewModel: MindDetailsViewModel
    
    init(viewModel: MindDetailsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(viewModel.mind.emoji.description).font(.largeTitle)
                Text(viewModel.mind.note).font(.body)
                Button(action: {
                    viewModel.deleteMind()
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Delete")
                    }
                }
            }
            .onChange(of: viewModel.needToDismiss) { needToDismiss in
                if needToDismiss {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
