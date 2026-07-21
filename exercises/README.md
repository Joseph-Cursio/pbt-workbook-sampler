# How to work an exercise

Every exercise hands you a **kernel** — a small piece of code with a correct
version and a set of hidden buggy variants (*mutants*). Your job is to write a
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
[S1.1] Run-length round-trip  — WEAK — 2/3 killed
    ✗ true but weak — killed 2 of 3; 1 broken implementation still passes.
    caught:
        rle.off-by-one — decompressor emits count-1 copies per run
          first broken by: [0, 0, 3, 0, 3, 3, 2, 0]
    survivors (bugs your property would still ship):
        rle.drops-singletons — compressor drops runs of length 1
```

The grade leads with **strength** — where your property sits on the ratchet:

- **caught** — mutants your property killed, each with the *smallest input that
  broke it*. That input is your reproduction; paste it into a scratch test.
- **survivors** — bugs your property *would still ship*. A survivor means your law
  is too weak to tell the correct kernel from that mutant. Strengthen it.
- **not refutable** — a law that can never fail (`return true`) kills nothing.
- **true but weak** — it holds but kills only some mutants; keep strengthening.
- **characterizing** — it holds and kills the whole corpus. That's a pass.
- **over-strong** — it fails on the *correct* kernel. You've written a law that
  rejects valid code; loosen it first.

A property **passes** only when it holds on the correct kernel **and** kills
every mutant. Strengthening from "true but weak" to "characterizing" — until no
mutant survives — is the whole exercise.

## What to re-read

Each prompt names the book chapter its shape comes from. You don't need the book
to *attempt* an exercise — you need it to *understand a surprising grade*. When a
mutant survives and you can't see why, that chapter is where the answer is.
