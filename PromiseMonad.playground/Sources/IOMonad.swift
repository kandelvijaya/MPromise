import Foundation

public class IO<T>: Functor {

    typealias A = T
    typealias B = Any
    typealias AB = IO<B>

    let intermediate: T

    public func fmap<B>(_ t: (T) -> B) -> IO<B> {
        return IO<B>(t(intermediate))
    }

    public func bind<B>(_ b: (T) -> IO<B>) -> IO<B> {
        return b(intermediate)
    }

    public init(_ intermediate: T) {
        self.intermediate = intermediate
    }

}
