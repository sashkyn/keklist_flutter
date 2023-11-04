import Foundation

enum MethodError: LocalizedError {
    case notAuthorized
    case notPaired
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "You are not authorized in Mobile app. Plese, open the app and make sign in."
        case .notPaired:
            return "Mobile and Watch are not paired."
        case .unknown:
            return "Unknown error"
        }
    }
}
