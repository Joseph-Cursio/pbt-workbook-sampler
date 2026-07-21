//  main.swift — the reader-facing loop: grade every submission, print feedback.
//
//  Run:  make grade
//  Write a property in Submissions.swift, run this, read the mutant-kill grade
//  and survivor list. This is the FREE sampler — Warm-up + Set 1.

import WorkbookExercises
import WorkbookGraderSwift

let exercises = Workbook.allExercises

print("""
Properties, Worked — FREE SAMPLER — grading \(exercises.count) exercises.
Edit Sources/WorkbookExercises/Submissions.swift, then re-run.
The full lab adds Sets 2–10 and a "prove it can't be proven" capstone.
────────────────────────────────────────────────────────────
""")

var passed = 0
for exercise in exercises {
    let grade = exercise.grade()
    let mark = grade.passed ? "PASS" : (grade.readerHint(authored: exercise.readerAuthored))
    print("[\(exercise.id)] \(exercise.title)  (book \(exercise.chapterRef))  — \(mark)")
    print(indent(grade.render()))
    if grade.passed { passed += 1 }
}

print("────────────────────────────────────────────────────────────")
print("\(passed)/\(exercises.count) exercises passing.")
if passed < exercises.count {
    print("Prompts live under exercises/. Strengthen a property and re-run.")
}

func indent(_ text: String) -> String {
    text.split(separator: "\n", omittingEmptySubsequences: false)
        .map { "    \($0)" }
        .joined(separator: "\n")
}

extension Grade {
    /// A short status tag for the header line.
    func readerHint(authored: Bool) -> String {
        if !referenceHeld { return "OVER-STRONG" }
        if mutantsTotal == 0 { return "no mutants" }
        if authored, killed.isEmpty { return "not refutable — \(survivors.count) survivors" }
        return "\(killed.count)/\(mutantsTotal) killed"
    }
}
