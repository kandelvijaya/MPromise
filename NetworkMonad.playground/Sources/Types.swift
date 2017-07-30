import Foundation

protocol Functor {

    associatedtype A
    associatedtype B
    associatedtype AB

    func fmap(_ t: (A) -> B) -> AB

}



protocol Monad: Functor {

    func bind(_ rhs: (A) -> AB) -> AB

}

