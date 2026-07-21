//  Grader.swift — the runner. Language-neutral; no engine, no test framework.
//
//  This is deliberately NOT built on `propertyCheck`: that function is bound to
//  Swift Testing (it requires a live test case and reports via `Issue.record`).
//  A grader must *count* kills and *return* a result, so it drives generators
//  itself through the `InputSource` contract.

extension Corpus {
    /// Grade a property against this corpus.
    ///
    /// The same `count` inputs are drawn once and reused across the reference
    /// and every mutant, so the comparison is fair and — given a seeded source
    /// — reproducible. A mutant is *killed* the first time the property fails on
    /// it; the reference is expected to survive all inputs.
    public func grade<Input, Source: InputSource>(
        with property: Property<Input, Subject>,
        drawing source: inout Source,
        count: Int
    ) -> Grade where Source.Input == Input {
        precondition(count > 0, "count must be positive")

        var inputs: [Input] = []
        inputs.reserveCapacity(count)
        for _ in 0..<count { inputs.append(source.next()) }

        // Sanity gate: the property must hold on correct code.
        var referenceHeld = true
        var referenceCounterexample: String?
        for input in inputs where !property.holds(input, reference) {
            referenceHeld = false
            referenceCounterexample = String(describing: input)
            break
        }

        var killed: [KilledMutant] = []
        var survivors: [Survivor] = []
        for mutant in mutants {
            var killer: String?
            for input in inputs where !property.holds(input, mutant.subject) {
                killer = String(describing: input)
                break
            }
            if let killer {
                killed.append(KilledMutant(id: mutant.id,
                                           explanation: mutant.explanation,
                                           counterexample: killer))
            } else {
                survivors.append(Survivor(id: mutant.id, explanation: mutant.explanation))
            }
        }

        return Grade(corpusName: name,
                     propertyName: property.name,
                     referenceHeld: referenceHeld,
                     referenceCounterexample: referenceCounterexample,
                     killed: killed,
                     survivors: survivors,
                     sampleCount: inputs.count)
    }
}
