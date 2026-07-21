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

    /// Where a property sits on the strength ratchet — the axis the workbook
    /// grades *beyond* pass/fail (planning/workbook-contracts-and-strength.md).
    /// A property can be *true* yet weak: it holds on correct code but lets
    /// broken implementations pass. Strength is how much of the corpus it
    /// characterizes.
    public enum Strength {
        /// Fails on the correct implementation — rejects valid code.
        case overStrong
        /// Holds, but the corpus has nothing to distinguish (a negative/honest
        /// rep — the trap is "killing" a mutant that isn't there).
        case noMutants
        /// Holds and never fails — kills nothing. Not yet refutable.
        case nonRefutable
        /// Holds and kills some, but broken implementations still pass.
        case weak
        /// Holds and kills every mutant — a characterizing property.
        case characterizing
    }

    public var strength: Strength {
        if !referenceHeld { return .overStrong }
        if mutantsTotal == 0 { return .noMutants }
        if killed.isEmpty { return .nonRefutable }
        if survivors.isEmpty { return .characterizing }
        return .weak
    }

    /// The ratchet as one sentence — "true but weak, N still pass" and kin.
    public var strengthHeadline: String {
        switch strength {
        case .overStrong:
            return "over-strong — it rejects correct code"
        case .noMutants:
            return "no mutants here — nothing to distinguish (an honest-silence rep)"
        case .nonRefutable:
            return "not yet refutable — it holds, but kills nothing"
        case .weak:
            let stillPass = survivors.count == 1 ? "1 broken implementation still passes"
                                                 : "\(survivors.count) broken implementations still pass"
            return "true but weak — killed \(killed.count) of \(mutantsTotal); \(stillPass)"
        case .characterizing:
            return "characterizing — killed all \(mutantsTotal); nothing broken survives"
        }
    }

    /// The reader-facing feedback string — the pedagogical payload. Leads with
    /// the strength verdict so the reader grades the *ratchet*, not a binary.
    public func render() -> String {
        var out = ""
        out += "\(corpusName) — property “\(propertyName)”\n"

        guard referenceHeld else {
            out += "  ✗ \(strengthHeadline).\n"
            if let referenceCounterexample {
                out += "    It rejects a valid input: \(referenceCounterexample)\n"
            }
            out += "    Loosen it before worrying about mutants — a property that "
            out += "fails on correct code can't grade anything.\n"
            return out
        }

        let settled = strength == .characterizing || strength == .noMutants
        out += "  \(settled ? "✓" : "✗") \(strengthHeadline)"
        out += " (over \(sampleCount) inputs).\n"

        if !killed.isEmpty {
            out += "  caught:\n"
            for kill in killed {
                out += "      \(kill.id) — \(kill.explanation)\n"
                out += "        first broken by: \(kill.counterexample)\n"
            }
        }

        if !survivors.isEmpty {
            out += "  survivors (bugs your property would still ship):\n"
            for survivor in survivors {
                out += "      \(survivor.id) — \(survivor.explanation)\n"
            }
            out += "    Strengthen the law until none survive — that's the ratchet "
            out += "from a property that's merely true to one that characterizes.\n"
        }
        return out
    }
}
