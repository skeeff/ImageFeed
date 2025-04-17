import XCTest
@testable import ImageFeed


final class ImagesListTests: XCTestCase {

    func testImagesListCellDidTapLike() {
        //given
        let presenter = ImagesListPresenterSpy()
        let viewController = ImagesListViewController()
        presenter.view = viewController
        let cell = ImagesListCell()
        let isLiked = presenter.isLiked
        
        //when
        presenter.imagesListDidTapLike(cell)
        
        //then
        XCTAssertNotEqual(isLiked, presenter.isLiked)
    }
    
    func testUpdateTableView() {
        //given
        let presenter = ImagesListPresenter(alertPresenter: AlertPresenter())
        let viewController = ImagesListViewController()
        presenter.view = viewController
        let imagesListService = ImagesListService.shared
        
        //when
        presenter.updateTableView()
        
        //then
        XCTAssertEqual(viewController.photos.count, imagesListService.photos.count)
    }
}


final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    func viewDidLoad() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    var view: ImagesListViewControllerProtocol?
    var isLiked: Bool = false
    let imagesListService = ImagesListService.shared
    let storage = OAuth2ServiceStorage.shared
    
    
    func imagesListDidTapLike(_ cell: ImagesListCell) {
        isLiked = true
    }
    
    func tableViewWillDisplay(indexPath: IndexPath) {
        
    }
    
    func updateTableView() {
        
    }
}
