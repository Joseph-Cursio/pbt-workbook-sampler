//  EndToEndTests.swift — the sampler's answer key.
//
//  Proves the free slice grades correctly through the real engine: the Warm-up
//  and Set 1 corpora are fully killable by a correct property, and the Set 1
//  starters leave the full survivor list.

import Testing
import PropertyBased
import WorkbookGraderSwift
@testable import WorkbookCorpus
import WorkbookExercises

@Suite("Sampler end-to-end grading")
struct EndToEndTests {

    @Test("Set 1 · run-length: correct round-trip kills every mutant")
    func runLengthAnswerKey() {
        let property = Property<[Int], any RunLengthCodec>("round-trip") { input, codec in
            codec.decompress(codec.compress(input)) == input
        }
        let grade = Set1.runLength.grade(with: property,
                                         using: Gen.int(in: 0...3).array(of: 0...8),
                                         count: 300)
        #expect(grade.passed, Comment(rawValue: grade.render()))
    }

    @Test("Set 1 · CSV: correct round-trip kills every mutant")
    func csvAnswerKey() {
        let property = Property<[Int], any IntListCSVCodec>("round-trip") { input, codec in
            codec.decode(codec.encode(input)) == input
        }
        let grade = Set1.csv.grade(with: property,
                                   using: Gen.int(in: -50...50).array(of: 0...6),
                                   count: 300)
        #expect(grade.passed, Comment(rawValue: grade.render()))
    }

    @Test("Warm-up starters are correct and each kills its one mutant")
    func warmupStartersKill() {
        let reverse = Warmup.reverse.grade(with: Submissions.reverseRoundTrip,
                                           using: Gen.int(in: -20...20).array(of: 0...6))
        #expect(reverse.passed)
        #expect(reverse.killed.count == 1)
        #expect(reverse.killed.first?.counterexample != nil)
    }

    @Test("every reader-authored starter leaves all its mutants alive")
    func startersLeaveSurvivors() {
        for exercise in Workbook.allExercises where exercise.readerAuthored {
            let grade = exercise.grade()
            #expect(grade.referenceHeld, "\(exercise.id) reference should hold")
            #expect(grade.killed.isEmpty, "\(exercise.id) starter should kill nothing")
            #expect(!grade.survivors.isEmpty, "\(exercise.id) should list survivors")
        }
    }

    @Test("grading is deterministic across runs")
    func gradingIsDeterministic() {
        let property = Property<[Int], any RunLengthCodec>("round-trip") { input, codec in
            codec.decompress(codec.compress(input)) == input
        }
        let generator = Gen.int(in: 0...3).array(of: 0...8)
        let first = Set1.runLength.grade(with: property, using: generator, count: 100)
        let second = Set1.runLength.grade(with: property, using: generator, count: 100)
        #expect(first.killed.map(\.counterexample) == second.killed.map(\.counterexample))
    }
}
