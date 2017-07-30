import Foundation

precedencegroup BindPrecedence {
    higherThan: BitwiseShiftPrecedence
    associativity: left
}
infix operator >>>=: BindPrecedence

public func >>>= <T,U>(_ lhs: Result<T>, _ rhsFunc: ((T) -> Result<U>)) -> Result<U> {
    return lhs.bind(rhsFunc)
}


