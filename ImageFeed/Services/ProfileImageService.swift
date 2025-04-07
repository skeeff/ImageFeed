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
        
        let task = URLSession.shared.dataTask(with: urlRequest){ [weak self] data, response, error in
            
            if let error = error {
                DispatchQueue.main.async{
                    completion(.failure(error))
                }
                print(error.localizedDescription)
                self?.task = nil
                return
            }
            
            guard let data = data else {
                DispatchQueue.main.async{
                    completion(.failure(NSError(domain: "No data/corrupted data", code: 0, userInfo: nil)))
                }
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8){
                print("JSON IMAGE = \(jsonString)")
            } else {
                print("failed to convert data \(data)")
            }
            
            do{
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let profileImageData = try decoder.decode(UserResult.self, from: data)
                let profileImage = profileImageData.profileImage.small
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["URL": profileImage])
                DispatchQueue.main.async {
                    self?.avatarURL = profileImage
                    completion(.success(profileImage))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                print(error.localizedDescription)
            }
            self?.task = nil
        }
        self.task = task
        task.resume()
    }
    
}
