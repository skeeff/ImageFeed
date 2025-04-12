import UIKit

final class TabBarController: UITabBarController {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController")
        imagesListViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "feed_tab_active"), selectedImage: nil)
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(title: "", image: UIImage(named: "profile_tab_active"), selectedImage: nil)
        
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
}
