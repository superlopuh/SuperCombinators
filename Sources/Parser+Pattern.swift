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
    public func and(_ next: Pattern) -> Parser {
        return Parser { text in
            guard
                let r0 = self.parsePrefix(text),
                let r1 = next.parsePrefix(r0.rest)
                else { return nil }
            
            return Parser.Result(
                value: r0.value,
                rest: r1.rest
            )
        }
    }

    /**
     Parse using `self` then `other`, returning a tuple of values from `self.parse`
     and `other.parse`.
    */
    public func and<OtherValue>(_ other: Parser<OtherValue>) -> Parser<(Value, OtherValue)> {
        return Parser<(Value, OtherValue)> { text in
            guard
                let r0 = self.parsePrefix(text),
                let r1 = other.parsePrefix(r0.rest)
                else { return nil }
            
            return Parser<(Value, OtherValue)>.Result(
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
    public func and<NewValue>(_ next: Parser<NewValue>) -> Parser<NewValue> {
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
            
            return Pattern.Result(
                value: (),
                rest: r1.rest
            )
        }
    }
}

/**
 Parse using `lhs` then `rhs`, returning the tuple containing both parsed values.
*/
public func & <LHS, RHS>(lhs: Parser<LHS>, rhs: Parser<RHS>) -> Parser<(LHS, RHS)> {
    return lhs.and(rhs)
}

/**
 Parse using `lhs` then `rhs`, returning the tuple containing all three parsed values.
 */
public func && <LHS0, LHS1, RHS>(lhs: Parser<(LHS0, LHS1)>, rhs: Parser<RHS>) -> Parser<(LHS0, LHS1, RHS)> {
    return lhs.and(rhs).map { ($0.0.0, $0.0.1, $0.1) }
}

/**
 Parse using `self` then `other`, returning a tuple of values from `self.parse`
 and `other.parse`.
*/
public func & <Value>(lhs: Pattern, rhs: Parser<Value>) -> Parser<Value> {
    return lhs.and(rhs)
}

/**
 Parse using `self` then `parser`, returning the value of `parser.parse`.
*/
public func & <Value>(lhs: Parser<Value>, rhs: Pattern) -> Parser<Value> {
    return lhs.and(rhs)
}

/**
 Parse using `self` then `pattern`.
*/
public func & (lhs: Pattern, rhs: Pattern) -> Pattern {
    return lhs.and(rhs)
}
