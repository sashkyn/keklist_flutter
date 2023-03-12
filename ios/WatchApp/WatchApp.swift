import SwiftUI

@main
struct WatchApp: App {
    
    // TODO: убрать в DI
    private let mindService: MindService = MindFlutterChannelService(
        mobileCommunicationManager: MobileCommunicationManager()
    )
    
    var body: some Scene {
        WindowGroup {
            MainView(service: mindService)
        }
    }
}
