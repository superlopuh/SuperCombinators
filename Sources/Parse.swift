//
//  Parse.swift
//  SuperCombinators
//
//  Created by Sasha Lopoukhine on 04/10/2017.
//

/**
 Contains the extracted value and remainder of the string.
*/
public struct Parse<Value> {
    
    public let value: Value
    public let rest: Substring
    
    public init(value: Value, rest: Substring) {
        self.value = value
        self.rest = rest
    }
}

extension Parse {
    
    public func map<NewValue>(_ transform: @escaping (Value) -> NewValue) -> Parse<NewValue> {
        return Parse<NewValue>(
            value: transform(value),
            rest: rest
        )
    }
}

extension Parse where Value == () {
    
    init(rest: Substring) {
        self.value = ()
        self.rest = rest
    }
}
