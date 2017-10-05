//
//  String+Operators.swift
//  SuperCombinators iOS
//
//  Created by Sasha Lopoukhine on 05/10/2017.
//

// Implement when Swift gets conditional conformance
// This will allow us to remove the operators on String

//public extension Pattern: ExpressibleByStringLiteral where Input == String {
//    ...
//}

public func || (lhs: String, rhs: Pattern<String>) -> Pattern<String> {
    return Pattern(prefix: lhs) || rhs
}

public func || (lhs: String, rhs: String) -> Pattern<String> {
    return Pattern(prefix: lhs) || Pattern(prefix: rhs)
}

public func || (lhs: Pattern<String>, rhs: String) -> Pattern<String> {
    return lhs || Pattern(prefix: rhs)
}

public func & <Value>(lhs: String, rhs: Parser<Value, String>) -> Parser<Value, String> {
    return Pattern(prefix: lhs) & rhs
}

public func & <Value>(lhs: Parser<Value, String>, rhs: String) -> Parser<Value, String> {
    return lhs & Pattern(prefix: rhs)
}

public func & (lhs: String, rhs: Pattern<String>) -> Pattern<String> {
    return Pattern(prefix: lhs) & rhs
}

public func & (lhs: Pattern<String>, rhs: String) -> Pattern<String> {
    return lhs & Pattern(prefix: rhs)
}
