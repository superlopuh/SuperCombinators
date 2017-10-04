//
//  Parse.swift
//  SuperCombinators
//
//  Created by Sasha Lopoukhine on 04/10/2017.
//

/**
 Contains the extracted value and remainder of the string.
 */
public struct Parse<Value, Input: Collection> where Input.SubSequence: Collection {
    
    public let value: Value
    public let rest: Input.SubSequence
    
    public init(value: Value, rest: Input.SubSequence) {
        self.value = value
        self.rest = rest
    }
}

extension Parse {
    
    public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Parse<NewValue, Input> {
        return Parse<NewValue, Input>(
            value: transform(value),
            rest: rest
        )
    }
}

extension Parse where Value == () {
    
    init(rest: Input.SubSequence) {
        self.value = ()
        self.rest = rest
    }
}

