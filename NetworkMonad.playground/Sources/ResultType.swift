import Foundation

public enum Result<T> {

    case success(T)
    case failure(Error)

}

extension Result: Functor {

    typealias A = T
    typealias B = Any
    typealias AB = Result<B>

    public func fmap<B>(_ t: (T) -> B) -> Result<B> {
        switch self {
        case let .success(v):
            return .success(t(v))
        case let .failure(e):
            return .failure(e)
        }
    }

}



extension Result: Monad {

    public func bind<B>(_ rhs: (T) -> Result<B>) -> Result<B> {
        switch self {
        case let .success(v):
            return rhs(v)
        case let .failure(e):
            return .failure(e)
        }
    }

}



