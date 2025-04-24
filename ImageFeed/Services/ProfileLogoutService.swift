import Foundation
import WebKit

final class ProfileLogoutService {
    //MARK: Properties
    private let storage = OAuth2ServiceStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService.shared
    //MARK: Singletone
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    
    func logout(){
        storage.cleanToken()
        profileService.cleanProfile()
        profileImageService.cleanProfileImage()
        imagesListService.cleanImagesList()
        cleanCookies()
        showSplashScreen()
    }
    
    func cleanCookies(){
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()){ records in
            records.forEach{ record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: { })
                
            }
        }
    }
    
    func showSplashScreen(){
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else{
            assertionFailure("Invalid Configuration")
            return
        }
        window.rootViewController = SplashScreenViewController()
    }
    
}
