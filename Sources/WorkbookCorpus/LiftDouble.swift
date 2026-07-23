//  LiftDouble.swift — the LIFT shape (candidate for Phase 2; see the book repo's
//  planning/workbook-lift-onramp.md).
//
//  Unlike the other exercises, this one hands the reader a *parameterized test*
//  and asks them to generalize it into a property. The endpoint is still a
//  property graded against a defect corpus, so no new grader machinery is needed
//  — that is precisely the point the planning note argues. What's new is the
//  *framing* (start from examples) and the fact that valid answers span a range
//  of strengths, with the undetected list telling you when you've generalized far
//  enough.

import WorkbookGraderCore

/// Doubles an integer. The reader never sees this signature framed as a law —
/// only the example table below.
public protocol Doubler {
    func double(_ x: Int) -> Int
}

struct CorrectDoubler: Doubler {
    func double(_ x: Int) -> Int { x * 2 }
}

/// The bug: off by a constant. Goes undetected by a "result is even"-style generalization
/// only if... it doesn't — `2x+1` is odd, so parity catches it. It goes undetected by a
/// "result grows with x" generalization.
struct PlusOneDoubler: Doubler {
    func double(_ x: Int) -> Int { x * 2 + 1 }
}

/// The bug: doubles the magnitude, not the value. It **agrees with every example
/// in the table** (all positive) and is even, so it slips past both the examples
/// and a parity generalization — only the exact law, exercised on a *negative*
/// input, detects it. This is the lift's core lesson: your examples were a biased
/// sample, and the property plus a fuller generator is what exposes it.
struct AbsDoubler: Doubler {
    func double(_ x: Int) -> Int { abs(x) * 2 }
}

public enum Lift {
    /// The parameterized test handed to the reader. Deliberately all positive —
    /// the accidental bias the exercise is about.
    public static var doubleExamples: [(input: Int, expected: Int)] {
        [(input: 2, expected: 4), (input: 5, expected: 10), (input: 9, expected: 18)]
    }

    public static var double: Corpus<any Doubler> {
        Corpus(
            name: "Warm-up W4 · the lift (double)",
            reference: CorrectDoubler(),
            defects: [
                Defect(id: "double.plus-one",
                       explanation: "returns 2x+1 (off by a constant)",
                       subject: PlusOneDoubler()),
                Defect(id: "double.abs",
                       explanation: "returns |x|·2; agrees with the positive examples, wrong for negatives",
                       subject: AbsDoubler())
            ]
        )
    }
}
