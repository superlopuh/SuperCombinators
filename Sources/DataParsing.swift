//
//  DataParsing.swift
//  SuperCombinators
//
//  Created by Sasha Lopoukhine on 06/10/2017.
//

import Foundation

public typealias DataPattern = Pattern<Data>
public typealias DataParser<Value> = Parser<Value, Data>

extension Parser where Input == Data, Value == String {
    
    /**
     Creates a Parser of text data encoded in UTF8.
     https://en.wikipedia.org/wiki/UTF-8
     */
    public static var utf8: Parser {
        let header = DataParser.single.flatMap { byte -> (Int, UInt32)? in
            let numberOfBytes: Int
            let remainingBits: UInt32
            
            if byte >> 7 == 0b0 {
                numberOfBytes = 1
                remainingBits = UInt32(byte & 0b01111111)
            } else if byte >> 5 == 0b110 {
                numberOfBytes = 2
                remainingBits = UInt32(byte & 0b00011111)
            } else if byte >> 4 == 0b1110 {
                numberOfBytes = 3
                remainingBits = UInt32(byte & 0b00001111)
            } else if byte >> 3 == 0b11110 {
                numberOfBytes = 4
                remainingBits = UInt32(byte & 0b00000111)
            } else {
                return nil
            }
            
            return (numberOfBytes, remainingBits)
        }
        
        let tailByte = DataParser.single.flatMap { byte -> UInt8? in
            guard byte >> 6 == 0b10 else { return nil }
            return byte & 0b00111111
        }
        
        let scalar = header.flatMap { header -> DataParser<Unicode.Scalar> in
            return tailByte.count(header.0 - 1).map { tailBytes in
                let accumulated = tailBytes.reduce(header.1) {
                    return ($0 << 6) | UInt32($1)
                }
                return Unicode.Scalar(accumulated)!
            }
        }
        
        return scalar*.map { unicodeScalars in
            var result = ""
            result.unicodeScalars.append(contentsOf: unicodeScalars)
            return result
        }
    }
}
