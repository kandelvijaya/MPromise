import Foundation

// TODO: Implement Promise interms of IO Monad
public class IO<T>: Functor {

    public typealias A = T
    public typealias B = Any
    public typealias AB = IO<B>

    let intermediate: T

    public func fmap<B>(_ t: @escaping (T) -> B) -> IO<B> {
        return IO<B>(t(intermediate))
    }

    public func bind<B>(_ b: (T) -> IO<B>) -> IO<B> {
        return b(intermediate)
    }

    public init(_ intermediate: T) {
        self.intermediate = intermediate
    }

}
