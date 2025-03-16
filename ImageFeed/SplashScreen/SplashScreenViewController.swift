import UIKit

final class SplashScreenViewController: UIViewController{
    
    private var logo: UIImageView?
    private let authSegueId = "ShowAuthScreen"
    
    private let storage = OAuth2ServiceStorage.shared
    private let oAuth2Service = OAuth2Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(named:"YP Dark")
        setLogo()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token{
            switchToTabBar()
        } else {
            performSegue(withIdentifier: authSegueId, sender: nil)
        }
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
            assertionFailure("Invalid wimdow condig")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
               .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
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

extension SplashScreenViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == authSegueId {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(authSegueId)")
                return
            }
            
            viewController.delegate = self
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashScreenViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oAuth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBar()
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
}
