import Foundation

/// A Functor ==> Monadic type that encapsulates completion block
/// and their associated async task thereby providing a nice
/// synchronous and flow oriented programming model.
public final class Promise<T> {

    public typealias Completion = (T) -> Void

    /// This is the async task that we are abstracting over
    var aTask: ((Completion?) -> Void)? = nil

    /// When creating a promise, you should care to call the first argument closure
    /// that is provided with the eventual result value.
    public init(_ task: @escaping ((Completion?) -> Void)) {
        self.aTask = task
    }

    /// `then` is equivalent to `fmap`/`map`. It makes Promises Functorial.
    /// This deals with synchronous side of the world.
    /// If you want to create a Prmose inside of then, you are better off
    /// using `bind`
    @discardableResult public func then<U>(_ transform: @escaping (T) -> U) -> Promise<U> {
        return Promise<U>{ upcomingCompletion in
            self.aTask?() { tk in
                let transformed = transform(tk)
                upcomingCompletion?(transformed)
            }
        }
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
        return Promise<A>{ aCompletion in
            input.then { innerPromise in
                innerPromise.then { innerValue in
                    aCompletion?(innerValue)
                }.execute()
            }.execute()
        }
    }

    /// Call this method on any Promise type to execute and fulfill the promise.
    /// This is important because the design of Promises is to not evaluate immediately
    /// but create a expression that can be executed/ passed or stored. The expression
    /// can be internally be optimized or lazily evaluated.
    public func execute() {
        aTask?(nil)
    }

}


extension Promise: Functor {

    public typealias A = T
    public typealias B = Any
    public typealias AB = Promise<B>

    /// fmap is the same as `then`
    public func fmap<B>(_ t: @escaping (T) -> B) -> Promise<B> {
        return then(t)
    }

}

/// Already implements `bind`
extension Promise: Monad { }

