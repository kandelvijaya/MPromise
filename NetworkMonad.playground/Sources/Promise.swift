import Foundation

/// A Functor ==> Monadic type that encapsulates completion block
/// and their associated async task thereby providing a nice
/// synchronous and flow oriented programming model.
public final class Promise<T> {

    public typealias Completion = (T) -> Void

    /// aCompletion is called by aTask when its done
    public var aCompletion: Completion?

    /// This is the async task that we are abstracting over
    public var aTask: ((Completion?) -> Void)? = nil

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

    public func execute() {
        aTask?(nil)
    }

}
