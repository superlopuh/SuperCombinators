//
//  ParserTests.swift
//  SuperCombinatorsTests
//
//  Created by Sasha Lopoukhine on 04/10/2017.
//

import Foundation
import XCTest
@testable import SuperCombinators

class ParserTests: XCTestCase {
    
    func testEmpty() {
        XCTAssert(Pattern.empty.parser.matches(""))
    }
    
    func testSimple() {
        let _a: Pattern = "a"
        let a = _a.parser
        let b = Pattern(prefix: "b").parser
        
        XCTAssertEqual("a", a.parse("a"))
        
        XCTAssert(a.matches("a"))
        XCTAssert(b.matches("b"))
        
        XCTAssert((a & b).matches("ab"))
        
        XCTAssert((a || b).matches("a"))
        XCTAssert((a || b).matches("b"))
        
        XCTAssertFalse(a.matches("c"))
        XCTAssertFalse(b.matches("c"))
        XCTAssertFalse((a & b).matches("c"))
        XCTAssertFalse((a || b).matches("c"))
    }
    
    func testRecursive() {
        let bracketed = Pattern.recursive { bracketed in
            let single = Pattern.recursive { single in
                return "(" & single & ")" || "()"
            }
            return single+ || "(" & bracketed & ")"
        }
        
        XCTAssertFalse(bracketed.matches(""))
        XCTAssertFalse(bracketed.matches("("))
        XCTAssertFalse(bracketed.matches(")"))
        XCTAssertFalse(bracketed.matches("())"))
        XCTAssertFalse(bracketed.matches("(()"))
        
        XCTAssert(bracketed.matches("()"))
        XCTAssert(bracketed.matches("(())"))
        XCTAssert(bracketed.matches("()()"))
        XCTAssert(bracketed.matches("(()())"))
        XCTAssert(bracketed.matches("(())(())()"))
    }
    
    func testRegularExpression() {
        let hello = Pattern(
            regularExpression: try! NSRegularExpression(pattern: "^hello", options: [])
        )
        XCTAssert(hello.matches("hello"))
    }
    
    func testCharacterSet() {
        let letters = Pattern.characters(in: .alphanumerics)
        let spaces = Pattern.characters(in: .whitespaces)
        
        let myParser = letters & ", " & letters.parser.separated(by: spaces)
        
        let _parse = myParser.parse("hello, my name is")
        XCTAssertNotNil(_parse)
        
        guard let parse = _parse else { return }
        
        XCTAssertEqual(["my", "name", "is"], parse)
    }
    
    func testUIntParser() {
        let digits = Pattern.characters(in: .decimalDigits)
        let uint = digits.parser.map { Int($0)! }
        
        let _parse = uint.parse("123")
        
        XCTAssertNotNil(_parse)
        
        guard let parse = _parse else { return }
        
        XCTAssertEqual(123, parse)
    }
    
    func testFloatParser() {
        let digits = Pattern.characters(in: .decimalDigits)
        let uint = digits.parser.map { Int($0)! }
        
        let ufloat0 = uint.map(Double.init)
        
        let ufloat1 = ("." & ufloat0).map { float -> Double in
            guard 0 < float else { return 0 }
            let power = log10(float).rounded(.down) + 1
            return float / pow(10, power)
        }
        
        let ufloat = (ufloat0.optional & ufloat1.optional)
            .test { nil != $0 || nil != $1 }
            .map { ($0 ?? 0) + ($1 ?? 0) }
        
        let float = ufloat || ("-" & ufloat).map { -$0 }
        
        let _parse0 = float.parse("-.1")
        let _parse1 = float.parse("123.456")
        
        XCTAssertNotNil(_parse0)
        XCTAssertNotNil(_parse1)
        
        guard let parse0 = _parse0, let parse1 = _parse1 else { return }
        
        XCTAssertEqual(-0.1, parse0)
        XCTAssertEqual(123.456, parse1)
    }
}
