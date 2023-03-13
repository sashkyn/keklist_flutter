import Foundation
import Combine

// TODO: передалать во Future

protocol MindService {
    var errors: AnyPublisher<Error, Never> { get }
    
    func obtainTodayMinds() -> AnyPublisher<[Mind], Never>
    func createNewMind(text: String, emoji: String) -> AnyPublisher<Void, Never>
    func deleteMind(id: String) -> AnyPublisher<Void, Never>
}

final class MindMobileChannelService: MindService {
    
    var errors: AnyPublisher<Error, Never> {
        mobileCommunicationManager.errors
    }
    
    private let mobileCommunicationManager: MobileCommunicationManager
    
    init(mobileCommunicationManager: MobileCommunicationManager) {
        self.mobileCommunicationManager = mobileCommunicationManager
    }
    
    func obtainTodayMinds() -> AnyPublisher<[Mind], Never> {
        mobileCommunicationManager.send(
            message: ["method": "obtainTodayMinds"]
        )
        
        return mobileCommunicationManager.messages
            .filter { $0.name == "displayMinds" }
            .map { $0.arguments }
            .compactMap { arguments in
                guard let mindsJSONString = arguments["minds"] as? String else {
                    return nil
                }
                let mindsJSONData = mindsJSONString.data(using: .utf8)
                return mindsJSONData
            }
            .flatMap { jsonData in
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                return Just(jsonData)
                    .decode(type: [Mind].self, decoder: decoder)
                    .catch { error in Just([]) }
            }
            .first()
            .eraseToAnyPublisher()
    }
    
    func createNewMind(text: String, emoji: String) -> AnyPublisher<Void, Never> {
        print("mindService createNewMind: \(text) \(emoji)")
        return Just(()).eraseToAnyPublisher()
    }
    
    func deleteMind(id: String) -> AnyPublisher<Void, Never> {
        Just(()).eraseToAnyPublisher()
    }
}
