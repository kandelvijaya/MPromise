//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport


class Promise<T> {

    //aCompletion is called by aTask when its done
    var aCompltion: ((T) -> ())?

    // This is the async task that we are abstracting over
    var aTask: (() -> ())?

    init() { }

    // We want our then to return a new compose promise so that it can be chained
    func then<U>(_ toF: @escaping (T) -> U) -> Promise<U> {

        let upcomingPromise = Promise<U>()
        upcomingPromise.aTask = nil

        self.aCompltion = { tk in
            let transformed = toF(tk)
            // Call the next promises token when this is done
            upcomingPromise.aCompltion?(transformed)
        }
        aTask?()
        return upcomingPromise
    }

}

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
                    // 3. Use the empty promise to call the token
                    // This token will be injected by user when they call then
                    promise.aCompltion?(.success(d))
                } else if let e = error {
                    promise.aCompltion?(.failure(e))
                } else {
                    promise.aCompltion?(.failure(NetworkError.unknown))
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
let kvNetwork = Network(url).get().then { (res) in
        return res.bind(dataToString)
    }.then {
        print($0.bind(takeFirstLine))
        return "Something"
    }.then {
        print($0)
}




PlaygroundPage.current.needsIndefiniteExecution = true
