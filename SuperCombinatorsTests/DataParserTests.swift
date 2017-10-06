//
//  DataParserTests.swift
//  SuperCombinatorsTests
//
//  Created by Sasha Lopoukhine on 06/10/2017.
//

import Foundation
import XCTest
@testable import SuperCombinators

typealias DataPattern = Pattern<Data>
typealias DataParser<Value> = Parser<Value, Data>

class DataParserTests: XCTestCase {

    func testUTF8() {
        let utf8 = DataParser.utf8
        
        let original = "Hello ⬛️ my old 👫"
        let data = original.data(using: .utf8)!
        let _recovered = utf8.parse(data)
        
        XCTAssertNotNil(_recovered)
        
        guard let recovered = _recovered else { return }
        
        XCTAssertEqual(original, recovered)
    }
}
