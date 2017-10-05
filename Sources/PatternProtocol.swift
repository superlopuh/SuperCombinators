//
//  PatternProtocol.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 10/02/2017.
//
//

public protocol PatternProtocol: ParserCombinator where Output == () {}

extension Pattern: PatternProtocol {
    public typealias Input = String
}
