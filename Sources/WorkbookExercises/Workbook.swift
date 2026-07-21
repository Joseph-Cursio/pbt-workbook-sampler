//  Workbook.swift — the provided generators and the sampler's exercise registry.
//
//  Sampler scope: Warm-up (W1–W3) + Set 1 (S1.1–S1.2) only. No Set 3, no lift,
//  no secret mutants — those live in the full, paid product.

import PropertyBased
import WorkbookGraderSwift
import WorkbookCorpus

enum ProvidedGenerators {
    static let smallList = Gen.int(in: -20...20).array(of: 0...6)
    static let anyInt = Gen.int(in: -1_000...1_000)
    static let clampTriple = zip(Gen.int(in: -50...50),
                                 Gen.int(in: -50...50),
                                 Gen.int(in: -50...50))
        .map { value, boundA, boundB in
            (value, min(boundA, boundB), max(boundA, boundB))
        }
    static let repeatyList = Gen.int(in: 0...3).array(of: 0...8)
    static let signedList = Gen.int(in: -50...50).array(of: 0...6)
}

/// One exercise, type-erased to a `() -> Grade` so a heterogeneous list of them
/// can be graded uniformly by the runner.
public struct GradedExercise {
    public let id: String
    public let title: String
    public let chapterRef: String
    public let promptPath: String
    public let readerAuthored: Bool
    private let runner: (Int) -> Grade

    init<Value, Shrink: SendableSequenceType, Subject>(
        id: String,
        title: String,
        chapterRef: String,
        promptPath: String,
        readerAuthored: Bool,
        corpus: Corpus<Subject>,
        generator: Generator<Value, Shrink>,
        property: Property<Value, Subject>
    ) {
        self.id = id
        self.title = title
        self.chapterRef = chapterRef
        self.promptPath = promptPath
        self.readerAuthored = readerAuthored
        self.runner = { count in
            corpus.grade(with: property, using: generator, count: count)
        }
    }

    public func grade(count: Int = 200) -> Grade { runner(count) }
}

public enum Workbook {
    /// The free sampler slice, in teaching order.
    public static var allExercises: [GradedExercise] {
        [
            GradedExercise(
                id: "W1", title: "Reverse round-trip",
                chapterRef: "Ch5", promptPath: "exercises/warmup/w1-reverse.md",
                readerAuthored: false,
                corpus: Warmup.reverse, generator: ProvidedGenerators.smallList,
                property: Submissions.reverseRoundTrip),
            GradedExercise(
                id: "W2", title: "Absolute value",
                chapterRef: "Ch5", promptPath: "exercises/warmup/w2-absolute.md",
                readerAuthored: false,
                corpus: Warmup.absolute, generator: ProvidedGenerators.anyInt,
                property: Submissions.absoluteValue),
            GradedExercise(
                id: "W3", title: "Clamp",
                chapterRef: "Ch5", promptPath: "exercises/warmup/w3-clamp.md",
                readerAuthored: false,
                corpus: Warmup.clamp, generator: ProvidedGenerators.clampTriple,
                property: Submissions.clampInRange),

            GradedExercise(
                id: "S1.1", title: "Run-length round-trip",
                chapterRef: "Ch8, Ch17", promptPath: "exercises/set1-round-trips/s1-1-run-length.md",
                readerAuthored: true,
                corpus: Set1.runLength, generator: ProvidedGenerators.repeatyList,
                property: Submissions.runLengthRoundTrip),
            GradedExercise(
                id: "S1.2", title: "CSV round-trip",
                chapterRef: "Ch8, Ch17", promptPath: "exercises/set1-round-trips/s1-2-csv.md",
                readerAuthored: true,
                corpus: Set1.csv, generator: ProvidedGenerators.signedList,
                property: Submissions.csvRoundTrip)
        ]
    }
}
