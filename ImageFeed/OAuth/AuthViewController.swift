import UIKit
import ProgressHUD


final class AuthViewController: UIViewController {
    
    private let oAuth2Service = OAuth2Service.shared
    private let oAuth2ServiceStorage = OAuth2ServiceStorage.shared
    weak var delegate: AuthViewControllerDelegate?
    let segueShowWebViewId = "ShowWebView"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueShowWebViewId {
                guard
                    let webViewViewController = segue.destination as? WebViewViewController
                else {
                    assertionFailure("Failed to prepare for \(segueShowWebViewId)")
                    return
                }
                let authHelper = AuthHelper()
                let webViewPresenter = WebViewPresenter(authHelper: authHelper)
                webViewViewController.presenter = webViewPresenter
                webViewPresenter.view = webViewViewController
                webViewViewController.delegate = self
            } else {
                super.prepare(for: segue, sender: sender)
            }
    }
    
    
    private func configureBackButton(){
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    
}


extension AuthViewController: WebViewViewControllerDelegate{
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String?) {
        UIBlockingProgressHUD.show()
        
        DispatchQueue.global().async{
            guard let code else {
                print("Didnt get authorisation code")
                return
            }
            
            self.oAuth2Service.fetchOAuthToken(code: code) { result in
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success(let token):
                    print("token successfully gathered")
                    self.oAuth2ServiceStorage.token = token
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true){
                            self.delegate?.didAuthenticate(self)
                        }
                    }
                    
                case .failure(let error):
                    let alert = UIAlertController(
                        title: "Что-то пошло не так",
                        message: "Не удалось войти в систему",
                        preferredStyle: .alert
                    )
                    let action = UIAlertAction(title: "Ok", style: .default)
                    alert.addAction(action)
                    DispatchQueue.main.async{
                        self.present(alert, animated: true)
                    }
                    print("Couldnt get token: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    
}
