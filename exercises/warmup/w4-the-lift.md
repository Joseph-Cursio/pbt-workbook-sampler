# Warm-up W4 · The lift

*Book: Ch2 (finding properties), Ch18 (lifting tests to properties). This is the
first rep where you write a real property — and the first that starts from where
you already are: an ordinary test.*

You didn't arrive at property-based testing from nowhere. You arrived from
**example tests**. So start there. Here's a parameterized test someone already
wrote for a `double` function:

```swift
@Test(arguments: [(2, 4), (5, 10), (9, 18)])
func doubles(_ input: Int, _ expected: Int) {
    #expect(subject.double(input) == expected)
}
```

Three passing examples. Your job is to find the **property** hiding inside them
— the thing that must *always* be true, not just true for these three rows.

You don't start from a blank line, though. `Submissions.swift` hands you a first,
deliberately weak guess to strengthen:

```swift
Property("result is even") { input, subject in
    subject.double(input) % 2 == 0
}
```

It's a *real* pattern in the examples (4, 10, 18 are all even) — but far too weak.
**Strengthen this same property in place: edit its law, don't add a second one.**
Run it, then work the questions below.

Ask, in order:

1. **What do these rows have in common?** The starter above bet on parity (4, 10,
   18 are all even) — but is that *the* rule, or just true of these three rows?
2. **What's essential vs accidental?** Every example input is *positive*. Is that
   the function's rule, or just how the test author happened to pick rows?
3. **Strengthen until bugs fall out.** Run `make grade`. The starter ("result is
   even") catches one hidden bug and **leaves one undetected**. Read it.
   What exact relationship between `input` and result would detect it too?
4. **What generator do you need?** The undetected defect only shows itself on inputs the
   examples never covered. The provided generator includes them — your property
   just has to be strong enough to notice.

The lesson in one line: **a parameterized test is an incomplete description of a
property.** Your examples were a biased sample (all positive); one of the two
bugs agrees with every row you were shown and is *even* — so neither the examples
nor a parity check catches it. The exact law does.

**Target:** `detected 2/2`. When you get there, you've done the move this whole
workbook trains — turned "it worked on my examples" into "it must always hold."
