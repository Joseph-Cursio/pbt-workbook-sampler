# Set 1 · S1.1 — Run-length round-trip

*Book: Ch8 (Codable round-trip), Ch17 (inverse shapes).*

The round-trip is the highest-yield property shape there is: if a function has an
inverse, `inverse(f(x)) == x` catches an enormous class of bugs for one line of
thought.

```swift
protocol RunLengthCodec {
    func compress(_ input: [Int]) -> [Run]      // [2,2,2,5] -> [(2,3),(5,1)]
    func decompress(_ runs: [Run]) -> [Int]     // and back
}
```

**Write the property** in `Submissions.swift` (`runLengthRoundTrip`). The
placeholder returns `true` and kills nothing — replace it with the law that says
compressing then decompressing gets you back where you started.

Three mutants hide in the corpus: one drops single-element runs, one is off by
one on the counts, one loses the *order* of interleaved values. A real round-trip
law kills all three. If one survives, ask what your law fails to observe about
the result — its length? its element values? its **order**?

**Target:** `killed 3/3`, no survivors.
