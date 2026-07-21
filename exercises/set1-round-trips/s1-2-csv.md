# Set 1 · S1.2 — CSV round-trip

*Book: Ch8, Ch17.*

```swift
protocol IntListCSVCodec {
    func encode(_ input: [Int]) -> String       // [1,-2,3] -> "1,-2,3"
    func decode(_ text: String) -> [Int]
}
```

Same shape — `decode(encode(x)) == x` — but the mutants here live in the *edges*
of the domain, not the middle. Write the law (`csvRoundTrip`) and let the
generator hunt them:

- one mutant handles the **empty list** wrong,
- one picks a separator that **collides** with a character that appears in the
  data itself.

The provided generator deliberately includes empty lists and negative numbers.
This is the lesson of Ch4 arriving early: a property is only as good as the
inputs it's offered, and the interesting bugs sit at the boundaries.

**Target:** `killed 2/2`, no survivors.
