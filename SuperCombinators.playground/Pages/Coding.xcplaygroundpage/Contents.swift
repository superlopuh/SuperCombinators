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

    var array: SerialEncoder<[Value], Output> {
        return SerialEncoder<[Value], Output> { values in
            var output = Output()

            for value in values {
                output.append(contentsOf: self.encode(value))
            }

            return output
        }
    }
}

postfix func * <Value, Output> (encoder: SerialEncoder<Value, Output>) -> SerialEncoder<[Value], Output> {
    return encoder.array
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

    func contramap<OldValue>(_ transform: @escaping (OldValue) -> Value) -> SerialEncoder<OldValue, Output> {
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

extension SerialEncoder {

    func pattern(_ value: Value) -> SerialPatternEncoder<Output> {
        return SerialPatternEncoder<Output> { self.encode(value) }
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

    var array: SerialCoder<[Value], Medium> {
        return SerialCoder<[Value], Medium>(
            encoder: encoder*,
            decoder: decoder*
        )
    }
}

postfix func * <Value, Medium> (coder: SerialCoder<Value, Medium>) -> SerialCoder<[Value], Medium> {
    return coder.array
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
            encoder: encoder.contramap(inverse),
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

extension SerialEncoder {

    func and(_ other: SerialEncoder) -> SerialEncoder {
        return SerialEncoder { value in
            var output = self.encode(value)
            output.append(contentsOf: other.encode(value))
            return output
        }
    }

    func or<OtherValue>(_ other: SerialEncoder<OtherValue, Output>) -> SerialEncoder<Either<Value, OtherValue>, Output> {
        return SerialEncoder<Either<Value, OtherValue>, Output> { value in
            return value.collapse(self.encode, other.encode)
        }
    }
}

enum Either<LHS, RHS> {
    case lhs(LHS)
    case rhs(RHS)

    var tag: Tag {
        switch self {
        case .lhs: return .lhs
        case .rhs: return .rhs
        }
    }

    func collapse<V>(_ lhsTransform: (LHS) -> V, _ rhsTransform: (RHS) -> V) -> V {
        switch self {
        case .lhs(let lhs):
            return lhsTransform(lhs)
        case .rhs(let rhs):
            return rhsTransform(rhs)
        }
    }
}

enum Tag {
    case lhs, rhs

    func choose<LHS, RHS>(_ values: (LHS, RHS)) -> Either<LHS, RHS> {
        switch self {
        case .lhs: return .lhs(values.0)
        case .rhs: return .rhs(values.1)
        }
    }
}

extension SerialDecoder where Value == Tag {

    func thenEither<LHS, RHS>(_ lhs: SerialDecoder<LHS, Input>, _ rhs: SerialDecoder<RHS, Input>) -> SerialDecoder<Either<LHS, RHS>, Input> {
        return self.flatMap { tag -> SerialDecoder<Either<LHS, RHS>, Input> in
            switch tag {
            case .lhs: return lhs.map(Either.lhs)
            case .rhs: return rhs.map(Either.rhs)
            }
        }
    }
}

extension SerialEncoder where Value == Tag {

    func thenEither<LHS, RHS>(_ lhs: SerialEncoder<LHS, Output>, _ rhs: SerialEncoder<RHS, Output>) -> SerialEncoder<Either<LHS, RHS>, Output> {
        return self.contramap({ $0.tag }).and(lhs.or(rhs))
    }
}

extension SerialCoder where Value == Tag {

    func thenEither<LHS, RHS>(_ lhs: SerialCoder<LHS, Medium>, _ rhs: SerialCoder<RHS, Medium>) -> SerialCoder<Either<LHS, RHS>, Medium> {
        return SerialCoder<Either<LHS, RHS>, Medium>(
            encoder: self.encoder.thenEither(lhs.encoder, rhs.encoder),
            decoder: self.decoder.thenEither(lhs.decoder, rhs.decoder)
        )
    }
}

extension SerialPatternEncoder {

    static func value(_ element: Output.Element) -> SerialPatternEncoder {
        return SerialPatternEncoder {
            var output = Output()
            output.append(element)
            return output
        }
    }
}

extension SerialPatternCoder {

    static func value(_ element: Medium.Element) -> SerialPatternCoder {
        return SerialPatternCoder(encoder: .value(element), decoder: .single)
    }
}

extension SerialCoder {

    func helpsDecodeFollowing<Following>(ambiguousEncoder: SerialEncoder<Following, Medium>, contramap: @escaping (Following) -> Value, decoderFlatMap: @escaping (Value) -> SerialDecoder<Following, Medium>) -> SerialCoder<Following, Medium> {
        let encoder = self.encoder.contramap(contramap).and(ambiguousEncoder)
        let decoder = self.decoder.flatMap(decoderFlatMap)
        return SerialCoder<Following, Medium>(
            encoder: encoder,
            decoder: decoder
        )
    }
}

func id<Value>(_ value: Value) -> Value { return value }
func duplicate<Value>(_ value: Value) -> (Value, Value) { return (value, value) }

do {
    typealias OneOrTwo = Either<Int, (Int, Int)>

    let one = SerialCoder<Int, [Int]>.single
    let two = one & one

    let tag: SerialCoder<Tag, [Int]> = one.map(
        transform: { 1 == $0 ? .lhs : .rhs },
        inverse: { Tag.lhs == $0 ? 1 : 2 }
    )

    let oneOrTwo = tag.thenEither(one, two)

    let original = OneOrTwo.rhs((12, 13))

    let encoded = oneOrTwo.encode(original)
    let decoded = oneOrTwo.decode(encoded)!
}

do {
    let int = SerialCoder<Int, [Int]>.single

    let arrayDecoder = int.decoder*
    let count = int
    let arrayWithCount = count.helpsDecodeFollowing(
        ambiguousEncoder: int.encoder.array,
        contramap: { $0.count },
        decoderFlatMap: { count in int.decoder.count(count) }
    )

    let arrays = arrayWithCount*

    let original = [[2], [4, 5, 6]]

    let encoded = arrays.encode(original)
    arrays.decode(encoded)!
}

//: [Next](@next)
