import Foundation
import WatchConnectivity

final class WatchCommunicationManager: NSObject {
    var onReceiveMinds: (([Mind]) -> ())?
    
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
    
    func handle(message: [String : Any]) {
        guard let methodName = message["method"] as? String else {
            return
        }
        
        switch methodName {
        case "displayMinds":
            guard let mindsJsonString = message["minds"] as? String else {
                return
            }
            
            guard let mindsJsonData = mindsJsonString.data(using: .utf8) else {
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let minds = try decoder.decode([Mind].self, from: mindsJsonData)
                self.onReceiveMinds?(minds)
            } catch {
                print("error - \(error)")
            }
        case "showLoading":
            print(message)
        case "showError":
            print(message)
        default:
            print(message)
        }
    }
}

extension WatchCommunicationManager: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("AppDelegate WC: activationDidCompleteWith - \(activationState)")
    }

    // MARK: чтобы запускалось из VS Code, запуская Flutter-приложение
    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("AppDelegate WC: sessionDidBecomeInactive")
    }

    func sessionDidDeactivate(_ session: WCSession) {
        print("AppDelegate WC: sessionDidDeactivate")
    }
    #endif
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("WatchCommunicationManager didReceiveMessage - method - \(message["method"] ?? "nil")")
        handle(message: message)
    }
}
