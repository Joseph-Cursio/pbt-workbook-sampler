//  DefectPinTests.swift — the defect corpus, pinned.
//
//  A defect is defined by *what catches it*, not by its id and its doc comment.
//  `rle.merges-non-adjacent` proved that the expensive way: the Python and
//  TypeScript ports implemented it by sorting, which reorders as well as
//  regroups, so `[1, 0]` caught it and the interleaving lesson vanished. Every
//  other signal agreed across all three languages — same id, same explanation,
//  same grade, same undetected list — and only the counterexample differed,
//  which is the one field nobody diffs.
//
//  So each defect is pinned in BOTH directions:
//
//    - the *catching* input fixes that the bug is at least this strong
//    - the *sparing* input fixes that it is no stronger
//
//  Either alone is worthless. A defect that breaks everything satisfies the
//  first; one that breaks nothing satisfies the second. What forked was neither
//  — it was the bug's *strength*, which only the pair constrains.
//
//  Each pin also checks that the *reference* survives the catching input, so a
//  pin cannot pass by testing a law that rejects everything.
//
//  These inputs are the specification of the bug, shared with the Python and
//  TypeScript corpora. Changing one means the corpora have forked. Do not
//  "update the expected value" to make a test pass.

import Testing
import WorkbookGraderCore
@testable import WorkbookCorpus

/// Pins one defect to its exact strength.
private func pin<Input, Subject>(
    _ corpus: Corpus<Subject>,
    _ defectID: String,
    law: (Input, Subject) -> Bool,
    catching: Input,
    sparing: Input,
    sourceLocation: SourceLocation = #_sourceLocation
) {
    guard let defect = corpus.defects.first(where: { $0.id == defectID }) else {
        Issue.record("no defect '\(defectID)' in \(corpus.name)", sourceLocation: sourceLocation)
        return
    }
    #expect(!law(catching, defect.subject),
            "\(defectID) is weaker than pinned: \(catching) no longer catches it",
            sourceLocation: sourceLocation)
    #expect(law(sparing, defect.subject),
            "\(defectID) is stronger than pinned: \(sparing) now catches it too",
            sourceLocation: sourceLocation)
    #expect(law(catching, corpus.reference),
            "\(defectID): correct code must survive \(catching), or the pin tests nothing",
            sourceLocation: sourceLocation)
}

@Suite("The defect corpus is pinned")
struct DefectPinTests {

    // MARK: Warm-up

    @Test("W1 · reverse.drops-last")
    func reverseDropsLast() {
        pin(Warmup.reverse, "reverse.drops-last",
            law: { (xs: [Int], r: any ListReverser) in r.reverse(r.reverse(xs)) == xs },
            // Caught: any non-empty list loses its last element.
            catching: [0],
            // Spared: the empty list has no last element to drop.
            sparing: [])
    }

    @Test("W2 · abs.identity")
    func absIdentity() {
        pin(Warmup.absolute, "abs.identity",
            law: { (x: Int, a: any Absoluter) in a.absolute(x) >= 0 && (a.absolute(x) == x || a.absolute(x) == -x) },
            // Caught: a negative stays negative.
            catching: -1,
            // Spared: a non-negative is already its own absolute value.
            sparing: 1)
    }

    @Test("W3 · clamp.no-upper-bound")
    func clampNoUpperBound() {
        pin(Warmup.clamp, "clamp.no-upper-bound",
            law: { (args: (Int, Int, Int), c: any Clamper) in
                let r = c.clamp(args.0, low: args.1, high: args.2)
                return args.1 <= r && r <= args.2
            },
            // Caught: a value above `high` is never brought down.
            catching: (1, 0, 0),
            // Spared: a value already in range needs no upper bound applied.
            sparing: (0, 0, 1))
    }

    // MARK: Set 1 · S1.1 run-length

    private static let rleLaw: @Sendable ([Int], any RunLengthCodec) -> Bool = { xs, c in
        c.decompress(c.compress(xs)) == xs
    }

    @Test("S1.1 · rle.drops-singletons")
    func rleDropsSingletons() {
        pin(Set1.runLength, "rle.drops-singletons", law: Self.rleLaw,
            // Caught: a run of length 1 is discarded.
            catching: [0],
            // Spared: no singleton runs, nothing to drop.
            sparing: [0, 0])
    }

    @Test("S1.1 · rle.off-by-one")
    func rleOffByOne() {
        pin(Set1.runLength, "rle.off-by-one", law: Self.rleLaw,
            // Caught: one copy short on every run.
            catching: [0],
            // Spared: no runs at all, so nothing is emitted short.
            sparing: [])
    }

    @Test("S1.1 · rle.merges-non-adjacent")
    func rleMergesNonAdjacent() {
        pin(Set1.runLength, "rle.merges-non-adjacent", law: Self.rleLaw,
            // Caught: a value appears, stops, and comes back. This is the bug —
            // interleaving, not ordering.
            catching: [2, 0, 2],
            // Spared: merely out of order, nothing interleaved. A defect that
            // fails here is the weaker *reordering* bug wearing this one's name,
            // which is exactly how both ports forked.
            sparing: [1, 0])
    }

    // MARK: Set 1 · S1.2 CSV

    private static let csvLaw: @Sendable ([Int], any IntListCSVCodec) -> Bool = { xs, c in
        c.decode(c.encode(xs)) == xs
    }

    @Test("S1.2 · csv.empty-becomes-zero")
    func csvEmptyBecomesZero() {
        pin(Set1.csv, "csv.empty-becomes-zero", law: Self.csvLaw,
            // Caught: the empty-input edge case, and only that.
            catching: [],
            // Spared: any non-empty list decodes normally.
            sparing: [1])
    }

    @Test("S1.2 · csv.dash-separator")
    func csvDashSeparator() {
        pin(Set1.csv, "csv.dash-separator", law: Self.csvLaw,
            // Caught: a minus sign collides with the separator.
            catching: [-1],
            // Spared: non-negative values round-trip through '-' just fine,
            // which is what makes this defect invisible to a careless generator.
            sparing: [1, 2])
    }

    // MARK: Completeness

    @Test("every defect in the sampler has a pin")
    func everyDefectIsPinned() {
        let pinned: Set<String> = [
            "reverse.drops-last", "abs.identity", "clamp.no-upper-bound",
            "rle.drops-singletons", "rle.off-by-one", "rle.merges-non-adjacent",
            "csv.empty-becomes-zero", "csv.dash-separator",
        ]
        var known: Set<String> = []
        known.formUnion(Warmup.reverse.defects.map(\.id))
        known.formUnion(Warmup.absolute.defects.map(\.id))
        known.formUnion(Warmup.clamp.defects.map(\.id))
        known.formUnion(Set1.runLength.defects.map(\.id))
        known.formUnion(Set1.csv.defects.map(\.id))

        // An unpinned defect is how the next silent fork gets in.
        #expect(known.subtracting(pinned).isEmpty,
                "unpinned defects: \(known.subtracting(pinned).sorted())")
    }
}
