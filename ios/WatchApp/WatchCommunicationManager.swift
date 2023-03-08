import Foundation
import WatchConnectivity

final class WatchCommunicationManager: NSObject {
    private let session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        
        self.session.delegate = self
        self.session.activate()
    }
    
    func obtainTodayMinds() {
        session.sendMessage(
            [
                "method": "obtainTodayMinds"
//                "data": ["text": "heheheeheheheheheeheh"]
            ],
            replyHandler: nil,
            errorHandler: nil
        )
    }
}

extension WatchCommunicationManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("AppDelegate WC: activationDidCompleteWith - \(activationState)")
    }

    // MARK: чтобы запускалось из VS Code - Flutter
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("AppDelegate WC: sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("AppDelegate WC: sessionDidDeactivate")
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("WatchCommunicationManager didReceiveMessage - \(message)")
    }
}
