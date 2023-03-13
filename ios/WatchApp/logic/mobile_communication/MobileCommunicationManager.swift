import Foundation
import Combine
import WatchConnectivity

final class MobileCommunicationManager: NSObject {
    
    var messages: AnyPublisher<MethodData, Never> {
        messagesSubject.eraseToAnyPublisher()
    }
    
    var errors: AnyPublisher<Error, Never> {
        errorsSubject.eraseToAnyPublisher()
    }
    
    private let messagesSubject = PassthroughSubject<MethodData, Never>()
    private let errorsSubject = PassthroughSubject<Error, Never>()
    
    private let session: WCSession
    
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        
        self.session.delegate = self
        self.session.activate()
    }
    
    func send(message: [String: Any]) {
        session.sendMessage(
            message,
            replyHandler: nil,
            errorHandler: { [weak self] error in
                self?.errorsSubject.send(error)
            }
        )
    }
    
    func handle(message: [String : Any]) {
        guard let methodName = message["method"] as? String else {
            return
        }
        
        var message = message
        message.removeValue(forKey: "method")
        
        let method = MethodData(name: methodName, arguments: message)
        messagesSubject.send(method)
    }
}

extension MobileCommunicationManager: WCSessionDelegate {
    
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

struct MethodData {
    var name: String
    var arguments: [String: Any]
}
