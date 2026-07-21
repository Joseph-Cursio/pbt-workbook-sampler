//  Warmup.swift — "Make one property fail" (Book Ch5).
//
//  The mechanics, not the thinking. The reader is *handed* a correct property
//  and a broken function; the job is to run it and read the shrunk
//  counterexample. Each corpus here has a correct reference and exactly ONE
//  obvious mutant, so the grade shows a single kill with its reproduction.

import WorkbookGraderCore

// MARK: - W1 · list reversal round-trips

/// Reversing a list twice must return the original list.
public protocol ListReverser {
    func reverse(_ list: [Int]) -> [Int]
}

struct CorrectReverser: ListReverser {
    func reverse(_ list: [Int]) -> [Int] { list.reversed() }
}

/// The bug: reverses but drops the last element, so a double reverse loses data.
struct DroppingReverser: ListReverser {
    func reverse(_ list: [Int]) -> [Int] {
        Array(list.reversed().dropLast())
    }
}

// MARK: - W2 · absolute value

/// `abs` is non-negative and equals either `x` or `-x`.
public protocol Absoluter {
    func absolute(_ value: Int) -> Int
}

struct CorrectAbsoluter: Absoluter {
    func absolute(_ value: Int) -> Int { value < 0 ? -value : value }
}

/// The bug: returns the value unchanged, so negatives stay negative.
struct IdentityAbsoluter: Absoluter {
    func absolute(_ value: Int) -> Int { value }
}

// MARK: - W3 · clamp

/// `clamp(v, lo, hi)` lands inside `lo...hi`.
public protocol Clamper {
    func clamp(_ value: Int, low: Int, high: Int) -> Int
}

struct CorrectClamper: Clamper {
    func clamp(_ value: Int, low: Int, high: Int) -> Int {
        min(max(value, low), high)
    }
}

/// The bug: enforces the lower bound but forgets the upper one.
struct HalfClamper: Clamper {
    func clamp(_ value: Int, low: Int, high: Int) -> Int {
        max(value, low)
    }
}

// MARK: - Corpora

public enum Warmup {
    public static var reverse: Corpus<any ListReverser> {
        Corpus(
            name: "Warm-up W1 · reverse round-trip",
            reference: CorrectReverser(),
            mutants: [
                Mutant(id: "reverse.drops-last",
                       explanation: "reverses but drops the last element",
                       subject: DroppingReverser())
            ]
        )
    }

    public static var absolute: Corpus<any Absoluter> {
        Corpus(
            name: "Warm-up W2 · absolute value",
            reference: CorrectAbsoluter(),
            mutants: [
                Mutant(id: "abs.identity",
                       explanation: "returns the input unchanged; negatives stay negative",
                       subject: IdentityAbsoluter())
            ]
        )
    }

    public static var clamp: Corpus<any Clamper> {
        Corpus(
            name: "Warm-up W3 · clamp",
            reference: CorrectClamper(),
            mutants: [
                Mutant(id: "clamp.no-upper-bound",
                       explanation: "applies the lower bound but never the upper bound",
                       subject: HalfClamper())
            ]
        )
    }
}
