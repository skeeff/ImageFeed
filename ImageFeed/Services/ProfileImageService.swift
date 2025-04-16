import Foundation

final class ProfileImageService {
    
    //MARK: singletone
    static let shared = ProfileImageService()
    
    private init() { }
    
    //MARK: Properties
    private var task: URLSessionTask?
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    //MARK: Methods
    func makeProfileImageRequest(token: String, username: String) -> URLRequest?{
        guard let url = URL(string: "/users/\(username)", relativeTo: Constants.defaultBaseURL) else {
            assertionFailure("Couldnt generaate url")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfileImageURL(token: String, username: String, _ completion: @escaping (Result<String, Error>) -> Void){
        DispatchQueue.main.async {
            assert(Thread.isMainThread)
        }
        
        guard task == nil else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        guard let urlRequest = makeProfileImageRequest(token: token, username: username) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            }
            return
        }
        print("Making request to: \(urlRequest.url?.absoluteString ?? "nil")")
        
        let task = URLSession.shared.objectTask(for: urlRequest) { [weak self] (result: Result<UserResult,Error>)  in
            DispatchQueue.main.async{
                guard let self else { return }
                switch result{
                case .success(let image):
                    let profileImageURL = image.profileImage.small
                    self.avatarURL = profileImageURL
                    NotificationCenter.default
                        .post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImageURL])
                    print("image data successfully decoded")
                    
                case .failure(let error):
                    completion(.failure(error))
                    print(NSError(domain: "couldnt decode data", code: 0, userInfo: nil))
                }
                self.task = nil
            }
        }
        
        self.task = task
        task.resume()
    }
    
}

extension ProfileImageService{
    func cleanProfileImage(){
        self.avatarURL = nil
    }
}
