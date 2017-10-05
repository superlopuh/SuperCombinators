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

extension ParserCombinator {
    public typealias Result = Parse<Value, Input>
}

extension ParserCombinator {
    
    /**
     Captures the string parsed using `self`.
     */
    public var capturePrefix: Parser<Input.SubSequence, Input> {
        return Parser<Input.SubSequence, Input> { input in
            guard let result = self.parsePrefix(input) else { return nil }
            return Parse<Input.SubSequence, Input>(
                value: input[..<result.rest.startIndex],
                rest: result.rest
            )
        }
    }
    
    public func matches(_ input: Input) -> Bool {
        guard let result = parsePrefix(input[...]) else { return false }
        return result.rest.isEmpty
    }
    
    public func or(_ other: Self) -> Self {
        return Self { input in
            return self.parsePrefix(input) ?? other.parsePrefix(input)
        }
    }
    
    public static func either(_ patterns: Self...) -> Self {
        return Self { input in
            for pattern in patterns {
                if let result = pattern.parsePrefix(input) { return result }
            }
            return nil
        }
    }
}
