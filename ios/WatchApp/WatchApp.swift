import SwiftUI

@main
struct WatchApp: App {
    
    // TODO: убрать в DI
    private let mindService: MindService = MindMobileChannelService(
        mobileCommunicationManager: MobileCommunicationManager()
    )
    
    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: MainViewModel(service: mindService)
            )
        }
    }
}
