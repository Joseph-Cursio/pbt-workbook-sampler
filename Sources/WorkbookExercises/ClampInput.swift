//  ClampInput.swift — the input to the W3 clamp exercise.

/// One `clamp` call's arguments, drawn so that `low <= high`.
public struct ClampInput: Sendable, CustomStringConvertible {
    /// The value to clamp.
    public let value: Int
    /// The lower bound.
    public let low: Int
    /// The upper bound, never below `low`.
    public let high: Int

    /// Renders as `(value, low, high)`, the way the grader showed the tuple
    /// this replaced.
    public var description: String { "(\(value), \(low), \(high))" }

    /// The arguments of one `clamp(value, low:, high:)` call.
    public init(value: Int, low: Int, high: Int) {
        self.value = value
        self.low = low
        self.high = high
    }
}
