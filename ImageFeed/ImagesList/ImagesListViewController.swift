

import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    var tableView: UITableView! { get set }
    var photos: [Photo] { get set }
    func updateTableViewAnimated()
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    //MARK: @IBOutlet properties
    @IBOutlet  weak var tableView: UITableView!
    //MARK: constants
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let currentDate = Date()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let imagesListService = ImagesListService.shared
    var photos: [Photo] = []
    private let storage = OAuth2ServiceStorage.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    var presenter: ImagesListPresenterProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        
        tableView.rowHeight = 200
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        loadNextPhotosIfNeeded()
        updateTableView()
    }
    
    private func showSingleImageViewController(indexPath: IndexPath) {
        let viewController = SingleImageViewController()
        guard let imageURL = URL(string: photos[indexPath.row].largeImageURL) else { return }
        viewController.largeImageURL = imageURL
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .crossDissolve
        present(viewController, animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter?.viewDidDisappear()
        // NotificationCenter.default.removeObserver(imagesListServiceObserver)
    }
    
}
//MARK: extensions
extension ImagesListViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSingleImageViewController(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let thumbImage = photos[indexPath.row].thumbSize
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = thumbImage.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = thumbImage.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath) as? ImagesListCell else {
            return UITableViewCell()
        }
        
        cell.delegate = self
        cell.configCell(photo: photos[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.tableViewWillDisplay(indexPath: indexPath)
    }
    
    
}

extension ImagesListViewController {
     func updateTableViewAnimated(){
        DispatchQueue.main.async{ [weak self] in
            guard let self else { return }
            let oldCount = photos.count
            let newCount = imagesListService.photos.count
            photos = imagesListService.photos
            if oldCount != newCount{
                tableView.performBatchUpdates{
                    let indexPaths = (oldCount..<newCount).map{ i in
                        IndexPath(row: i, section: 0)
                    }
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                }completion: { _ in }
            }
            
        }
    }
    private func updateTableView(){
        presenter?.updateTableView()
    }
    
    private func loadNextPhotosIfNeeded() {
        guard let token = storage.token else { return }
        guard imagesListService.task == nil else { return }
        
        imagesListService.fetchPhotosNextPage(token: token)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        presenter?.imagesListDidTapLike(cell)

    }
}
