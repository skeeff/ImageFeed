import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        
       
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        imagesListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "feed_tab_active"), selectedImage: nil)
        if let imagesListVC = imagesListViewController as? ImagesListViewController {
            let imagesListPresenter = ImagesListPresenter(alertPresenter: alertPresenter)
            imagesListVC.presenter = imagesListPresenter
            imagesListPresenter.view = imagesListVC
        }
        let profilePresenter = ProfilePresenter(alertPresenter: alertPresenter)
        let profileViewController = ProfileViewController(presenter: profilePresenter)
        profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile_tab_active"), selectedImage: nil)
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
}
