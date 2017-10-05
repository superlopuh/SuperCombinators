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

public typealias StringPattern = Pattern<String>
public typealias StringParser<Value> = Parser<Value, String>

extension Pattern where Input == String {
    
    public var stringParser: StringParser<String> {
        return self.capturePrefix.map(String.init)
    }
}

extension Parser where Input == String {
    
    public func separated(by separator: String) -> Parser<[Value], Input> {
        return self.separated(by: Pattern(prefix: separator))
    }
    
    public convenience init(_ prefix: String, _ value: Value) {
        self.init(StringPattern(prefix: prefix), value)
    }
}

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
