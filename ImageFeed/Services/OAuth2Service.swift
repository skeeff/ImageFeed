import UIKit

final class OAuth2Service {
    
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
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
        
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String,Error>) -> Void){
        guard let urlRequest = makeOAuthTokenRequest(code: code) else {
            DispatchQueue.main.async {
                completion(.failure(NSError(domain: "Invalid request", code: 0, userInfo: nil)))
            }
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
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
            
        }
        task.resume()
    }
    
}

enum DecoderError: Error{
    case decodingError(Error)
}
