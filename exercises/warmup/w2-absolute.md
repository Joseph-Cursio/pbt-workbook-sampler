# Warm-up W2 · A property with two clauses

*Book: Ch5. Still handed to you — read the counterexample.*

```swift
protocol Absoluter { func absolute(_ value: Int) -> Int }
```

The handed law says two things at once:

```swift
let result = absoluter.absolute(input)
result >= 0 && (result == input || result == -input)
```

Absolute value is non-negative **and** equals either the input or its negation.
A property can be a conjunction — each clause narrows what "correct" means. The
hidden bug violates one of them. Run it; read which input exposes it.

**You'll know it worked when:** `detected 1/1`, broken by a negative input.
