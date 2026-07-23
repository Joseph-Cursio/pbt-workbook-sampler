//  Workbook.swift — the provided generators and the sampler's exercise registry.
//
//  Sampler scope: Warm-up (W1–W3) + Set 1 (S1.1–S1.2) only. No Set 3, no lift,
//  no secret defects — those live in the full, paid product.

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

/// How each provided generator's inputs reduce. Paired with the generators above:
/// a shrinker must produce values the *same shape* as its generator, or the
/// reduced counterexample won't be a legal input for the exercise.
enum ProvidedShrinkers {
    static func intList(_ values: [Int]) -> [[Int]] {
        Shrinkers.array(values, element: Shrinkers.integer)
    }

    static func int(_ value: Int) -> [Int] {
        Shrinkers.integer(value)
    }

    /// The clamp triple carries an invariant the generator establishes —
    /// `low <= high`. Shrinking must preserve it, or the reader is handed a
    /// "counterexample" that could never have been generated and that the
    /// property was never meant to hold for.
    static func clampTriple(_ triple: (Int, Int, Int)) -> [(Int, Int, Int)] {
        let (value, low, high) = triple
        var candidates: [(Int, Int, Int)] = []
        for smaller in Shrinkers.integer(value) { candidates.append((smaller, low, high)) }
        for smaller in Shrinkers.integer(low) where smaller <= high {
            candidates.append((value, smaller, high))
        }
        for smaller in Shrinkers.integer(high) where low <= smaller {
            candidates.append((value, low, smaller))
        }
        return candidates
    }
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

    /// - Parameter shrink: how to reduce a failing input before the reader reads
    ///   it. Every exercise supplies one — an unshrunk counterexample is a much
    ///   weaker teaching artifact, because the reader has to work out which part
    ///   of it the bug actually needed.
    init<Value, Shrink: SendableSequenceType, Subject>(
        id: String,
        title: String,
        chapterRef: String,
        promptPath: String,
        readerAuthored: Bool,
        corpus: Corpus<Subject>,
        generator: Generator<Value, Shrink>,
        property: Property<Value, Subject>,
        shrink: @escaping (Value) -> [Value] = { _ in [] }
    ) {
        self.id = id
        self.title = title
        self.chapterRef = chapterRef
        self.promptPath = promptPath
        self.readerAuthored = readerAuthored
        self.runner = { count in
            corpus.grade(with: property, using: generator, count: count, shrink: shrink)
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
                property: Submissions.reverseRoundTrip,
                shrink: ProvidedShrinkers.intList),
            GradedExercise(
                id: "W2", title: "Absolute value",
                chapterRef: "Ch5", promptPath: "exercises/warmup/w2-absolute.md",
                readerAuthored: false,
                corpus: Warmup.absolute, generator: ProvidedGenerators.anyInt,
                property: Submissions.absoluteValue,
                shrink: ProvidedShrinkers.int),
            GradedExercise(
                id: "W3", title: "Clamp",
                chapterRef: "Ch5", promptPath: "exercises/warmup/w3-clamp.md",
                readerAuthored: false,
                corpus: Warmup.clamp, generator: ProvidedGenerators.clampTriple,
                property: Submissions.clampInRange,
                shrink: ProvidedShrinkers.clampTriple),

            GradedExercise(
                id: "S1.1", title: "Run-length round-trip",
                chapterRef: "Ch8, Ch17", promptPath: "exercises/set1-round-trips/s1-1-run-length.md",
                readerAuthored: true,
                corpus: Set1.runLength, generator: ProvidedGenerators.repeatyList,
                property: Submissions.runLengthRoundTrip,
                shrink: ProvidedShrinkers.intList),
            GradedExercise(
                id: "S1.2", title: "CSV round-trip",
                chapterRef: "Ch8, Ch17", promptPath: "exercises/set1-round-trips/s1-2-csv.md",
                readerAuthored: true,
                corpus: Set1.csv, generator: ProvidedGenerators.signedList,
                property: Submissions.csvRoundTrip,
                shrink: ProvidedShrinkers.intList)
        ]
    }
}
