import UIKit

final class OAuth2Service {
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    
    static let shared = OAuth2Service()
    private init() { }
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: "https://unsplash.com") else {
            return nil
        }
        
        var components = URLComponents()
        components.path = "/oauth/token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components.url(relativeTo: baseURL) else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
        
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String,Error>) -> Void){
        guard let urlRequest = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid request", code: 0, userInfo: nil))) //could change to guard let Thread.isMainThread later
            }
            return
        }
        
        DispatchQueue.main.async {
            assert(Thread.isMainThread)
        }
        
        if task != nil{
            if lastCode != code{
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        guard let request = makeOAuthTokenRequest(code: code) else{
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) {[weak self] data, response, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                print(error.localizedDescription)
            }
            
            guard let data = data else{
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "No data recieved", code: 0, userInfo: nil)))
                }
                return
            }
            
            
            if let jsonString = String(data: data, encoding: .utf8){
                print("JSON = \(jsonString)")
            } else {
                print("failed to convert data to string")
            }
            
            
            do {
                let decoder = JSONDecoder()
                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(responseBody.accessToken))
                }
            } catch {
                print("Couldnt decode token")
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    completion(.failure(DecoderError.decodingError(error)))
                }
            }
            self?.task = nil
            self?.lastCode = nil
            
        }
        self.task = task
        task.resume()
    }
    
}

enum DecoderError: Error{
    case decodingError(Error)
}

enum AuthServiceError: Error{
    case invalidRequest
}
