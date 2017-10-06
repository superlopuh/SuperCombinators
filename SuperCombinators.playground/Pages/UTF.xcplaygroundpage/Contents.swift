//: [Previous](@previous)

import SuperCombinators

let utf8 = DataParser.utf8

let original = "Hello, playground 🚀"
let data = original.data(using: .utf8)!
let scalars = utf8.parse(data)

//byte.parsePrefix(data)

//: [Next](@next)
