# Properties, Worked — Free Sampler

A taste of the **auto-graded exercise lab** for property-based testing. You write
a property; a machine tries to break it. Your law runs against a corpus of buggy
kernel variants (*mutants*) and the grade is behavioral:

> *you killed 7/9 mutants — here are the two survivors and why.*

This repo is the **free sampler**: the Warm-up + Set 1 (round-trips). It's the
whole loop, end to end, on the gentlest sets — enough to feel whether an
executable, refutable exercise teaches you something a worked example can't.

## Run it

```
make grade      # build + grade every submission, print feedback
make test       # the answer key: every corpus here is fully killable
```

Open `Sources/WorkbookExercises/Submissions.swift`, write a property, re-run.
Start at `exercises/README.md`.

> `make grade` wraps the run so the executable finds `libTesting.dylib` — the
> engine links Swift Testing, so anything linking it needs that library at
> launch. `swift test` needs no wrapper.

## What's here — and what isn't

- **Here:** the grader (a language-neutral core + a Swift binding), the Warm-up
  and Set 1 kernels, and their mutants. Everything is public. These mutants are
  the *free sample* — read them all you like.
- **Not here:** the full product's private grading corpora. The paid lab adds
  **Sets 2–10** — conformance laws, generators, metamorphic testing, shapeless
  bugs (banker's rounding, dropped separators), value semantics, model-based
  command sequences, idempotency — and a **"prove it can't be proven" capstone**.
  Their mutants stay secret, because a public answer key is just a solutions
  manual next to the exam.

## Engine-only

A submission imports only the engine (`swift-property-based`) plus the exercise's
kernel protocol — no extra kit. Pinned to `1.2.x`. The sampler doubles as proof
the exercise spine needs nothing more.

---

*The full workbook and the book behind it: property-based testing in Swift, from
"I've read about it" to "I can find the invariant."*
