import Foundation

public protocol Functor {

    associatedtype A
    associatedtype B
    associatedtype AB

    func fmap(_ t: @escaping (A) -> B) -> AB

}



public protocol Monad: Functor {

    func bind(_ rhs: @escaping (A) -> AB) -> AB

    // Init cannout be part of the requirement.
    // We need a constructor that takes a normal value and turns into a monad.
    // func init(_ v: A) -> AB

}


