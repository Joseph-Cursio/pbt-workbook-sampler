//  GraderTests.swift — proves the language-neutral core with NO engine at all.
//
//  If these pass importing only WorkbookGraderCore, the pedagogy is genuinely
//  substrate-free — the portability claim, checked.

import Testing
@testable import WorkbookGraderCore

/// A trivial input source over a fixed list — the stand-in for "an engine's
/// generator" that a language port would replace.
private struct ListSource<Element>: InputSource {
    var values: [Element]
    var index = 0
    mutating func next() -> Element {
        defer { index = (index + 1) % values.count }
        return values[index]
    }
}

/// Subjects are plain closures here — the core doesn't care what a subject is.
private struct Doubler { let apply: (Int) -> Int }

@Suite("Core grader — engine-free")
struct GraderTests {

    private func doublingCorpus() -> Corpus<Doubler> {
        Corpus(
            name: "double",
            reference: Doubler { $0 * 2 },
            mutants: [
                Mutant(id: "off-by-one", explanation: "returns 2x+1",
                       subject: Doubler { $0 * 2 + 1 }),
                Mutant(id: "identity", explanation: "returns x",
                       subject: Doubler { $0 })
            ]
        )
    }

    @Test("a correct property kills every mutant and passes")
    func correctPropertyPasses() {
        let corpus = doublingCorpus()
        let property = Property<Int, Doubler>("f(x) == x + x") { input, subject in
            subject.apply(input) == input + input
        }
        var source = ListSource(values: [1, 2, 3, 4, 5])
        let grade = corpus.grade(with: property, drawing: &source, count: 20)

        #expect(grade.referenceHeld)
        #expect(grade.survivors.isEmpty)
        #expect(grade.killed.count == 2)
        #expect(grade.passed)
        #expect(grade.score == 1.0)
    }

    @Test("a non-refutable property leaves every mutant alive")
    func trivialPropertyLeavesSurvivors() {
        let corpus = doublingCorpus()
        let property = Property<Int, Doubler>("true") { _, _ in true }
        var source = ListSource(values: [1, 2, 3])
        let grade = corpus.grade(with: property, drawing: &source, count: 10)

        #expect(grade.referenceHeld)
        #expect(grade.killed.isEmpty)
        #expect(grade.survivors.count == 2)
        #expect(!grade.passed)
        #expect(grade.score == 0.0)
    }

    @Test("an over-strong property is reported against the reference, not passed")
    func overStrongPropertyFailsReference() {
        let corpus = doublingCorpus()
        // Rejects correct code: claims f(x) == x (false for the reference).
        let property = Property<Int, Doubler>("f(x) == x") { input, subject in
            subject.apply(input) == input
        }
        var source = ListSource(values: [1, 2, 3])
        let grade = corpus.grade(with: property, drawing: &source, count: 10)

        #expect(!grade.referenceHeld)
        #expect(grade.referenceCounterexample != nil)
        #expect(!grade.passed)
        #expect(grade.render().contains("over-strong"))
    }

    @Test("strength classifies the ratchet: over-strong / non-refutable / weak / characterizing")
    func strengthClassification() {
        let corpus = doublingCorpus()
        var source = ListSource(values: [1, 2, 3])

        // Characterizing — kills the whole corpus.
        let full = Property<Int, Doubler>("f(x) == 2x") { $1.apply($0) == $0 * 2 }
        #expect(corpus.grade(with: full, drawing: &source, count: 9).strength == .characterizing)

        // Non-refutable — holds, kills nothing.
        var trivialSource = ListSource(values: [1, 2, 3])
        let trivial = Property<Int, Doubler>("true") { _, _ in true }
        #expect(corpus.grade(with: trivial, drawing: &trivialSource, count: 9).strength == .nonRefutable)

        // Weak — kills the identity mutant (result != input) but not off-by-one.
        var weakSource = ListSource(values: [1, 2, 3])
        let weak = Property<Int, Doubler>("f(x) != x") { $1.apply($0) != $0 }
        let weakGrade = corpus.grade(with: weak, drawing: &weakSource, count: 9)
        #expect(weakGrade.strength == .weak)
        #expect(weakGrade.strengthHeadline.contains("true but weak"))

        // Over-strong — fails on the reference.
        var overStrongSource = ListSource(values: [1, 2, 3])
        let overStrong = Property<Int, Doubler>("f(x) == x") { $1.apply($0) == $0 }
        #expect(corpus.grade(with: overStrong, drawing: &overStrongSource, count: 9).strength == .overStrong)
    }

    @Test("killed mutants carry a reproducing counterexample")
    func killsRecordCounterexample() {
        let corpus = doublingCorpus()
        let property = Property<Int, Doubler>("f(x) == 2x") { input, subject in
            subject.apply(input) == input * 2
        }
        var source = ListSource(values: [7])
        let grade = corpus.grade(with: property, drawing: &source, count: 3)
        #expect(grade.killed.allSatisfy { $0.counterexample == "7" })
    }
}
