import SwiftUI
import Combine

final class MindDetailsViewModel: ObservableObject {
    
    @Published
    private(set) var isLoading: Bool = false
    
    @Published
    private(set) var needToDismiss: Bool = false
    
    @Published
    private(set) var readyToDelete: Bool = false
    
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
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { [weak self] _ in
                    self?.needToDismiss = true
                }
            )
    }
    
    func prepareToDelete() {
        readyToDelete = true
    }
}

struct MindDetailsView: View {
    
    @Environment(\.presentationMode)
    private var presentationMode: Binding<PresentationMode>
    
    @ObservedObject
    private var viewModel: MindDetailsViewModel
    
    private var onDelete: (String) -> Void
    
    init(
        viewModel: MindDetailsViewModel,
        onDelete: @escaping (String) -> Void
    ) {
        self.viewModel = viewModel
        self.onDelete = onDelete
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(viewModel.mind.emoji.description).font(.largeTitle)
                Text(viewModel.mind.note).font(.body)
                Button(action: {
                    if viewModel.readyToDelete {
                        viewModel.deleteMind()
                    } else {
                        viewModel.prepareToDelete()
                    }
                }) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text("Delete")
                    }
                }
                    .background(viewModel.readyToDelete ? Color.red : Color.clear)
                    .cornerRadius(viewModel.readyToDelete ? 10.0 : 0.0)
            }
                .onChange(of: viewModel.needToDismiss) { needToDismiss in
                    onDelete(viewModel.mind.uuid)
                    if needToDismiss {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
        }
    }
}
