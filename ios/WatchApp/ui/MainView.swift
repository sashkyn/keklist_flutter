import SwiftUI
import Combine

// TODO: сделать автоопредение эмоджи по тексту, попросить ChatGPT
// TODO: сделать аккуратное удаление Эмодзи
// TODO: сделать переподключения при ошибках соединения с приложением

final class MainViewModel: ObservableObject {
    
    @Published
    var minds: [Mind] = []
    
    @Published
    var isLoading: Bool = true
    
    @Published
    var errorText: String?

    let service: MindService
    private var cancellable: AnyCancellable?
    private var errorCancellable: AnyCancellable?
    
    init(service: MindService) {
        self.service = service
        
        errorCancellable = service.errors
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                self?.errorText = error.errorDescription
            }
    }
    
    func obtainTodayMinds() {
        cancellable?.cancel()
        cancellable = nil
        
        errorText = nil
        isLoading = true
        
        cancellable = service.obtainTodayMinds()
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
                receiveValue: { [weak self] minds in
                    guard let self else { return }
                    
                    self.minds = minds
                    self.isLoading = false
                }
            )
    }
}

struct MainView: View {
    
    @ObservedObject
    var viewModel: MainViewModel
    
    var body: some View {
        NavigationView {
            if let errorText = viewModel.errorText {
                ErrorView(
                    retryAction: { viewModel.obtainTodayMinds() },
                    errorLabel: { Text(errorText) }
                )
            } else if viewModel.isLoading {
                LoadingView(text: "Connecting...")
                    .onAppear { viewModel.obtainTodayMinds() }
            } else {
                MindCollectionView(viewModel: viewModel)
                    .navigationTitle("Minds")
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}

// MARK: Generation of minds

//let emojis: [Character] = ["😊", "🤔", "😍", "🤯", "🧘‍♀️"]
//let notes: [String] = ["Feeling great today!", "Can't seem to focus on anything.", "Just got some exciting news!", "Mind blown by the latest tech.", "Meditated for 20 minutes."]
//var minds: [Mind] = []
//
//for i in 0..<30 {
//    let uuid = UUID().uuidString
//    let emoji = emojis.randomElement()!
//    let note = notes.randomElement()!
//    let dayIndex = i % 7
//    let sortIndex = Int.random(in: 0..<100)
//    let mind = Mind(uuid: uuid, emoji: emoji, note: note, dayIndex: dayIndex, sortIndex: sortIndex)
//    minds.append(mind)
//}
//isLoading = false
//self.minds = minds
