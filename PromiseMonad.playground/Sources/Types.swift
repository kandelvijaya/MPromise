import Foundation

public protocol Functor {

    associatedtype A
    associatedtype B
    associatedtype AB

    func fmap(_ t: @escaping (A) -> B) -> AB

}



public protocol Monad: Functor {

    func bind(_ rhs: @escaping (A) -> AB) -> AB

}


