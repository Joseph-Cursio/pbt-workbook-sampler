//  Grade.swift — the behavioral result of running a property against a corpus.
//
//  The grade is not a score against an answer key; it is a *behavioral* report:
//  which mutants your property killed, which survived, and — for the kills — the
//  smallest input that did it. (planning/workbook-positioning-spec.md — "the
//  grade is behavioral: you killed 7/9 mutants, here are the two survivors and
//  why".)

/// A mutant your property caught, with the input that exposed it.
public struct KilledMutant {
    public let id: String
    public let explanation: String
    /// A rendering of the falsifying input — the reproduction the reader reads.
    public let counterexample: String

    public init(id: String, explanation: String, counterexample: String) {
        self.id = id
        self.explanation = explanation
        self.counterexample = counterexample
    }
}

/// A mutant your property missed — the teaching moment.
public struct Survivor {
    public let id: String
    public let explanation: String

    public init(id: String, explanation: String) {
        self.id = id
        self.explanation = explanation
    }
}

public struct Grade {
    public let corpusName: String
    public let propertyName: String

    /// Did the property hold on the *correct* implementation? A `false` here
    /// means the property is over-strong (it rejects correct code) — a
    /// different failure from a weak one, and reported first.
    public let referenceHeld: Bool
    /// If the reference failed, the input that broke it.
    public let referenceCounterexample: String?

    public let killed: [KilledMutant]
    public let survivors: [Survivor]
    public let sampleCount: Int

    public init(corpusName: String,
                propertyName: String,
                referenceHeld: Bool,
                referenceCounterexample: String?,
                killed: [KilledMutant],
                survivors: [Survivor],
                sampleCount: Int) {
        self.corpusName = corpusName
        self.propertyName = propertyName
        self.referenceHeld = referenceHeld
        self.referenceCounterexample = referenceCounterexample
        self.killed = killed
        self.survivors = survivors
        self.sampleCount = sampleCount
    }

    public var mutantsTotal: Int { killed.count + survivors.count }

    /// Mutant-kill ratio in `0...1`. An empty corpus scores 1 (nothing to kill)
    /// — the honest answer for a negative Capstone rep, not a bug.
    public var score: Double {
        mutantsTotal == 0 ? 1 : Double(killed.count) / Double(mutantsTotal)
    }

    /// The property passes only if it holds on the reference *and* kills every
    /// mutant. An over-strong property (fails the reference) never passes, no
    /// matter how many mutants it "kills".
    public var passed: Bool {
        referenceHeld && survivors.isEmpty && mutantsTotal > 0
    }

    /// The reader-facing feedback string — the pedagogical payload.
    public func render() -> String {
        var out = ""
        out += "\(corpusName) — property “\(propertyName)”\n"

        guard referenceHeld else {
            out += "  ✗ Your property does not hold on the correct implementation.\n"
            if let referenceCounterexample {
                out += "    It rejects a valid input: \(referenceCounterexample)\n"
            }
            out += "    A property that fails on correct code is over-strong — "
            out += "loosen it before worrying about mutants.\n"
            return out
        }

        out += "  killed \(killed.count)/\(mutantsTotal) mutants"
        out += " over \(sampleCount) inputs.\n"

        if !killed.isEmpty {
            out += "  ✓ caught:\n"
            for kill in killed {
                out += "      \(kill.id) — \(kill.explanation)\n"
                out += "        first broken by: \(kill.counterexample)\n"
            }
        }

        if survivors.isEmpty {
            out += "  ✓ no survivors — every mutant killed.\n"
        } else {
            out += "  ✗ survivors (your property missed these):\n"
            for survivor in survivors {
                out += "      \(survivor.id) — \(survivor.explanation)\n"
            }
            out += "    A survivor is a bug your property would ship. "
            out += "Strengthen the law so it distinguishes this case.\n"
        }
        return out
    }
}
