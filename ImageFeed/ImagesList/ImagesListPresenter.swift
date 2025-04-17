import Foundation

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func viewDidDisappear()
    func imagesListDidTapLike(_ cell: ImagesListCell)
    func tableViewWillDisplay(indexPath: IndexPath)
    func updateTableView()
}

final class ImagesListPresenter: ImagesListPresenterProtocol{
    
    private let imagesListService = ImagesListService.shared
    private let storage = OAuth2ServiceStorage.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    weak var view: ImagesListViewControllerProtocol?
    
    init(alertPresenter: AlertPresenterProtocol) {
        self.alertPresenter = alertPresenter
    }
    
    func viewDidLoad(){
        imagesListServiceObserver = NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification, object: nil, queue: .main){ [weak self] _ in
            guard let self else { return }
            view?.updateTableViewAnimated()
        }
    }
    func viewDidDisappear() {
        guard let imagesListServiceObserver else { return }
        NotificationCenter.default.removeObserver(imagesListServiceObserver)
    }
    func imagesListDidTapLike(_ cell: ImagesListCell) {
        guard let token = storage.token else { return }
        guard let view else { return }
        guard let indexPath = view.tableView.indexPath(for: cell) else { return }
        let photo = view.photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(token: token, photoId: photo.id, isLiked: !photo.isLiked){[weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result{
            case .success(let isLiked):
                view.photos[indexPath.row].isLiked = isLiked
                cell.setIsLiked(isLiked: isLiked)
            case .failure(let error):
                let alert = AlertModel(title: "Что-то пошло не так",
                                       message: "Проверьте свое соединение с интернетом\n\(error)",
                                       button: "Попробовать снова"){}
                alertPresenter?.showAlert(result: alert)
                print(error.localizedDescription)
                print("counldn change state of like(imageList vc)")
            }
        }
    }
    func tableViewWillDisplay(indexPath: IndexPath) {
        guard let token = storage.token else { return }
        
        if indexPath.row + 1 == view?.photos.count {
            imagesListService.fetchPhotosNextPage(token: token)
        }
    }
    func updateTableView() {
        guard let token = storage.token else { return }
        
        imagesListService.fetchPhotosNextPage(token: token)
        view?.updateTableViewAnimated()
    }
    
    
}
