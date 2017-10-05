//
//  Parser.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 09/02/2017.
//
//

/**
 Parses a prefix of a substring, extracting a value, and returning the remainder of the string.
*/
public final class Parser<Value, Input: Collection>: ParserCombinator where Input.SubSequence: Collection {

    /**
     Parses a prefix of a string, returning the prefix's end index and value on success.
    */
    public let parsePrefix: (Input.SubSequence) -> Parse<Value, Input>?

    public init(parsePrefix: @escaping (Input.SubSequence) -> Parse<Value, Input>?) {
        self.parsePrefix = parsePrefix
    }
}

extension Parser {
    
    /**
     Parses a prefix of a string, returning the string's value only if it exists for the whole string.
     */
    public func parse(_ input: Input) -> Value? {
        guard let result = parsePrefix(input[...]), result.rest.isEmpty else { return nil }
        return result.value
    }
}

extension Parser {

    /**
     Creates a `Parser` that parses an empty prefix and returns the specified value.
    */
    public static func pure(_ value: Value) -> Parser {
        return Parser { text in Result(value: value, rest: text[...]) }
    }

    /**
     Creates a `Parser` that always succeeds, giving the result of `self.parse` if it exists.
    */
    public var optional: Parser<Value?, Input> {
        return Parser<Value?, Input> { text in
            let result = self.parsePrefix(text)
            return Parser<Value?, Input>.Result(
                value: result?.value,
                rest: result?.rest ?? text[...]
            )
        }
    }

    /**
     Creates a `Parser` that parses the same prefix as `self`, and contains the transformed value.
    */
    public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Parser<NewValue, Input> {
        return Parser<NewValue, Input> { text in
            return self.parsePrefix(text)?.map(transform)
        }
    }

    /**
     Creates a `Parser` that 
     1. parses the same prefix as `self`
     2. creates a new parser using `transform`
     3. parses the prefix of the newly created suffix using the new parser
    */
    public func flatMap<NewValue>(_ transform: @escaping (Value) -> Parser<NewValue, Input>) -> Parser<NewValue, Input> {
        return Parser<NewValue, Input> { text in
            guard let r0 = self.parsePrefix(text) else { return nil }
            return transform(r0.value).parsePrefix(r0.rest)
        }
    }

    /**
     Returns the result of 'self.parse' if the extracted value passes the `test`.
    */
    public func test(_ test: @escaping (Value) -> Bool) -> Parser {
        return Parser { characters in
            guard let result = self.parsePrefix(characters), test(result.value) else { return nil }
            return result
        }
    }
}

// MARK: Apply

/**
 Parses the text first using the left parser, then the right, and calls the value of the right-hand result on the value of the left-hand result.
*/
public func / <A, B, Input>(lhs: Parser<A, Input>, rhs: Parser<(A) -> B, Input>) -> Parser<B, Input> {
    return lhs.and(rhs).map { $1($0) }
}

/**
 Parses the text first using the left parser, then the right, and calls the value of the left-hand result on the value of the right-hand result.
*/
public func / <A, B, Input>(lhs: Parser<(A) -> B, Input>, rhs: Parser<A, Input>) -> Parser<B, Input> {
    return lhs.and(rhs).map { $0($1) }
}
