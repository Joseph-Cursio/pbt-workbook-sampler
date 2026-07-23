# Properties, Worked — Free Sampler

A taste of the **auto-graded exercise lab** for property-based testing. You write
a property; a machine tries to break it. Your law runs against a corpus of buggy
kernel variants (*defects*) and the grade is behavioral:

> *you detected 7/9 defects — here are the two that went undetected and why.*

This repo is the **free sampler**: **5 of the full lab's 58 exercises** — the
Warm-up plus the first two round-trips of Set 1. It's the whole loop, end to end,
on the gentlest sets — enough to feel whether an executable, refutable exercise
teaches you something a worked example can't.

## Run it

```
make grade      # build + grade every submission, print feedback
make test       # the answer key: every corpus here is fully detectable
```

Open `Sources/WorkbookExercises/Submissions.swift`, write a property, re-run.

- **New to property-based testing?** Start at
  [`exercises/on-ramp.md`](exercises/on-ramp.md) — one page, the four words you
  need. No prior knowledge assumed.
- **Already know PBT?** Go straight to
  [`exercises/README.md`](exercises/README.md) for the loop and how to read a
  grade.

> `make grade` wraps the run so the executable finds Swift Testing — the engine
> links it, so anything linking the engine needs it at launch. Toolchains ship it
> two ways (a framework or a dylib) and the wrapper covers both, so use `make
> grade` rather than running the binary directly. `swift test` needs no wrapper.

## What's here — and what isn't

- **Here:** the grader (a language-neutral core + a Swift binding), the Warm-up
  and Set 1 kernels, and their defects. Everything is public. These defects are
  the *free sample* — read them all you like.
- **Not here:** the full product's private grading corpora. The paid lab adds the
  other **53 exercises** across **Sets 2–10** — conformance laws, generators,
  metamorphic testing, shapeless bugs (banker's rounding, dropped separators),
  value semantics, model-based command sequences, idempotency — and a **"prove it
  can't be proven" capstone**. Their defects stay secret, because a public answer
  key is just a solutions manual next to the exam.

## Engine-only

A submission imports only the engine (`swift-property-based`) plus the exercise's
kernel protocol — no extra kit. Pinned to `1.2.x`. The sampler doubles as proof
the exercise spine needs nothing more.

## License

MIT — see [`LICENSE`](LICENSE). Clone it, edit it, keep your answers, reuse the
kernels in your own tests. The license covers this sampler; the paid lab's
private corpora are not distributed here.

---

*The full workbook and the book behind it: property-based testing in Swift, from
"I've read about it" to "I can find the invariant."*
