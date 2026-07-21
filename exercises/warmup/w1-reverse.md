# Warm-up W1 · Make one property fail

*Book: Ch5 (shrinking). No new thinking — this rep teaches the format.*

You're **handed** a correct property and a broken function. Just run it.

```swift
protocol ListReverser { func reverse(_ list: [Int]) -> [Int] }
```

The law is already written for you in `Submissions.swift`:

```swift
// reverse(reverse(x)) == x
reverser.reverse(reverser.reverse(input)) == input
```

Reversing a list twice must return the original. The hidden implementation has a
bug. Run `make grade` and read the **counterexample** — the shrunk input that
proves the bug. Notice how small it is: the grader shrinks a failing case down to
the least input that still fails, so you debug the essence, not the noise.

**You'll know it worked when:** the grade shows `killed 1/1`, and a short list
under "first broken by".
