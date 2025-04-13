import Foundation

final class ImagesListService{
    //MARK: Singletone
    static let shared = ImagesListService()
    private init() { }
    //MARK: Properties
    
    private(set) var photos : [Photo] = []
    private var lastLoadedPage : Int?
    private var task: URLSessionTask?
    private let dateFormatter = DateFormatter.dateFormatter
    
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func makePhtosRequest(token: String, page: Int) -> URLRequest? {
        guard let url = URL(string: "/photos?page=\(page)", relativeTo: Constants.defaultBaseURL) else {
            assertionFailure("couldnt generate url")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func nextPageNumber() -> Int{
        guard let lastLoadedPage else { return 1 }
        return lastLoadedPage + 1
    }
    
    func convertFromPhotoResult(photoResult: PhotoResult) -> Photo {
        let thumbWidth = 200.0
        let aspectRatio = Double(photoResult.height)/Double(photoResult.width)
        let thumbHeight = thumbWidth / aspectRatio
        
        return Photo(
            id: photoResult.id,
            size: CGSize(width: Double(photoResult.width),
                         height: Double(photoResult.height)),
            createdAt: dateFormatter.date(from: photoResult.createdAt ?? ""),
            welcomeDescription: photoResult.description,
            thumbImageURL: photoResult.urls.small,
            largeImageURL: photoResult.urls.full,
            isLiked: photoResult.likedByUser
        )
    }
    
    func fetchPhotosNextPage(token: String){
        DispatchQueue.main.async{
            assert(Thread.isMainThread)
        }
        
        let nextPage = nextPageNumber()
        
        guard task == nil else{
            print(AuthServiceError.invalidRequest)
            return
        }
        
        guard let urlRequest = makePhtosRequest(token: token, page: nextPage) else{
            print(AuthServiceError.invalidRequest)
            print("invalid photos request")
            return
        }
        
        let task = URLSession.shared.objectTask(for: urlRequest){ [weak self] (result:Result<[PhotoResult], Error>) in
            guard let self else { return }
            switch result{
            case .success(let photoResult):
                DispatchQueue.main.async{
                    var photos: [Photo] = []
                    photoResult.forEach {
                        photo in photos.append(self.convertFromPhotoResult(photoResult: photo)) }
                    NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                    self.photos += photos
                    self.lastLoadedPage = nextPage
                    print("photos decoded successfully")
                }
                
            case .failure(let error):
                print("Error occurred \(error)")
            }
            self.task = nil
        }
        self.task = task
        task.resume()
    }
    
}
