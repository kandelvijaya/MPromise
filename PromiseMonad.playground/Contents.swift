//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport


let url = URL(string: "https://www.kandelvijaya.com")!
let url2 = URL(string: "https://www.objc.io")!

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


func takeFirst20Chars(_ string: String) -> Result<String> {
    let prefixed = String(string.prefix(20))
    return .success(prefixed)
}




func testThennedPromisePromise() -> Promise<()> {
    let x = Network(url).get().then { (data) -> Result<String> in
            print("Step 1")
            let ret = data.bind(dataToString)
            return ret
        }.then { (str) -> () in
            print("printing step 2")
            print(str.bind(takeFirstLine))
        }.bind { (_) -> Promise<Result<Data>> in
            print("Step 3: Another task")
            return Network(url2).get()
        }.then { (result) -> () in
            print("Step 4 printing")
            print(result.bind(dataToString).bind(takeFirst20Chars))
        }
    return x
}

func testThennedPromisePromiseWithoutTypeInfomation() -> Promise<()> {
    /// If any but the last then or bind block has a print statement, the closure return type
    /// cannot be inferred. Strange but true.
    let x = Network(url).get().then {
            return $0.bind(dataToString)
        }.then {
            return ()
        }.bind {
            return Network(url2).get()
        }.then {
            print($0.bind(dataToString).bind(takeFirst20Chars))
        }
    return x
}


func testNestingOfPromises() {
    testThennedPromisePromise().then {
        print("inner promise")
        testThennedPromisePromiseWithoutTypeInfomation().execute()
    }.execute()
}


// testThennedPromisePromise().execute()
// testThennedPromisePromiseWithoutTypeInfomation().execute()
// testNestingOfPromises()





print("here: testing monadic promise")
PlaygroundPage.current.needsIndefiniteExecution = true
