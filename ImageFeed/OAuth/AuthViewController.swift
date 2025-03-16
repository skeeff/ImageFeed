import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
}

final class AuthViewController: UIViewController {
    
    private let oAuth2Service = OAuth2Service.shared
    private let oAuth2ServiceStorage = OAuth2ServiceStorage.shared
    weak var delegate: AuthViewControllerDelegate?
    let segueShowWebViewId = "ShowWebView"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureBackButton()
    }
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(animated)
    //        configureBackButton()
    //    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueShowWebViewId {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare for \(segueShowWebViewId)")
                return
            }
            webViewViewController.delegate = self
        }else{
            super.prepare(for: segue, sender: sender)
        }
    }
    
    //    private func configureBackButton() {
    //        let backButton = UIBarButtonItem(image: UIImage(named: "nav_back_button"),
    //                                         style: .plain,
    //                                         target: self,
    //                                         action: #selector(didTapBackButton))
    //        backButton.tintColor = UIColor(named: "YP Black")
    //        navigationItem.leftBarButtonItem = backButton
    //    }
    //
    //    @objc private func didTapBackButton() {
    //        navigationController?.popViewController(animated: true)
    //    }
    
    
    private func configureBackButton(){
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }
    
    
}


extension AuthViewController: WebViewViewControllerDelegate{
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String?) {
        
        DispatchQueue.global().async{
            guard let code else {
                print("Didnt get authorisation code")
                return
            }
            self.oAuth2Service.fetchOAuthToken(code: code) { result in
                switch result {
                case .success(let token):
                    print("token successfully gathered")
                    self.oAuth2ServiceStorage.token = token
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true)
                    }
                    
                case .failure(let error):
                    print("Couldnt get token: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
    
}
