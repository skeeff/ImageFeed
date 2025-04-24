import UIKit

//protocol AuthViewControllerDelegate: AnyObject {
//    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
//}
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class SplashScreenViewController: UIViewController{
    
    private var logo: UIImageView?
    
    private let storage = OAuth2ServiceStorage.shared
    private let oAuth2Service = OAuth2Service.shared
    private let profile = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let token = storage.token else { return }
        fetchProfile(token)
        
        
        view.backgroundColor = UIColor(named:"YP Dark")
        setLogo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        chooseScreen()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    private func switchToTabBar(){
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window condig")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func switchToAuthViewController(){
        let authViewController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController
        
        guard let authViewController else { return }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true, completion: nil)
    }
    
    private func chooseScreen(){
        if let token = storage.token {
            fetchProfile(token)
        }else {
            switchToAuthViewController()
        }
    }
    
    private func setLogo(){
        let logo = UIImage(named: "Vector")
        let logoView = UIImageView(image: logo)
        logoView.backgroundColor = UIColor(named: "YP Dark")
        logoView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoView)
        
        logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        self.logo = logoView
    }
}

//extension SplashScreenViewController{
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
//        if segue.identifier == authSegueId {
//            guard
//                let navigationController = segue.destination as? UINavigationController,
//                let viewController = navigationController.viewControllers[0] as? AuthViewController
//            else {
//                assertionFailure("Failed to prepare for \(authSegueId)")
//                return
//            }
//            
//            viewController.delegate = self
//            
//        } else {
//            super.prepare(for: segue, sender: sender)
//        }
//    }
//}

extension SplashScreenViewController: AuthViewControllerDelegate {
    
    func didAuthenticate(_ vc: AuthViewController){
        vc.dismiss(animated: true)
        
        guard let token = storage.token else{
            return
        }
        fetchProfile(token)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        
        profile.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else{ return }
            
            switch result {
            case .success(let profile):
                print("Fetching profile image for username: \(profile.username)")
                profileImageService.fetchProfileImageURL(token: token, username: profile.username) { result in
                    switch result {
                    case .success(let url):
                        print("Successfully fetched image URL: \(url)")
                    case .failure(let error):
                        print("Failed to fetch image URL: \(error.localizedDescription)")
                    }
                }
                self.switchToTabBar()
                
            case.failure(let error):
                print("Couldnt get profile info,  \(error.localizedDescription)")
                break
            }
        }
    }
    
//    private func fetchProfileImageURL(username: String) {
//        guard let token = storage.token else {
//            print("invalid token")
//            return
//        }
//        avatar.fetchProfileImageURL(token: token, username: username) { result in
//            switch result {
//            case .success(let imageURL):
//                print("profile image url: ")
//                avatar.avatarURL = imageURL
//                
//            }
//            
//        }
//    }
    

}
