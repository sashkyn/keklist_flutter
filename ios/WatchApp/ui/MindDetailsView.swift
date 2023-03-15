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
        cancellable = service.deleteMind(id: mind.uuid)
            .sink(
                receiveCompletion: {
                    print($0)
                },
                receiveValue: { [weak self] _ in
                    self?.isLoading = false
                }
            )
    }
}

struct MindDetailsView: View {
    
    @Environment(\.presentationMode)
    private var presentationMode: Binding<PresentationMode>
    
    @ObservedObject
    private var viewModel: MindDetailsViewModel
    
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
            }.onChange(of: viewModel.needToDismiss) { needToDismiss in
                if needToDismiss {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
