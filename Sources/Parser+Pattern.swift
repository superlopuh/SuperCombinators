//
//  Parser+Pattern.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 14/02/2017.
//
//

extension Parser {

    /**
     Parse using `self` then `pattern`, returning the value of `self.parse`.
    */
    public func and(_ next: Pattern<Input>) -> Parser<Value, Input> {
        return Parser<Value, Input> { text in
            guard
                let r0 = self.parsePrefix(text),
                let r1 = next.parsePrefix(r0.rest)
                else { return nil }
            
            return r1.map { _ in r0.value }
        }
    }

    /**
     Parse using `self` then `other`, returning a tuple of values from `self.parse`
     and `other.parse`.
    */
    public func and<OtherValue>(_ other: Parser<OtherValue, Input>) -> Parser<(Value, OtherValue), Input> {
        return Parser<(Value, OtherValue), Input> { text in
            guard
                let r0 = self.parsePrefix(text),
                let r1 = other.parsePrefix(r0.rest)
                else { return nil }
            
            return Parse<(Value, OtherValue), Input>(
                value: (r0.value, r1.value),
                rest: r1.rest
            )
        }
    }
}

extension Pattern {

    /**
     Parse using `self` then `parser`, returning the value of `parser.parse`.
    */
    public func and<NewValue>(_ next: Parser<NewValue, Input>) -> Parser<NewValue, Input> {
        return Parser { text in
            guard let r0 = self.parsePrefix(text) else { return nil }
            
            return next.parsePrefix(r0.rest)
        }
    }

    /**
     Parse using `self` then `pattern`.
    */
    public func and(_ next: Pattern) -> Pattern {
        return Pattern { text in
            guard
                let r0 = self.parsePrefix(text),
                let r1 = next.parsePrefix(r0.rest)
                else { return nil }
            
            return Pattern.Result(rest: r1.rest)
        }
    }
}

/**
 Parse using `lhs` then `rhs`, returning the tuple containing both parsed values.
*/
public func & <LHS, RHS, Input>(lhs: Parser<LHS, Input>, rhs: Parser<RHS, Input>) -> Parser<(LHS, RHS), Input> {
    return lhs.and(rhs)
}

/**
 Parse using `lhs` then `rhs`, returning the tuple containing all three parsed values.
 */
public func && <LHS0, LHS1, RHS, Input>(lhs: Parser<(LHS0, LHS1), Input>, rhs: Parser<RHS, Input>) -> Parser<(LHS0, LHS1, RHS), Input> {
    return lhs.and(rhs).map { ($0.0.0, $0.0.1, $0.1) }
}

/**
 Parse using `self` then `other`, returning a tuple of values from `self.parse`
 and `other.parse`.
*/
public func & <Value, Input>(lhs: Pattern<Input>, rhs: Parser<Value, Input>) -> Parser<Value, Input> {
    return lhs.and(rhs)
}

/**
 Parse using `self` then `parser`, returning the value of `parser.parse`.
*/
public func & <Value, Input>(lhs: Parser<Value, Input>, rhs: Pattern<Input>) -> Parser<Value, Input> {
    return lhs.and(rhs)
}

/**
 Parse using `self` then `pattern`.
*/
public func & <Input>(lhs: Pattern<Input>, rhs: Pattern<Input>) -> Pattern<Input> {
    return lhs.and(rhs)
}
