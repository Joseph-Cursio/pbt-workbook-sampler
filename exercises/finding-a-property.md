# Finding a property: the pre/post/invariant checklist

You're staring at a function and the box in `Submissions.swift` is blank. What
law do you even write? This is the hard part of property-based testing — not
running the check, but *finding* it. Here's a mechanical scaffold that gets you
from a bare function to a candidate property. Use it until you don't need it.

Ask three questions, in order. Each answer maps to a specific piece of a property.

### 1. Precondition — what must be true of the input?

What does the caller have to guarantee for the function to even apply? A square
root wants a non-negative number; a "pop" wants a non-empty stack. **That's your
generator's domain** (book Ch4). In these exercises the generator is *provided*,
so the answer is usually "any input" — but naming the precondition tells you what
you must *not* generate, and a surprising number of bugs live exactly at the edge
of the domain (the empty list, the value at overflow — the CSV set has both).

### 2. Postcondition — what must be true of the output?

And, crucially: *that you can check **without redoing the computation.*** That
last clause is the whole game. If the only way to know the answer is to
re-implement the function, you have no oracle. So look for something weaker but
still true:

- `abs(x)` — the result is `>= 0`, and equals `x` or `-x`. (Warm-up W2.)
- a function with an **inverse** — `decompress(compress(x)) == x`. The
  postcondition spans two functions, and neither states it alone. (Set 1.)

**That's your property.** The inverse trick (round-trips) is the highest-yield
one there is: if a function has an inverse, you get a strong property for one line
of thought — which is exactly what all of Set 1 is about.

### 3. Invariant — what stays true *before and after*, or *across two runs*?

Some laws don't need an oracle at all — they relate the function to *itself*. You
already have one in the Warm-up:

- **Involution** — applying twice returns the original:
  `reverse(reverse(x)) == x`. (Warm-up W1.)

The full lab's algebraic set drills the siblings — **idempotence**
(`f(f(x)) == f(x)`) and **commutativity** (`combine(a, b) == combine(b, a)`) —
and the striking thing about that whole row is that you can write the law
*without ever knowing what the function computes*. The invariant needs no
reference answer. **That's your metamorphic or state property.**

## The trap: don't over-specify

A postcondition that pins the *exact* output — "the decoder returns the input,
byte for byte, in this format" — often isn't a property, it's a
re-implementation. It fails valid refactors while catching no real bug. Write
only what **must** be true, no more. (The grade will tell you if you've gone too
far: a law that fails the *correct* kernel comes back `over-strong`.)

## A worked pass

Take Set 1's run-length codec. Precondition: `compress` accepts any `[Int]` —
nothing to exclude. Postcondition: what's true of `compress`'s output that I can
check cheaply? Hard to say in isolation… but `compress` has an **inverse**,
`decompress`. So question 3 answers it: `decompress(compress(x)) == x`. The
checklist walked you straight to the round-trip.

Now the Warm-up reverser. Precondition: any list. Postcondition: hard to state
without rebuilding the reversed list. Invariant: reversing is its own undo →
`reverse(reverse(x)) == x`. Property found, no oracle needed.

## The scaffold comes off

This checklist is Chapter 2's method compressed into three prompts, and it's
**training wheels on purpose**. The round-trip set almost fills it in for you.
The hard sets — in the full lab — are where you ride without it: for a **shapeless
bug** (a currency formatter, a rounding mode) there's no inverse and no algebra,
and the only handle is the docstring, which you read *as a postcondition*; at the
**Capstone**, the honest answer is sometimes that all three questions come up
empty, and saying so is the skill. When the checklist runs dry, that emptiness is
itself the lesson.

*This is the free sampler — Warm-up + Set 1. The full lab adds Sets 2–10 (the
algebraic, metamorphic, and model-based sets that fill in the invariant row) and
a "prove it can't be proven" capstone.*
