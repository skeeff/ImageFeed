

import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    //MARK: @IBOutlet properties
    @IBOutlet private weak var tableView: UITableView!
    //MARK: constants
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    private let currentDate = Date()
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private let imagesListService = ImagesListService.shared
    var photos: [Photo] = []
    private let storage = OAuth2ServiceStorage.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(forName: ImagesListService.didChangeNotification, object: nil, queue: .main){ [weak self] _ in
            guard let self else { return }
            self.updateTableView()
        }
        
        
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        loadNextPhotosIfNeeded()
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
//        if cell.configCell(photo: photos[indexPath.row]){
//     tableView.reloadRows(at: [indexPath], with: .automatic)
//        }
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            loadNextPhotosIfNeeded()
        }
    }
    
    
}
extension ImagesListViewController{
    //    private func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
    //        guard let image = UIImage(named: photosName[indexPath.row]) else {
    //            return
    //        }
    //
    //        cell.cellImage.image = image
    //        cell.dateLabel.text = dateFormatter.string(from: currentDate)
    //
    //        let isLiked = indexPath.row % 2 == 0
    //        let likeImage = isLiked ? UIImage(named: "liked") : UIImage(named: "notLiked")
    //        cell.likeButton.setImage(likeImage, for: .normal)
    //    }
}

extension ImagesListViewController {
    private func updateTableViewAnimated(){
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
        guard let token = storage.token else { return }
        //        imagesListService.fetchPhotosNextPage(token: token)
        self.updateTableViewAnimated()
    }
    
    private func tableViewWillDisplay(indexPath: IndexPath){
        guard let token = storage.token else{ return }
        
        if indexPath.row + 1 == photos.count{
            imagesListService.fetchPhotosNextPage(token: token)
        }
    }
    
    private func loadNextPhotosIfNeeded() {
        guard let token = storage.token else { return }
        guard imagesListService.task == nil else { return }
        
        imagesListService.fetchPhotosNextPage(token: token)
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let token = storage.token else { return }
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(token: token, photoId: photo.id, isLiked: !photo.isLiked){[weak self] result in
            guard let self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result{
            case .success(let isLiked):
                self.photos[indexPath.row].isLiked = isLiked
                cell.setIsLiked(isLiked: isLiked)
            case .failure(let error):
                let alert = UIAlertController(title: "Что-то пошло не так", message: "Проверьте соединение с интернетом", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ок", style: .default)
                alert.addAction(action)
                DispatchQueue.main.async{
                    self.present(alert, animated: true)
                }
                print(error.localizedDescription)
                print("counldn change state of like(imageList vc)")
            }
        }
    }
}
