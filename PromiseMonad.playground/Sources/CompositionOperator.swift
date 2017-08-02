import Foundation

precedencegroup BindPrecedence {
    higherThan: BitwiseShiftPrecedence
    associativity: left
}

/// alternative operator for `bind()`
infix operator >>>=: BindPrecedence

public func >>>= <A,B>(_ lhs: Result<A>, _ rhsFunc: @escaping ((A) -> Result<B>)) -> Result<B> {
    return lhs.bind(rhsFunc)
}


