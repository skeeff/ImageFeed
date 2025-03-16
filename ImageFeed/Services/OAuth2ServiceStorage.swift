import Foundation

final class OAuth2ServiceStorage {
    static let shared = OAuth2ServiceStorage()
    
    private init() {}
    
    private let storage = UserDefaults.standard
    
    private enum StorageKey: String{
        case token
    }
    
    var token: String? {
        get{
            storage.string(forKey: StorageKey.token.rawValue)
        }
        set{
            guard let newValue else {
                return
            }
            storage.set(newValue, forKey: StorageKey.token.rawValue)
        }
    }
}
