import Foundation
import Combine

// TODO: передалать во Future

protocol MindService {
    var errors: AnyPublisher<Error, Never> { get }
    
    func obtainTodayMinds() -> AnyPublisher<[Mind], Error>
    func obtainPredictedEmojies(text: String) -> AnyPublisher<[String], Error>
    func createNewMind(text: String, emoji: String) -> AnyPublisher<Void, Error>
    func deleteMind(id: String) -> AnyPublisher<Void, Error>
}

final class MindMobileChannelService: MindService {
    
    var errors: AnyPublisher<Error, Never> {
        mobileCommunicationManager.errors
    }
    
    private let mobileCommunicationManager: MobileCommunicationManager
    
    init(mobileCommunicationManager: MobileCommunicationManager) {
        self.mobileCommunicationManager = mobileCommunicationManager
    }
    
    func obtainTodayMinds() -> AnyPublisher<[Mind], Error> {
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
            }
            .first()
            .eraseToAnyPublisher()
    }
    
    func obtainPredictedEmojies(text: String) -> AnyPublisher<[String], Error> {
        mobileCommunicationManager.send(
            message: [
                "method": "obtainPredictedEmojies",
                "mindText": text,
            ]
        )
        
        return mobileCommunicationManager.messages
            .filter { $0.name == "displayPredictedEmojies" }
            .map { $0.arguments }
            .compactMap { arguments in
                guard let jsonString = arguments["emojies"] as? String else {
                    return nil
                }
                let jsonData = jsonString.data(using: .utf8)
                return jsonData
            }
            .flatMap { jsonData in
                let decoder = JSONDecoder()
                return Just(jsonData)
                    .decode(type: [String].self, decoder: decoder)
            }
            .first()
            .eraseToAnyPublisher()
    }
    
    func createNewMind(text: String, emoji: String) -> AnyPublisher<Void, Error> {
        mobileCommunicationManager.send(
            message: [
                "method": "createMind",
                "mindText": text,
                "mindEmoji": emoji,
            ]
        )
        
        return mobileCommunicationManager.messages
            .filter { $0.name == "mindDidCreated" }
            .map { _ in }
            .print("hehehehehe")
            .setFailureType(to: Error.self)
            .first()
            .eraseToAnyPublisher()
    }
    
    func deleteMind(id: String) -> AnyPublisher<Void, Error> {
        mobileCommunicationManager.send(
            message: [
                "method": "deleteMind",
                "id": id
            ]
        )
        
        return mobileCommunicationManager.messages
            .filter { $0.name == "mindDidDeleted" }
            .map { _ in }
            .setFailureType(to: Error.self)
            .first()
            .eraseToAnyPublisher()
    }
}
