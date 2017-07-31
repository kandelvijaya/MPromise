//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

public class Network {

    enum NetworkError: Error {
        case unknown
    }

    private var task: URLSessionDataTask? = nil
    private let url: URL

    init(_ url: URL) {
        self.url = url
    }

    func get() -> Promise<Result<Data>> {
        //1. Make empty promise
        let promise = Promise<Result<Data>>()

        //2. Set the worker async block for the promise
        promise.aTask = {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: self.url) { (data, response, error) in
                if let d = data, error == nil {
                    // 3. When done, call into the promises `aCompletion`
                    // Dont worry, `aCompletion` will be injected when you do subsequent `then`
                    promise.aCompletion?(.success(d))
                } else if let e = error {
                    promise.aCompletion?(.failure(e))
                } else {
                    promise.aCompletion?(.failure(NetworkError.unknown))
                }
            }
            // 4. Resume the task when the worker is invoked
            task.resume()
        }
        return promise
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
let url2 = URL(string: "https://www.objc.io")!


Network(url).get().bind { data  -> Promise<Result<Data>> in
        //lets say the data contained url
        print(data.bind(dataToString).bind(takeFirstLine))
        print("here we go")
        return Network(url2).get()
    }.then { data2 in
        print(data2.bind(dataToString).bind(takeFirstLine))
    }
print(2)




PlaygroundPage.current.needsIndefiniteExecution = true
