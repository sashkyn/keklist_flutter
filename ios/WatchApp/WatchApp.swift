import SwiftUI

@main
struct WatchApp: App {
    
    // TODO: убрать в DI
    private let mindService: MindService = MindMobileChannelService(
        mobileCommunicationManager: MobileAppCommunicationManager()
    )
    
    var body: some Scene {
        WindowGroup {
            MainView(
                viewModel: MainViewModel(service: mindService)
            )
        }
    }
}
