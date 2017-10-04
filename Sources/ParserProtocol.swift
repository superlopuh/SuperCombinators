//
//  ParserProtocol.swift
//  SuperCombinators
//
//  Created by Sasha Lopoukhine on 04/10/2017.
//

public protocol ParserProtocol: ParserCombinator {}

extension Parser: ParserProtocol {
    
    public var matchPrefix: (Substring) -> Substring? {
        return { text in
            self.parsePrefix(text)?.rest
        }
    }
}
