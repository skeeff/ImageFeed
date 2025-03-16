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
            completion(.failure(NSError(domain: "Invalid request", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            }
            
            guard let data = data else{
                completion(.failure(NSError(domain: "No data recieved", code: 0, userInfo: nil)))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                completion(.success(responseBody.accessToken))
            } catch {
                print("Couldnt decode token")
                print(error.localizedDescription)
                completion(.failure(DecoderError.decodingError(error)))
            }
            
        }
        task.resume()
    }
    
}

enum DecoderError: Error{
    case decodingError(Error)
}
