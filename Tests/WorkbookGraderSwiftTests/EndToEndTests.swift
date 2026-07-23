//  EndToEndTests.swift — the sampler's answer key.
//
//  Proves the free slice grades correctly through the real engine: the Warm-up
//  and Set 1 corpora are fully detectable by a correct property, and the Set 1
//  starters leave the full undetected list.

import Testing
import PropertyBased
import WorkbookGraderSwift
@testable import WorkbookCorpus
import WorkbookExercises

@Suite("Sampler end-to-end grading")
struct EndToEndTests {

    @Test("Set 1 · run-length: correct round-trip detects every defect")
    func runLengthAnswerKey() {
        let property = Property<[Int], any RunLengthCodec>("round-trip") { input, codec in
            codec.decompress(codec.compress(input)) == input
        }
        let grade = Set1.runLength.grade(with: property,
                                         using: Gen.int(in: 0...3).array(of: 0...8),
                                         count: 300)
        #expect(grade.passed, Comment(rawValue: grade.render()))
    }

    @Test("Set 1 · CSV: correct round-trip detects every defect")
    func csvAnswerKey() {
        let property = Property<[Int], any IntListCSVCodec>("round-trip") { input, codec in
            codec.decode(codec.encode(input)) == input
        }
        let grade = Set1.csv.grade(with: property,
                                   using: Gen.int(in: -50...50).array(of: 0...6),
                                   count: 300)
        #expect(grade.passed, Comment(rawValue: grade.render()))
    }

    @Test("Warm-up starters are correct and each detects its one defect")
    func warmupStartersDetect() {
        let reverse = Warmup.reverse.grade(with: Submissions.reverseRoundTrip,
                                           using: Gen.int(in: -20...20).array(of: 0...6))
        #expect(reverse.passed)
        #expect(reverse.detected.count == 1)
        #expect(reverse.detected.first?.counterexample != nil)
    }

    @Test("every reader-authored starter leaves work to do")
    func startersLeaveUndetectedDefects() {
        // Set 1's starters are stubs (`return true`) and detect nothing. The
        // lift starter (W4) is deliberately different: a real-but-weak
        // generalization that detects one defect and leaves one — so assert on
        // undetected defects, not on zero detects. Mirrors the full lab's test.
        for exercise in Workbook.allExercises where exercise.readerAuthored {
            let grade = exercise.grade()
            #expect(grade.referenceHeld, "\(exercise.id) reference should hold")
            #expect(!grade.passed, "\(exercise.id) starter should not yet pass")
            #expect(!grade.undetected.isEmpty, "\(exercise.id) should list undetected defects")
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
        #expect(first.detected.map(\.counterexample) == second.detected.map(\.counterexample))
    }
}
