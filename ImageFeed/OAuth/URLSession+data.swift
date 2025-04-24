import Foundation

enum NetworkError: Error, LocalizedError {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    
    var errorDescription: String? {
        switch self {
        case .httpStatusCode(let code):
            return "HTTP Status Code Error - code \(code)"
        case .urlRequestError(let error):
            return "Request Error - \(error.localizedDescription)"
        case .urlSessionError:
            return "URL Session Error"
        }
    }
}

extension URLSession {
    func data (for request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) -> URLSessionTask {
        
        let fulfillCompletionOnTheMainThread : (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async{
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                    print(NetworkError.httpStatusCode(statusCode).localizedDescription)
                }
            } else if let error = error {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                print(NetworkError.urlSessionError.localizedDescription)
            } else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let gatheredData = try decoder.decode(T.self, from: data)
                    completion(.success(gatheredData))
                }catch let error as DecodingError {
                    switch error {
                    case .keyNotFound(let key, let context):
                        print("❌ Ключ не найден: \(key.stringValue), \(context.debugDescription)")
                    case .typeMismatch(let type, let context):
                        print("❌ Несовпадение типа: \(type), \(context.debugDescription)")
                    case .valueNotFound(let type, let context):
                        print("❌ Отсутствует значение типа: \(type), \(context.debugDescription)")
                    case .dataCorrupted(let context):
                        print("❌ Данные повреждены: \(context.debugDescription)")
                    @unknown default:
                        print("❌ Неизвестная ошибка: \(error.localizedDescription)")
                    }
                    completion(.failure(error))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        return task
    }
}

