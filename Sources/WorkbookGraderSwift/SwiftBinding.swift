//  SwiftBinding.swift — Layer 2. Binds the language-neutral contract to the
//  `swift-property-based` engine, and nothing more.
//
//  This is the only file a Swift port would throw away. `WorkbookGraderCore`
//  (the pedagogy) stays; a fast-check port writes its own binding here.

import PropertyBased
// Re-export the contract so downstream code imports one module and writes
// `Property`, `Corpus`, `Grade` unqualified.
@_exported import WorkbookGraderCore

/// Adapts an engine `Generator` (a.k.a. `Gen`) plus a seeded `Xoshiro` into the
/// core `InputSource`. The seed makes every grade reproducible: the same
/// submission always meets the same inputs, so a counterexample a reader sees is
/// the one they can reproduce.
public struct SwiftInputSource<Value, Shrink: SendableSequenceType>: InputSource {
    /// A fixed, arbitrary default seed. Grading is deterministic by default;
    /// pass a different seed to vary the input sample.
    public static var defaultSeed: UInt64 { 0xB00C_5EED_1DEA_0FF5 }

    private let generator: Generator<Value, Shrink>
    private var rng: Xoshiro

    public init(_ generator: Generator<Value, Shrink>,
                seed: UInt64 = SwiftInputSource.defaultSeed) {
        self.generator = generator
        self.rng = Xoshiro(seed: Self.expand(seed))
    }

    public mutating func next() -> Value {
        generator.run(using: &rng)
    }

    /// Disperse a single seed into Xoshiro's 4-word state with SplitMix64, so a
    /// small seed like `1` still gives a well-mixed starting state (a mostly-zero
    /// tuple would generate poorly).
    private static func expand(_ seed: UInt64) -> (UInt64, UInt64, UInt64, UInt64) {
        var state = seed
        func nextWord() -> UInt64 {
            state = state &+ 0x9E37_79B9_7F4A_7C15
            var mixed = state
            mixed = (mixed ^ (mixed >> 30)) &* 0xBF58_476D_1CE4_E5B9
            mixed = (mixed ^ (mixed >> 27)) &* 0x94D0_49BB_1331_11EB
            return mixed ^ (mixed >> 31)
        }
        return (nextWord(), nextWord(), nextWord(), nextWord())
    }
}

extension Corpus {
    /// Grade a property against this corpus using an engine generator — the
    /// convenience the reader-facing loop calls. Deterministic given the seed.
    public func grade<Value, Shrink: SendableSequenceType>(
        with property: Property<Value, Subject>,
        using generator: Generator<Value, Shrink>,
        count: Int = 200,
        seed: UInt64 = SwiftInputSource<Value, Shrink>.defaultSeed
    ) -> Grade {
        var source = SwiftInputSource(generator, seed: seed)
        return grade(with: property, drawing: &source, count: count)
    }
}
