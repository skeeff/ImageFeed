import Foundation

final class ProfileService {
    //MARK: Singletone
    static let shared = ProfileService()
    
    private init() { }
    //MARK: Properties 
    private var task: URLSessionTask?
    private(set) var profile: Profile?
        

    //MARK: Methods
    func makeProfileRequest(token: String) -> URLRequest? { 
        guard let url = URL(string: "/me", relativeTo: Constants.defaultBaseURL) else {
            assertionFailure("Couldnt generaate url")
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        DispatchQueue.main.async {
            assert(Thread.isMainThread)
        }
        
        guard task == nil else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        guard let urlRequest = makeProfileRequest(token: token) else{
            DispatchQueue.main.async{
                completion(.failure(NSError(domain: "Invalid request", code: 0, userInfo: nil)))
            }
            return
        }
        
        let task = URLSession.shared.objectTask(for: urlRequest) {[weak self] (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async{
                guard let self else { return }
                switch result {
                case .success(let profileResult):
                    let profile = Profile(profileResult: profileResult)
                    self.profile = profile
                    completion(.success(profile))
                    print("profile data fetched successfully")
                    
                case .failure(let error):
                    completion(.failure(error))
                    print(NSError(domain: "decodin error", code: 0, userInfo: nil))
                }
                self.task = nil
            }
        }
        
//        let task = URLSession.shared.dataTask(with: urlRequest) {[weak self] data, response, error in
//            guard let data = data else {
//                DispatchQueue.main.async{
//                    completion(.failure(NSError(domain: "No data received", code: 0, userInfo: nil)))
//                }
//                return
//            }
//            if let error = error {
//                DispatchQueue.main.async{
//                    completion(.failure(error))
//                }
//                print(error.localizedDescription)
//            }
//            
//            if let jsonString = String(data: data, encoding: .utf8){
//                print("JSON = \(jsonString)")
//            } else {
//                print("Failed to convert data")
//            }
//            
//            do {
//                let decoder = JSONDecoder()
//                // decoder.keyDecodingStrategy = .convertFromSnakeCase
//                let profileResult = try decoder.decode(ProfileResult.self, from: data)
//                let profile = Profile(profileResult: profileResult)
//                DispatchQueue.main.async {
//                    self?.profile = profile
//                    completion(.success(profile))
//                }
//            } catch let error as DecodingError {
//                switch error {
//                case .keyNotFound(let key, let context):
//                    print("Отсутствует ключ: \(key.stringValue), \(context.debugDescription)")
//                case .typeMismatch(let type, let context):
//                    print("Несовпадение типа \(type), \(context.debugDescription)")
//                case .valueNotFound(let type, let context):
//                    print("Отсутствует значение типа \(type), \(context.debugDescription)")
//                case .dataCorrupted(let context):
//                    print("Данные повреждены: \(context.debugDescription)")
//                @unknown default:
//                    print("Неизвестная ошибка: \(error.localizedDescription)")
//                }
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//            } catch {
//                DispatchQueue.main.async {
//                    completion(.failure(error))
//                }
//                print(error.localizedDescription)
//            }
//
//            self?.task = nil
//        }
        
        self.task = task
        task.resume()
    }
}

enum ProfileServiceError: Error {
    case invalidRequest
}
