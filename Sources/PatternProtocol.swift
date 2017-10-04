//
//  PatternProtocol.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 10/02/2017.
//
//

postfix operator *
postfix operator +

protocol PatternProtocol: class {

    associatedtype Value

    var parsePrefix: (Substring) -> Parse<Value>? { get }

    init(parsePrefix: @escaping (Substring) -> Parse<Value>?)
}

extension Pattern: PatternProtocol {
    typealias Value = ()
}

extension Parser: PatternProtocol {}

extension PatternProtocol {
    
    func then<Other: PatternProtocol>(_ other: Other) -> Parser<(Value, Other.Value)> {
        return Parser<(Value, Other.Value)> { text in
            guard
                let r0 = self.parsePrefix(text),
                let r1 = other.parsePrefix(r0.rest)
                else { return nil }
            
            return Parse<(Value, Other.Value)>(
                value: (r0.value, r1.value),
                rest: r1.rest
            )
        }
    }
}

extension PatternProtocol {

    /**
     Captures the string parsed using `self`.
    */
    public var parser: Parser<String> {
        return Parser<String> { text in
            guard let result = self.parsePrefix(text) else { return nil }
            return Parse<String>(
                value: String(text[..<result.rest.startIndex]),
                rest: result.rest
            )
        }
    }

    /**
     Parses the using the left-hand parser.
     If the result exists, then return that.
     Otherwise, attempt using right-hand pattern.
    */
    public func matches(_ text: String) -> Bool {
        guard let result = parsePrefix(text[...]) else { return false }
        return result.rest.isEmpty
    }

    public func or(_ other: Self) -> Self {
        return Self { text in self.parsePrefix(text) ?? other.parsePrefix(text) }
    }

    public static func either(_ patterns: Self...) -> Self {
        return Self { text in
            for pattern in patterns {
                if let result = pattern.parsePrefix(text) { return result }
            }
            return nil
        }
    }
}
