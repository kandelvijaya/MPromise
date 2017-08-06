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


let x = Promise(12).then {
    return $0 * 2.10
    }.then {
        print($0)
    }

x.execute()



extension UIView {
    func animate(duration: TimeInterval, animation: @escaping (UIView) -> Void) -> Promise<UIView> {
        return Promise<UIView> { aC in
            UIView.animate(withDuration: duration, animations: {
                animation(self)
            }) { finished in
                if finished {
                    aC?(self)
                }
            }
        }
    }
}


struct AnimationToken {
    let duration: TimeInterval
    let animation: (UIView) -> Void
}

extension Promise where T == UIView {
    func animate(with duration: TimeInterval, animation: @escaping (UIView) -> Void) -> Promise<UIView> {
        return self.bind { view in
            view.animate(duration: duration, animation: animation)
        }
    }

    func animate(with animationTokens: [AnimationToken]) -> Promise<UIView> {
        return animateSequence(of: animationTokens, on: self)
    }

    private func animateSequence(of tokens: [AnimationToken], on promise: Promise<UIView>) -> Promise<UIView> {
        guard let currentToken = tokens.first else {
            return promise
        }
        let remainingTokens = Array(tokens.dropFirst())
        let newPromise = promise.animate(with: currentToken.duration, animation: currentToken.animation)
        return animateSequence(of: remainingTokens, on: newPromise)
    }
}


let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
view.backgroundColor = .red

let p = Promise(view).animate(with: 2) { view in
        view.backgroundColor = .green
    }.animate(with: 3) { view in
        view.backgroundColor = .red
    }.animate(with: 2) { view in
        view.backgroundColor = .white
    }



//p.execute()

let p2 = Promise(view).animate(with: [
    AnimationToken(duration: 4) { $0.backgroundColor = .white },
    AnimationToken(duration: 2) { $0.backgroundColor = .green },
])

p2.execute()








print("here: testing monadic promise")
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
