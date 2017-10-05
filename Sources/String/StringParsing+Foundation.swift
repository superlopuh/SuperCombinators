//
//  StringParsing+Foundation.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 09/02/2017.
//
//

import Foundation

extension Pattern where Input == String {

    /**
     Matches all unicode characters `characterSet` does not contain.
    */
    public static func characters(notIn characterSet: CharacterSet) -> Pattern {
        return Pattern { text in
            guard !text.isEmpty else { return nil }
            let copy = String(text)
            guard let range = copy.rangeOfCharacter(from: characterSet) else {
                return Result(rest: text[text.endIndex...])
            }
            guard copy.startIndex != range.lowerBound else { return nil }
            let index = text.index(
                text.startIndex,
                offsetBy: copy.distance(from: copy.startIndex, to: range.lowerBound)
            )
            return Result(rest: text[index...])
        }
    }

    /**
     Matches all unicode characters `characterSet` contains.
    */
    public static func characters(in characterSet: CharacterSet) -> Pattern {
        return characters(notIn: characterSet.inverted)
    }

    /**
     Matches a single unicode character whose UnicodeScalars `characterSet` contains.
    */
    public static func character(in characterSet: CharacterSet) -> Pattern {
        return Pattern { text in
            guard !text.isEmpty else { return nil }
            let suffixIndex = text.index(text.startIndex, offsetBy: 1)
            let prefix = text[..<suffixIndex]
            if let _ = prefix.rangeOfCharacter(from: characterSet) {
                return nil
            } else {
                return Result(rest: text[suffixIndex...])
            }
        }
    }

    /**
     Matches all unicode characters `characterSet` does not contain.
     */
    public convenience init(regularExpression: NSRegularExpression) {
        self.init { text in
            let _range = text.range(
                of: regularExpression.pattern,
                options: .regularExpression
            )
            guard let range = _range else { return nil }
            assert(range.lowerBound == text.startIndex)
            return Result(rest: text[range.upperBound...])
        }
    }
}
