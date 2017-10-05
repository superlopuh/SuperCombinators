//
//  Pattern.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 09/02/2017.
//
//

/**
 Parses a prefix of a string, returning the prefix's end index on success.
*/
public final class Pattern: PatternProtocol {
    
    public typealias Output = ()
    public typealias Input = String
    
    /**
     Parses a prefix of a string, returning the prefix's end index on success.
    */
    public let parsePrefix: (Substring) -> Result?

    public init(parsePrefix: @escaping (Substring) -> Result?) {
        self.parsePrefix = parsePrefix
    }
}

extension Parser {

    /**
     Creates a pattern that parses the prefix of a string using `self.parse` and ignores the value.
    */
    public var pattern: Pattern {
        return Pattern { text in
            return self.parsePrefix(text)?.map { _ in () }
        }
    }

    /**
     Create a parser that parses the prefix of a string using `pattern.parse` and returns `value` as the value.
    */
    public convenience init(_ pattern: Pattern, _ value: Value) {
        self.init { text in
            return pattern.parsePrefix(text)?.map { _ in value }
        }
    }

    /**
     Create a parser that parses the prefix of a string using `pattern.parse` and returns `value` as the value.
     
     Returns an array of values that can be parsed by `self` given that their strings are separated by substrings matched by `separator`.
     */
    public func separated(by separator: Pattern) -> Parser<[Value]> {
        return Parser<[Value]> { text in
            guard let first = self.parsePrefix(text) else { return nil }

            let combined = separator & self

            var values = [first.value]
            var rest = first.rest

            while let next = combined.parsePrefix(rest) {
                values.append(next.value)
                rest = next.rest
                guard !rest.isEmpty else { break }
            }

            return Parser<[Value]>.Result(
                value: values,
                rest: rest
            )
        }
    }
}

extension Pattern {

    /**
     Create a pattern that matches the prefix of a string if it is equal to the prefix provided.
    */
    public convenience init(prefix: String) {
        self.init { text in
            guard text.hasPrefix(prefix) else { return nil }
            let suffixIndex = text.index(text.startIndex, offsetBy: prefix.characters.count)
            return Result(rest: text[suffixIndex...])
        }
    }

    /**
     Create a pattern that returns the prefix composed of `count` Characters, and fails if the input is not long enough.
    */
    public convenience init(count: Int) {
        self.init { text in
            guard
                let suffixIndex = text.index(text.startIndex, offsetBy: count, limitedBy: text.endIndex)
                else { return nil }
            return Result(rest: text[suffixIndex...])
        }
    }

    /**
     Create a pattern that does not parse anything and never fails.
    */
    public static var pure: Pattern {
        return Pattern { text in Result(rest: text[...]) }
    }

    /**
     Create a pattern that fails on any string but "".
    */
    public static var empty: Pattern {
        return Pattern { text in text.isEmpty ? Result(rest: text[...]) : nil }
    }

    /**
     Create a pattern that parses using `self.parse`. If that fails, returns the whole text as suffix.
     - Note: is equivalent to `self || .pure`
    */
    public var optional: Pattern {
        return Pattern { text in self.parsePrefix(text) ?? Result(rest: text[...]) }
    }
}

extension Pattern: ExpressibleByStringLiteral {

    public convenience init(stringLiteral value: String) {
        self.init(prefix: value)
    }

    public convenience init(unicodeScalarLiteral value: String) {
        self.init(prefix: value)
    }

    public convenience init(extendedGraphemeClusterLiteral value: String) {
        self.init(prefix: value)
    }
}
