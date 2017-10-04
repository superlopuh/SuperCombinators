//
//  ParserCombinator.swift
//  SuperCombinators
//
//  Created by Sasha Lopoukhine on 04/10/2017.
//

postfix operator *
postfix operator +

public protocol ParserCombinator {
    associatedtype Value
    associatedtype Input: Collection where Input.SubSequence: Collection
    var parsePrefix: (Input.SubSequence) -> Parse<Value, Input>? { get }
    init(parsePrefix: @escaping (Input.SubSequence) -> Parse<Value, Input>?)
}

extension ParserCombinator where Input == String {
    
    /**
     Captures the string parsed using `self`.
     */
    public var parser: Parser<String> {
        return Parser<String> { text in
            guard let result = self.parsePrefix(text) else { return nil }
            return Parse<String, String>(
                value: String(text[..<result.rest.startIndex]),
                rest: result.rest
            )
        }
    }
    
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
