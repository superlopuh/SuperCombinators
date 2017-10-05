//
//  Parser+Operators.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 09/02/2017.
//
//
//

/**
 Parses the using the left-hand parser.
 If the result exists, then return that.
 Otherwise, attempt using right-hand parser.
*/
public func || <Value, Input>(lhs: Parser<Value, Input>, rhs: Parser<Value, Input>) -> Parser<Value, Input> {
    return lhs.or(rhs)
}

extension Parser {

    /**
     Attemps to use `self` `number` times.
    */
    public func count(_ number: Int) -> Parser<[Value], Input> {
        precondition(0 <= number, "Can't invoke parser negative number of times")
        return Parser<[Value], Input> { text in
            var values = [Value]()
            var rest: Input.SubSequence = text[...]
            
            for _ in 0 ..< number {
                guard let result = self.parsePrefix(rest) else { return nil }
                values.append(result.value)
                rest = result.rest
                guard !rest.isEmpty else { break }
            }
            
            return Parse<[Value], Input>(
                value: values,
                rest: rest
            )
        }
    }
    
    /**
     Attemps to use `self` as many times as possible. Never fails.
    */
    public func zeroOrMore() -> Parser<[Value], Input> {
        return Parser<[Value], Input> { text in
            var values = [Value]()
            var rest = text[...]
            
            while let next = self.parsePrefix(rest) {
                values.append(next.value)
                rest = next.rest
                guard !rest.isEmpty else { break }
            }
            
            return Parse<[Value], Input>(
                value: values,
                rest: rest
            )
        }
    }
    
    /**
     Attemps to use `self` as many times as possible. Fails if there is not at least one match.
    */
    public func oneOrMore() -> Parser<[Value], Input> {
        return Parser<[Value], Input> { text in
            guard let first = self.parsePrefix(text) else { return nil }
            
            var values = [first.value]
            var rest = first.rest
            
            while let next = self.parsePrefix(rest) {
                values.append(next.value)
                rest = next.rest
                guard !rest.isEmpty else { break }
            }
            
            return Parse<[Value], Input>(
                value: values,
                rest: rest
            )
        }
    }
}

/**
 Attemps to use `self` as many times as possible. Never fails.
*/
public postfix func * <Value, Input>(single: Parser<Value, Input>) -> Parser<[Value], Input> {
    return single.zeroOrMore()
}

/**
 Attemps to use `self` as many times as possible. Fails if there is not at least one match.
*/
public postfix func + <Value, Input>(single: Parser<Value, Input>) -> Parser<[Value], Input> {
    return single.oneOrMore()
}
