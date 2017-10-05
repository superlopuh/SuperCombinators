//
//  PatternTests.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 23/02/2017.
//
//

import Foundation
import XCTest
@testable import SuperCombinators

class PatternTests: XCTestCase {

    func testEmpty() {
        XCTAssert(Pattern.empty.matches(""))
    }

    func testSimple() {
        let a = Pattern(prefix: "a")
        let b = Pattern(prefix: "b")

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
        let bracketed = StringPattern.recursive { bracketed in
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
        
        let myPattern = letters & ", " & letters.capturePrefix.separated(by: spaces)
        
        XCTAssert(myPattern.matches("hello, my name is"))
    }
}
