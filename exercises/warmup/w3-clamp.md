# Warm-up W3 · A property over a generated range

*Book: Ch5. Last handed rep.*

This warm-up also has a property given to you, and a buggy implementation. Notice a property can constrain a protocol's contract, not just a single function — you'll do that directly in the conformance-law set (Set 2).

```swift
protocol Clamper { func clamp(_ value: Int, low: Int, high: Int) -> Int }
```

The property is given to you as:

```swift
let result = clamper.clamp(value, low: low, high: high)
low <= result && result <= high
```

`clamp` must land inside `low...high`. The provided generator only ever gives you
`low <= high`, so the law is always well-posed — a reminder that the *generator*
decides which inputs a property is even asked about. The hidden bug enforces one
bound but not the other.

**You'll know it worked when:** `detected 1/1`, broken by a `(value, low, high)`
where the value is above `high`.

After this, the training wheels come off: in Set 1 **you** write the property.
