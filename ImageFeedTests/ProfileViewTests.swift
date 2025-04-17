import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        presenter.view = viewController
        
        // when
        _ = viewController.view
        
        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    
    func testViewControllerUpdatesAvatar() {
        // given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController(presenter: presenter)
        _ = viewController.view
        
        // when
        let placeholderImage = UIImage(named: "avatar_placeholder")
        
        // then
        XCTAssertEqual(viewController.avatarImageView?.image?.pngData(), placeholderImage?.pngData())
    }
}


final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var updatedProfile: Profile?
    
    func updateProfileInformation(profile: Profile) {
        updatedProfile = profile
    }
    
    func updateAvatar() {
        // Имитация обновления аватарки
    }
    
    func dismiss() {
        // Имитация закрытия экрана
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func viewDidDisappear() {
    }
    
    func didTapLogoutButton() {
    }
}

