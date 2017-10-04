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
    public func and(_ pattern: Pattern) -> Parser {
        return self.then(pattern).map { $0.0 }
    }

    /**
     Parse using `self` then `other`, returning a tuple of values from `self.parse`
     and `other.parse`.
    */
    public func and<OtherValue>(_ other: Parser<OtherValue>) -> Parser<(Value, OtherValue)> {
        return self.then(other)
    }
}

extension Pattern {

    /**
     Parse using `self` then `parser`, returning the value of `parser.parse`.
    */
    public func and<NewValue>(_ parser: Parser<NewValue>) -> Parser<NewValue> {
        return self.then(parser).map { $0.1 }
    }

    /**
     Parse using `self` then `pattern`.
    */
    public func and(_ pattern: Pattern) -> Pattern {
        return self.then(pattern).pattern
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
