//
//  Pattern+Operators.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 14/02/2017.
//
//

/**
 Parses the using the left-hand parser. 
 If the result exists, then return that.
 Otherwise, attempt using right-hand pattern.
*/
public func || (lhs: Pattern, rhs: Pattern) -> Pattern {
    return lhs.or(rhs)
}

extension Pattern {

    /**
     Attemps `self`, succeeds if length of prefix parsed equals `length`.
    */
    public func length(_ length: Int) -> Pattern {
        precondition(0 <= length, "Can't expect a negative length")
        return Pattern { text in
            guard
                let result = self.parsePrefix(text),
                length == text.distance(from: text.startIndex, to: result.rest.startIndex)
                else { return nil }

            return result
        }
    }

    /**
     Attemps to use `self` `number` times.
    */
    public func count(_ number: Int) -> Pattern {
        precondition(0 <= number, "Can't invoke parser negative number of times")
        return Pattern { text in
            var rest = text[...]

            for _ in 0 ..< number {
                guard let next = self.parsePrefix(rest) else { return nil }
                rest = next.rest
                guard !rest.isEmpty else { break }
            }

            return Result(rest: rest)
        }
    }

    /**
     Attemps to use `self` as many times as possible. Never fails.
    */
    public func zeroOrMore() -> Pattern {
        return Pattern { text in
            var rest = text[...]

            while let next = self.parsePrefix(rest) {
                rest = next.rest
                guard !rest.isEmpty else { break }
            }

            return Result(rest: rest)
        }
    }
    
    /**
     Attemps to use `self` as many times as possible. Fails if there is not at least one match.
    */
    public func oneOrMore() -> Pattern {
        return Pattern { text in
            guard var result = self.parsePrefix(text) else { return nil }

            while let next = self.parsePrefix(result.rest) {
                result = next
                guard !result.rest.isEmpty else { break }
            }

            return result
        }
    }
}

/**
 Attemps to use `self` as many times as possible. Never fails.
*/
public postfix func * (single: Pattern) -> Pattern {
    return single.zeroOrMore()
}

/**
 Attemps to use `self` as many times as possible. Fails if there is not at least one match.
*/
public postfix func + (single: Pattern) -> Pattern {
    return single.oneOrMore()
}
