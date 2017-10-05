//
//  StringParsing.swift
//  SuperCombinators
//
//  Created by Sasha Lopoukhine on 05/10/2017.
//

public typealias StringPattern = Pattern<String>
public typealias StringParser<Value> = Parser<Value, String>

extension Pattern where Input == String {
    
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
        self.init { input in
            guard
                let suffixIndex = input.index(input.startIndex, offsetBy: count, limitedBy: input.endIndex)
                else { return nil }
            return Result(rest: input[suffixIndex...])
        }
    }
    
    /**
     Creates a parser that copies the traversed substring.
     */
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
