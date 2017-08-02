import Foundation


public class Network {

    public enum NetworkError: Error {
        case unknown
    }

    private var task: URLSessionDataTask? = nil
    private let url: URL

    public init(_ url: URL) {
        self.url = url
    }

    public func get() -> Promise<Result<Data>> {
        return Promise { aCompletion in
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: self.url) { (data, response, error) in
                if let d = data, error == nil {
                    aCompletion?(.success(d))
                } else if let e = error {
                    aCompletion?(.failure(e))
                } else {
                    aCompletion?(.failure(NetworkError.unknown))
                }
            }
            // 4. Resume the task when the worker is invoked
            task.resume()
        }
    }

}
