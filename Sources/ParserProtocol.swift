//
//  ParserProtocol.swift
//  SuperCombinators
//
//  Created by Sasha Lopoukhine on 04/10/2017.
//

public protocol ParserProtocol: ParserCombinator {}

extension ParserProtocol {
    
    /**
     Parses a prefix of a string, returning the string's value only if it exists for the whole string.
     */
    public func parse(_ input: Input) -> Output? {
        guard let result = parsePrefix(input[...]), result.rest.isEmpty else { return nil }
        return result.value
    }
}
