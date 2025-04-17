import Foundation
import UIKit

protocol ProfilePresenterProtocol: AnyObject{
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func viewDidDisappear()
    func didTapLogoutButton()
}

final class ProfilePresenter: ProfilePresenterProtocol{
    var view: ProfileViewControllerProtocol?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    private let storage = OAuth2ServiceStorage.shared
    private let logoutService = ProfileLogoutService.shared
    private var alertPresenter: AlertPresenterProtocol?
    
    init(alertPresenter: AlertPresenterProtocol) {
           self.alertPresenter = alertPresenter
       }
    
    func viewDidLoad() {
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            view?.updateAvatar()
        }
        view?.updateAvatar()
    }
    
    func viewDidDisappear() {
        guard let profileImageServiceObserver else { return }
        NotificationCenter.default.removeObserver(profileImageServiceObserver)
    }
    
    func didTapLogoutButton() {
        let viewModel = AlertModel(title: "Пока!",
                                   message: "Уверены что хотите выйти?",
                                   button: "Да",
                                   completion: { self.logoutService.logout() },
                                   secondButton: "Нет",
                                   secondCompletion: { self.view?.dismiss() })
        alertPresenter?.showAlert(result: viewModel)

    }
    
    
}
