//  Contract.swift — the language-neutral grading contract.
//
//  Everything a grade needs, and nothing about any particular PBT engine:
//  a *source of inputs*, a *property*, and a *mutant corpus*. A future port to
//  fast-check or Hypothesis reimplements the substrate behind `InputSource`;
//  this file does not change. (planning/workbook-portability.md — "the grader
//  is a language-neutral contract".)

/// A stream of inputs to try a property against.
///
/// The Swift binding wraps an engine `Gen` + a seeded RNG in this protocol; a
/// port wraps whatever its own generators are. The core never sees either.
public protocol InputSource {
    associatedtype Input
    /// The next generated input. Called `count` times per grade.
    mutating func next() -> Input
}

/// A candidate law the reader authored: does it hold for this input against
/// this subject?
///
/// `Subject` is the code under test — the reference implementation during the
/// sanity check, then each mutant in turn. A round-trip law, for example, is
/// `{ input, codec in codec.decode(codec.encode(input)) == input }`; the grader
/// swaps `codec` for the reference and every mutant.
public struct Property<Input, Subject> {
    public let name: String
    public let holds: (Input, Subject) -> Bool

    public init(_ name: String = "property",
                holds: @escaping (Input, Subject) -> Bool) {
        self.name = name
        self.holds = holds
    }
}

/// One buggy variant of a kernel, plus the prose that explains it — the text a
/// reader sees when their property fails to catch it.
public struct Mutant<Subject> {
    /// Stable identifier, e.g. `"rle.drops-singletons"`.
    public let id: String
    /// One line describing the injected bug — the "…and why" in the survivor
    /// feedback. Never leaked until the grade is rendered.
    public let explanation: String
    public let subject: Subject

    public init(id: String, explanation: String, subject: Subject) {
        self.id = id
        self.explanation = explanation
        self.subject = subject
    }
}

/// A kernel's correct reference plus its hidden mutant set — the "answer key",
/// made executable. Grading a property means: it must hold on `reference` and
/// break on every `mutant`.
public struct Corpus<Subject> {
    public let name: String
    public let reference: Subject
    public let mutants: [Mutant<Subject>]

    public init(name: String, reference: Subject, mutants: [Mutant<Subject>]) {
        self.name = name
        self.reference = reference
        self.mutants = mutants
    }
}
