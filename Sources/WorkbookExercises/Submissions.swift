//  Submissions.swift — THIS IS THE FILE YOU EDIT.
//
//  The free sampler: Warm-up (handed to you) + Set 1 (you write the property).
//  Run `make grade`, read the defect-detection grade, strengthen, re-run. When you've
//  detected every defect in Set 1, you've done the thing the full workbook drills
//  across eleven more sets — round-trips, algebraic laws, metamorphic tests,
//  model-based sequences, and a "prove it can't be proven" capstone.

import WorkbookGraderSwift
import WorkbookCorpus

public enum Submissions {

    // MARK: Warm-up — handed to you, correct. Run and read the counterexample.

    public static var reverseRoundTrip: Property<[Int], any ListReverser> {
        Property("reverse(reverse(x)) == x") { input, reverser in
            reverser.reverse(reverser.reverse(input)) == input
        }
    }

    public static var absoluteValue: Property<Int, any Absoluter> {
        Property("abs(x) >= 0 and equals x or -x") { input, absoluter in
            let result = absoluter.absolute(input)
            return result >= 0 && (result == input || result == -input)
        }
    }

    public static var clampInRange: Property<(Int, Int, Int), any Clamper> {
        Property("low <= clamp(v, low, high) <= high") { input, clamper in
            let (value, low, high) = input
            let result = clamper.clamp(value, low: low, high: high)
            return low <= result && result <= high
        }
    }

    // MARK: Warm-up W4 · The lift — YOU strengthen this one.
    //
    // You're handed a test table (see the prompt): (2,4), (5,10), (9,18).
    // The starter below is a REAL but WEAK generalization — it holds on those
    // examples and catches one of the two hidden bugs. Your job is to strengthen
    // it until that defect is detected too. This is the examples→properties skill.

    public static var doubleFromExamples: Property<Int, any Doubler> {
        Property("result is even") { input, subject in
            // A genuine pattern in the table (4, 10, 18 are all even) — but too
            // weak. It leaves a defect undetected. What is the examples' *exact* claim?
            subject.double(input) % 2 == 0
        }
    }

    // MARK: Set 1 · Round-trips — YOU write these.

    public static var runLengthRoundTrip: Property<[Int], any RunLengthCodec> {
        Property("decompress(compress(x)) == x") { input, codec in
            // TODO: the round-trip law is `decompress(compress(x)) == x`.
            _ = (input, codec)
            return true
        }
    }

    public static var csvRoundTrip: Property<[Int], any IntListCSVCodec> {
        Property("decode(encode(x)) == x") { input, codec in
            // TODO: the round-trip law is `decode(encode(x)) == x`.
            _ = (input, codec)
            return true
        }
    }
}
