//: [Previous](@previous)

import SuperCombinators

final class SerialEncoder<Value, Output: RangeReplaceableCollection> {

    public let encode: (Value) -> Output

    public init(encode: @escaping (Value) -> Output) {
        self.encode = encode
    }
}

final class SerialPatternEncoder<Output: RangeReplaceableCollection> {

    public let encode: () -> Output

    public init(encode: @escaping () -> Output) {
        self.encode = encode
    }
}

extension SerialEncoder {

    func then<OtherValue>(_ other: SerialEncoder<OtherValue, Output>) -> SerialEncoder<(Value, OtherValue), Output> {
        return SerialEncoder<(Value, OtherValue), Output> { (value, otherValue) in
            var output = self.encode(value)
            output.append(contentsOf: other.encode(otherValue))
            return output
        }
    }

    func then(_ dummy: SerialPatternEncoder<Output>) -> SerialEncoder {
        return SerialEncoder { (value) in
            var output = self.encode(value)
            output.append(contentsOf: dummy.encode())
            return output
        }
    }
}

extension SerialPatternEncoder {

    func then<Value>(_ encoder: SerialEncoder<Value, Output>) -> SerialEncoder<Value, Output> {
        return SerialEncoder<Value, Output> { (value) in
            var output = self.encode()
            output.append(contentsOf: encoder.encode(value))
            return output
        }
    }

    func then(_ other: SerialPatternEncoder<Output>) -> SerialPatternEncoder {
        return SerialPatternEncoder {
            var output = self.encode()
            output.append(contentsOf: other.encode())
            return output
        }
    }
}

func & <LHS, RHS, O>(lhs: SerialEncoder<LHS, O>, rhs: SerialEncoder<RHS, O>) -> SerialEncoder<(LHS, RHS), O> {
    return lhs.then(rhs)
}

func & <V, O>(lhs: SerialEncoder<V, O>, rhs: SerialPatternEncoder<O>) -> SerialEncoder<V, O> {
    return lhs.then(rhs)
}

func & <V, O>(lhs: SerialPatternEncoder<O>, rhs: SerialEncoder<V, O>) -> SerialEncoder<V, O> {
    return lhs.then(rhs)
}

func & <O>(lhs: SerialPatternEncoder<O>, rhs: SerialPatternEncoder<O>) -> SerialPatternEncoder<O> {
    return lhs.then(rhs)
}

extension SerialEncoder {

    func map<OldValue>(transform: @escaping (OldValue) -> Value) -> SerialEncoder<OldValue, Output> {
        return SerialEncoder<OldValue, Output> { oldValue in
            return self.encode(transform(oldValue))
        }
    }
}

typealias SerialDecoder<Value, Input: Collection> = Parser<Value, Input> where Input.SubSequence: Collection
typealias SerialPatternDecoder<Input: Collection> = Pattern<Input> where Input.SubSequence: Collection

final class SerialPatternCoder<Medium: RangeReplaceableCollection> where Medium.SubSequence: Collection {

    let encoder: SerialPatternEncoder<Medium>
    let decoder: SerialPatternDecoder<Medium>

    init(encoder: SerialPatternEncoder<Medium>, decoder: SerialPatternDecoder<Medium>) {
        self.encoder = encoder
        self.decoder = decoder
    }
}

final class SerialCoder<Value, Medium: RangeReplaceableCollection> where Medium.SubSequence: Collection {

    let encoder: SerialEncoder<Value, Medium>
    let decoder: SerialDecoder<Value, Medium>

    init(encoder: SerialEncoder<Value, Medium>, decoder: SerialDecoder<Value, Medium>) {
        self.encoder = encoder
        self.decoder = decoder
    }
}

extension SerialCoder {

    func encode(_ value: Value) -> Medium {
        return encoder.encode(value)
    }

    func decode(_ input: Medium) -> Value? {
        return decoder.parse(input)
    }
}

extension SerialCoder {

    convenience init(encode: @escaping (Value) -> Medium, decode: @escaping (Medium.SubSequence) -> Parse<Value, Medium>?) {
        self.init(
            encoder: SerialEncoder<Value, Medium>(encode: encode),
            decoder: Parser<Value, Medium>(parsePrefix: decode)
        )
    }
}

extension SerialCoder {

    func then<OtherValue>(_ other: SerialCoder<OtherValue, Medium>) -> SerialCoder<(Value, OtherValue), Medium> {
        return SerialCoder<(Value, OtherValue), Medium>(
            encoder: self.encoder & other.encoder,
            decoder: self.decoder & other.decoder
        )
    }

    func then(_ other: SerialPatternCoder<Medium>) -> SerialCoder<Value, Medium> {
        return SerialCoder<Value, Medium>(
            encoder: self.encoder & other.encoder,
            decoder: self.decoder & other.decoder
        )
    }
}

extension SerialPatternCoder {

    func then<Value>(_ other: SerialCoder<Value, Medium>) -> SerialCoder<Value, Medium> {
        return SerialCoder<Value, Medium>(
            encoder: self.encoder & other.encoder,
            decoder: self.decoder & other.decoder
        )
    }

    func then(_ other: SerialPatternCoder<Medium>) -> SerialPatternCoder<Medium> {
        return SerialPatternCoder<Medium>(
            encoder: self.encoder & other.encoder,
            decoder: self.decoder & other.decoder
        )
    }
}

func & <LHS, RHS, O>(lhs: SerialCoder<LHS, O>, rhs: SerialCoder<RHS, O>) -> SerialCoder<(LHS, RHS), O> {
    return lhs.then(rhs)
}

func & <V, O>(lhs: SerialCoder<V, O>, rhs: SerialPatternCoder<O>) -> SerialCoder<V, O> {
    return lhs.then(rhs)
}

func & <V, O>(lhs: SerialPatternCoder<O>, rhs: SerialCoder<V, O>) -> SerialCoder<V, O> {
    return lhs.then(rhs)
}

func & <O>(lhs: SerialPatternCoder<O>, rhs: SerialPatternCoder<O>) -> SerialPatternCoder<O> {
    return lhs.then(rhs)
}

extension SerialCoder {

    func map<NewValue>(transform: @escaping (Value) -> NewValue, inverse: @escaping (NewValue) -> Value) -> SerialCoder<NewValue, Medium> {
        return SerialCoder<NewValue, Medium>(
            encoder: encoder.map(transform: inverse),
            decoder: decoder.map(transform)
        )
    }
}

extension SerialEncoder where Value == Output.Element {

    static var single: SerialEncoder {
        return SerialEncoder { value in
            var output = Output()
            output.append(value)
            return output
        }
    }
}

extension SerialCoder where Value == Medium.Element {

    static var single: SerialCoder {
        return SerialCoder(encoder: .single, decoder: .single)
    }
}

do {
    let character = SerialCoder<Character, String>.single

    let twoCharacters = character & character

    let ab = "ab"

    let decoded = twoCharacters.decoder.parse(ab)!

    twoCharacters.encoder.encode(decoded)
}

do {
    let octet = SerialCoder<UInt8, Data>.single

    let uInt16BigEndian: SerialCoder<UInt16, Data> = (octet & octet)
        .map(
            transform: { bytes -> UInt16 in UInt16(bytes.0) << 8 + UInt16(bytes.1) },
            inverse: { uInt16 -> (UInt8, UInt8) in
                let byte0 = UInt8(uInt16 >> 8)
                let byte1 = UInt8(uInt16 % 256)
                return (byte0, byte1)
            }
        )

    let original: UInt16 = 0x0C0D
    let encoded = uInt16BigEndian.encode(original)
    uInt16BigEndian.decode(encoded)!
}



//: [Next](@next)
