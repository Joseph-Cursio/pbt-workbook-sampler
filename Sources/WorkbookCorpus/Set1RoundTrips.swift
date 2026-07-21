//  Set1RoundTrips.swift — Round-trips and inverses (Book Ch8, Ch17).
//
//  The template that gives the most bugs per line of thought:
//  `decode(encode(x)) == x`. Now the reader writes the law; the generator is
//  provided. Each corpus carries several mutants — asymmetric encoders and
//  dropped-field bugs — so a weak property (one that checks, say, only length)
//  leaves survivors and earns a survivor list.

import WorkbookGraderCore

// MARK: - S1.1 · run-length encoding

/// Compress a list into runs, and expand runs back into a list.
/// The round-trip law: `decompress(compress(x)) == x`.
public protocol RunLengthCodec {
    func compress(_ input: [Int]) -> [Run]
    func decompress(_ runs: [Run]) -> [Int]
}

/// A `(value, count)` run. A plain struct so `String(describing:)` renders
/// legibly in counterexamples.
public struct Run: Equatable {
    public let value: Int
    public let count: Int
    public init(value: Int, count: Int) {
        self.value = value
        self.count = count
    }
}

struct CorrectRunLength: RunLengthCodec {
    func compress(_ input: [Int]) -> [Run] {
        var runs: [Run] = []
        for value in input {
            if let last = runs.last, last.value == value {
                runs[runs.count - 1] = Run(value: value, count: last.count + 1)
            } else {
                runs.append(Run(value: value, count: 1))
            }
        }
        return runs
    }
    func decompress(_ runs: [Run]) -> [Int] {
        runs.flatMap { run in Array(repeating: run.value, count: run.count) }
    }
}

/// The bug: the compressor drops runs of length 1, so singletons vanish.
struct DropsSingletonsRunLength: RunLengthCodec {
    private let correct = CorrectRunLength()
    func compress(_ input: [Int]) -> [Run] {
        correct.compress(input).filter { $0.count > 1 }
    }
    func decompress(_ runs: [Run]) -> [Int] { correct.decompress(runs) }
}

/// The bug: the decompressor emits one copy too few for each run.
struct OffByOneRunLength: RunLengthCodec {
    private let correct = CorrectRunLength()
    func compress(_ input: [Int]) -> [Run] { correct.compress(input) }
    func decompress(_ runs: [Run]) -> [Int] {
        runs.flatMap { run in Array(repeating: run.value, count: max(0, run.count - 1)) }
    }
}

/// The bug: groups equal values *globally* instead of by adjacent run, so any
/// interleaving (e.g. `[0, 1, 0]`) is reordered and the round-trip is lost.
/// A classic real RLE mistake. (Survives any property that ignores element
/// *order* — e.g. one that compares sorted results or multisets.)
struct MergesNonAdjacentRunLength: RunLengthCodec {
    func compress(_ input: [Int]) -> [Run] {
        var counts: [Int: Int] = [:]
        var order: [Int] = []
        for value in input {
            if counts[value] == nil { order.append(value) }
            counts[value, default: 0] += 1
        }
        return order.map { Run(value: $0, count: counts[$0]!) }
    }
    func decompress(_ runs: [Run]) -> [Int] {
        runs.flatMap { run in Array(repeating: run.value, count: run.count) }
    }
}

// MARK: - S1.2 · CSV of integers

/// Encode a list of ints to a comma-joined string and back.
/// The round-trip law: `decode(encode(x)) == x`.
public protocol IntListCSVCodec {
    func encode(_ input: [Int]) -> String
    func decode(_ text: String) -> [Int]
}

struct CorrectCSV: IntListCSVCodec {
    func encode(_ input: [Int]) -> String {
        input.map(String.init).joined(separator: ",")
    }
    func decode(_ text: String) -> [Int] {
        text.isEmpty ? [] : text.split(separator: ",").map { Int($0) ?? 0 }
    }
}

/// The bug: the empty list encodes to "" but decodes back to `[0]`.
struct EmptyBugCSV: IntListCSVCodec {
    func encode(_ input: [Int]) -> String {
        input.map(String.init).joined(separator: ",")
    }
    func decode(_ text: String) -> [Int] {
        text.split(separator: ",").map { Int($0) ?? 0 }
            .isEmpty ? [0] : text.split(separator: ",").map { Int($0) ?? 0 }
    }
}

/// The bug: the encoder uses "-" as the separator, colliding with minus signs,
/// so any negative value corrupts the round-trip.
struct DashSeparatorCSV: IntListCSVCodec {
    func encode(_ input: [Int]) -> String {
        input.map(String.init).joined(separator: "-")
    }
    func decode(_ text: String) -> [Int] {
        text.isEmpty ? [] : text.split(separator: "-").map { Int($0) ?? 0 }
    }
}

// MARK: - Corpora

public enum Set1 {
    public static var runLength: Corpus<any RunLengthCodec> {
        Corpus(
            name: "Set 1 · S1.1 run-length round-trip",
            reference: CorrectRunLength(),
            mutants: [
                Mutant(id: "rle.drops-singletons",
                       explanation: "compressor drops runs of length 1",
                       subject: DropsSingletonsRunLength()),
                Mutant(id: "rle.off-by-one",
                       explanation: "decompressor emits count-1 copies per run",
                       subject: OffByOneRunLength()),
                Mutant(id: "rle.merges-non-adjacent",
                       explanation: "groups equal values globally, losing interleaving order",
                       subject: MergesNonAdjacentRunLength())
            ]
        )
    }

    public static var csv: Corpus<any IntListCSVCodec> {
        Corpus(
            name: "Set 1 · S1.2 CSV round-trip",
            reference: CorrectCSV(),
            mutants: [
                Mutant(id: "csv.empty-becomes-zero",
                       explanation: "empty list decodes back to [0]",
                       subject: EmptyBugCSV()),
                Mutant(id: "csv.dash-separator",
                       explanation: "uses '-' as separator, colliding with minus signs",
                       subject: DashSeparatorCSV())
            ]
        )
    }
}
