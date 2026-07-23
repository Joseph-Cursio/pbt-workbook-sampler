//  main.swift — the reader-facing loop: grade every submission, print feedback.
//
//  Run:  make grade
//  Write a property in Submissions.swift, run this, read the defect-detection grade
//  and undetected list. This is the FREE sampler — Warm-up + Set 1.

import WorkbookExercises
import WorkbookGraderSwift

let exercises = Workbook.allExercises

/// Exercise count of the full lab (Warm-up + Sets 1–10 + Capstone), which lives
/// in the private `pbt-workbook` repo. The single source of this number in the
/// sampler — the header and footer below both derive from it, so adding a set
/// there means updating one constant here.
let fullLabExerciseCount = 58

print("""
Properties, Worked — FREE SAMPLER — grading \(exercises.count) of the full lab's \
\(fullLabExerciseCount) exercises.
Edit Sources/WorkbookExercises/Submissions.swift, then re-run.
────────────────────────────────────────────────────────────
""")

var passed = 0
for exercise in exercises {
    let grade = exercise.grade()
    let mark = grade.passed ? "PASS" : grade.readerHint()
    print("[\(exercise.id)] \(exercise.title)  (book \(exercise.chapterRef))  — \(mark)")
    print(indent(grade.render()))
    if grade.passed { passed += 1 }
}

print("────────────────────────────────────────────────────────────")
print("\(passed)/\(exercises.count) exercises passing.")
if passed < exercises.count {
    print("Prompts live under exercises/. Strengthen a property and re-run.")
}

// The upsell lands here, at the moment the reader has just finished, rather
// than in the header where it would be a claim about work not yet done.
print("""

This sampler is \(exercises.count) of the full lab's \(fullLabExerciseCount) exercises. \
The other \(fullLabExerciseCount - exercises.count) span
Sets 2–10 — conformance laws, generators you write yourself, metamorphic
testing, shapeless bugs, value semantics, model-based command sequences,
idempotency — and a "prove it can't be proven" capstone.
""")

func indent(_ text: String) -> String {
    text.split(separator: "\n", omittingEmptySubsequences: false)
        .map { "    \($0)" }
        .joined(separator: "\n")
}

extension Grade {
    /// A short status tag for the header line — the strength verdict in a word.
    func readerHint() -> String {
        switch strength {
        case .overStrong:     return "OVER-STRONG"
        case .noDefects:      return "no defects"
        case .nonRefutable:   return "not refutable — \(undetected.count) undetected defect\(undetected.count == 1 ? "" : "s")"
        case .weak:           return "WEAK — \(detected.count)/\(defectsTotal) detected"
        case .characterizing: return "\(detected.count)/\(defectsTotal) detected"
        }
    }
}
