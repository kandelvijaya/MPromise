import Foundation

/// A Functor ==> Monadic type that encapsulates completion block
/// and their associated async task thereby providing a nice
/// synchronous and flow oriented programming model.
public final class Promise<T> {

    /// aCompletion is called by aTask when its done
    public var aCompletion: ((T) -> ())?

    /// This is the async task that we are abstracting over
    /// NOTE: aTask has to call aCompletion inside the closure
    public var aTask: (() -> ())? = nil

    /// You will need to call the aCompletion of the new Promise
    /// when the asyncTask is done.
    /// Due to this limitation we can't take argument in constructor
    //    init(with asyncTask: (() -> Void)? = nil) {
    //        self.aTask = asyncTask
    //    }
    public init() { }

    /// `then` is equivalent to `fmap`/`map`. It makes Promises Functorial.
    /// This deals with synchronous side of the world.
    /// If you want to create a Prmose inside of then, you are better off
    /// using `bind`
    @discardableResult public func then<U>(_ transform: @escaping (T) -> U) -> Promise<U> {
        let upcomingPromise = Promise<U>()
        self.aCompletion = { tk in
            let transformed = transform(tk)
            // Call the upcoming Promise's `completion` with the transformed value
            upcomingPromise.aCompletion?(transformed)
        }
        aTask?()
        return upcomingPromise
    }

    /// `bind` is equivalent to `>>=`. It makes Promises Monadic
    /// If all you want is to do synchronous tasks with the result
    /// its better to use the functorial `then`. However, bind is
    /// implemented in terms of `then` and `join`.
    public func bind<U>(_ transform: @escaping (T) -> Promise<U>) -> Promise<U> {
        let transformed = then(transform)
        return Promise.join(transformed)
    }

    static public func join<A>(_ input: Promise<Promise<A>>) -> Promise<A> {
        let newP = Promise<A>()
        newP.aTask = {
            input.then { innerPromise in
                innerPromise.then { innerValue in
                    newP.aCompletion?(innerValue)
                }
            }
        }
        return newP
    }

}
