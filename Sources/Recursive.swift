//
//  Recursive.swift
//  SuperCombinators
//
//  Created by Alexandre Lopoukhine on 14/02/2017.
//
//

private final class Recursive<P: ParserCombinator> {

    private let generate: (Recursive) -> (P.Input.SubSequence) -> P.Result?

    private(set) lazy var parsePrefix: (P.Input.SubSequence) -> P.Result? = self.generate(self)

    init(generateParser: @escaping (P) -> P) {
        self.generate = { rec in
            let box = P { [unowned rec] text in
                return rec.parsePrefix(text)
            }
            return generateParser(box).parsePrefix
        }
    }
}

extension ParserCombinator {

    /**
     Creates a `ParserCombinator` for a recursive grammar.
     
     - Note: Within the scope of the closure, the input parser's `parsePrefix` method is not defined, and will crash if called.
    */
    public static func recursive(generateParser: @escaping (Self) -> Self) -> Self {
        let rec = Recursive(generateParser: generateParser)
        return Self { text in
            return rec.parsePrefix(text)
        }
    }
}
