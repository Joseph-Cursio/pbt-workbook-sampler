# How to work an exercise

Every exercise hands you a **kernel** — a small piece of code with a correct
version and a set of hidden buggy variants (*mutants*). Your job is to write a
**property**: a law that should hold for the correct kernel and *fail* for the
buggy ones. Then a machine grades it by trying to break it.

## The loop

1. Open `Sources/WorkbookExercises/Submissions.swift`.
2. Find the property for this exercise. Replace the placeholder with your law.
3. Run the grader:

   ```
   make grade        # or: swift test
   ```

4. Read the grade.

## Reading a grade

```
[S1.1] Run-length round-trip  — 2/3 killed
    killed 2/3 mutants over 200 inputs.
    ✓ caught:
        rle.off-by-one — decompressor emits count-1 copies per run
          first broken by: [0, 0, 3, 0, 3, 3, 2, 0]
    ✗ survivors (your property missed these):
        rle.drops-singletons — compressor drops runs of length 1
```

- **killed** — mutants your property caught, each with the *smallest input that
  broke it*. That input is your reproduction; paste it into a scratch test.
- **survivors** — bugs your property *would have shipped*. A survivor means your
  law is too weak to tell the correct kernel from that mutant. Strengthen it.
- **over-strong** — if the grade says your property fails on the *correct*
  kernel, you've written a law that rejects valid code. Loosen it first.

A property **passes** only when it holds on the correct kernel **and** kills
every mutant. A law that can never fail (`return true`) kills nothing — that's
the zero you get for pasting something non-refutable.

## What to re-read

Each prompt names the book chapter its shape comes from. You don't need the book
to *attempt* an exercise — you need it to *understand a surprising grade*. When a
mutant survives and you can't see why, that chapter is where the answer is.
