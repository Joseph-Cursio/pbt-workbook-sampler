# How to work an exercise

Every exercise hands you a **kernel** — a small piece of code with a correct
version and a set of hidden buggy variants (*defects*). Your job is to write a
**property**: a law that should hold for the correct kernel and *fail* for the
buggy ones. Then a machine grades it by trying to break it.

## The loop

1. Open `Sources/WorkbookExercises/Submissions.swift`.
2. Find the property for this exercise. Replace the placeholder with your law.
   *Blank on what law to write? See [finding-a-property.md](finding-a-property.md)
   — the pre/post/invariant checklist for getting from a bare function to a
   candidate property.*
3. Run the grader:

   ```
   make grade        # or: swift test
   ```

4. Read the grade.

## Reading a grade

```
[S1.1] Run-length round-trip  — WEAK — 2/3 detected
    ✗ true but weak — detected 2 of 3; 1 defect undetected.
    detected:
        rle.off-by-one — decompressor emits count-1 copies per run
          first caught on: [0, 0, 3, 0, 3, 3, 2, 0]
    undetected (defects your property would still ship):
        rle.drops-singletons — compressor drops runs of length 1
```

The grade leads with **strength** — where your property sits on the ratchet:

- **detected** — defects your property caught, each with the *smallest input
  that broke it*. That input is your reproduction; paste it into a scratch test.
- **undetected** — defects your property *would still ship*. An undetected defect
  means your law is too weak to tell the correct kernel from that defect.
  Strengthen it.
- **not refutable** — a law that can never fail (`return true`) detects nothing.
- **true but weak** — it holds but detects only some defects; keep strengthening.
- **characterizing** — it holds and detects the whole corpus. That's a pass.
- **over-strong** — it fails on the *correct* kernel. You've written a law that
  rejects valid code; loosen it first.

A property **passes** only when it holds on the correct kernel **and** detects
every defect. Strengthening from "true but weak" to "characterizing" — until no
defect goes undetected — is the whole exercise.

## What to re-read

Each prompt names the book chapter its shape comes from. You don't need the book
to *attempt* an exercise — you need it to *understand a surprising grade*. When a
defect goes undetected and you can't see why, that chapter is where the answer is.
