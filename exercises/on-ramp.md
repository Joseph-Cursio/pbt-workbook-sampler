# New to Property-Based Testing (PBT)? Read this first.

If you've written unit tests before, you know the process: you give an input and assert the expected output. For example:

```swift
#expect(reverse([1, 2, 3]) == [3, 2, 1])   // one input, one answer
```

in PBT parlance, this is what's known as an **example test** because it tests one specific example. Example tests work, but they only ever check the specific cases that you've thought of. Property-based testing makes one important change in how you test:

> from *"Does **this** input give the expected output?"*
> to *"What must **always** be true?"*

The end result is a **property test**. You state the law once, and a machine checks it against hundreds (or even thousands) of generated inputs — including the ugly ones you'd never have typed.

## Four terms

That's the whole vocabulary you need to start:

- **Generator** (`Gen`) — makes random inputs of a type. *In this sampler, the
  generator is handed to you; you only write the law.*
- **Property** — the law that should hold for **every** input. This is the Swift code that you write. Example: *reversing a list twice returns the original —*
  `reverse(reverse(x)) == x`.
- **Shrinking** — when a property fails, the tool doesn't just report the messy
  input that broke it; it **shrinks** that input to the smallest example that still fails, so you debug the essence, not the noise.
- **Defect / detect** — each exercise hides several *broken* versions of the
  function. Your property **detects** a defect by failing on it (catching its bug).

## The process

The hardest part of testing properties is the "properties" part: how to define a property that returns true when the function is implemented properly, but false when there's a bug. Your grade is how many defects your property detected — plus, for the ones you missed, feedback as to why. For example, your property could have been: `x == x` but that would accept all buggy versions of `reverse`.

After you define your property, the sampler will test it against a correct implementation of the function, and then mutate the function in various ways, to see if your property can identify the defect.

## Sixty seconds of it

This warm-up does all the work for you. But with a twist. It only has one buggy version of the function. You're given this property and a broken `reverse` function:

```swift
reverse(reverse(input)) == input
```

Run `make grade`. The property fails, and the grade shows the **shrunk
counterexample** — the tiny input that exposes the bug. You didn't pick that
input; the generator found it and the shrinker minimized it. You didn't even need to read through the implementation to guess the nature of the bug. That's the loop: *state a law, let the machine hunt for the input that breaks it.*

## A note on peeking

This sampler is public, so its defects are sitting in `Sources/WorkbookCorpus/`
in plain sight — read them if you want. But notice what reading them does and
doesn't buy you: knowing that the compressor *drops runs of length 1* still
leaves you to write a law that **fails** when it does. That gap — from naming a
bug to stating the law that catches it — is the entire skill, and it's the one
thing you can't read your way past. (In the full lab the defects are hidden, so
the gap is all there is.)

## Where to go next

- **How to run the loop and read a grade:** [`README.md`](README.md).
- **How to *find* a property when the box is blank:**
  [`finding-a-property.md`](finding-a-property.md) — the pre/post/invariant
  checklist.

That's enough to attempt every exercise here: the three warm-ups and the two
round-trip exercises of Set 1. The full *why* behind any surprising grade is what
the book is for — reach for it when a defect goes undetected and you can't see
why, not before.

*This is the free sampler. The full lab adds Sets 2–10 — conformance laws,
generators you write yourself, metamorphic testing, shapeless bugs, value
semantics, model-based command sequences, idempotency — and a "prove it can't be
proven" capstone.*
