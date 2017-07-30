//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

public class Network {

    enum NetworkError: Error {
        case unknown
    }

    private var eventual: ((Result<Data>) -> ())?
    private var task: URLSessionDataTask? = nil
    private let url: URL

    init(_ url: URL) {
        self.url = url
        let session = URLSession(configuration: .default)
        task = session.dataTask(with: url) { (data, response, error) in
            if let d = data, error == nil {
                self.eventual?(.success(d))
            } else if let e = error {
                self.eventual?(.failure(e))
            } else {
                self.eventual?(.failure(NetworkError.unknown))
            }
        }
    }

//    func then(_ doF: @escaping (Result<Data>) -> ()) -> () {
//        self.eventual = doF
//    }

    func then(_ doF: @escaping (Result<Data>) -> ()) -> Network {
        self.eventual = doF
        return self
    }

    func finilize() {
        task?.resume()
    }

}

enum DataConversionError: Error {
    case dataCannotBeConvertedToString
}

func dataToString(_ data: Data) -> Result<String> {
    let string = String(data: data, encoding: .utf8)
    guard let str = string else {
        return .failure(DataConversionError.dataCannotBeConvertedToString)
    }
    return .success(str)
}

func takeFirstLine(_ string: String) -> Result<String> {
    if let index = string.index(of: "\n") {
        return .success(string.substring(to: index))
    }
    return .failure(DataConversionError.dataCannotBeConvertedToString)
}






let url = URL(string: "https://www.kandelvijaya.com")!
let kvNetwork = Network(url)
kvNetwork.then { (res) in
    print(res.bind(dataToString))
}.then { (res) in
    print(res.bind(dataToString).bind(takeFirstLine))
}.finilize()





PlaygroundPage.current.needsIndefiniteExecution = true
