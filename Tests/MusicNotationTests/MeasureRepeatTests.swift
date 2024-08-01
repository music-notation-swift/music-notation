//
//	MeasureRepeatTests.swift
//	MusicNotationCore
//
//	Created by Kyle Sherman on 2016-03-09.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class MeasureRepeatTests {
    static let timeSignature = TimeSignature(numerator: 4, denominator: 4, tempo: 120)
    static let key = Key(noteLetter: .c)
    static let note1 = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
    static let note2 = Note(.quarter, pitch: SpelledPitch(.d, .octave1))
    let measure1 = Measure(timeSignature: timeSignature, key: key, notes: [[note1, note1]])
    let measure2 = Measure(timeSignature: timeSignature, key: key, notes: [[note2, note2]])

    // MARK: - init(measures:repeateCount:)

    // MARK: Failures

    @Test func initInvalidRepeatCount() async throws {
        #expect(throws: MeasureRepeatError.invalidRepeatCount) {
            _ = try MeasureRepeat(measures: [measure1], repeatCount: -2)
        }
    }

    @Test func initNoMeasures() async throws {
        #expect(throws: MeasureRepeatError.noMeasures) {
            _ = try MeasureRepeat(measures: [])
        }
    }

    // MARK: Successes

    @Test func initNotSpecifiedRepeatCount() async throws {
        let measureRepeat = try MeasureRepeat(measures: [measure1])
        #expect(measureRepeat.repeatCount == 1)
    }

    @Test func initSingleMeasure() async throws {
        _ = try MeasureRepeat(measures: [measure2], repeatCount: 3)
    }

    @Test func initMultipleMeasures() async throws {
        _ = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 4)
    }

    // MARK: - expand()

    @Test func expandSingleMeasureRepeatedOnce() async throws {
        let measureRepeat = try MeasureRepeat(measures: [measure1], repeatCount: 1)
        let expected = [measure1, RepeatedMeasure(immutableMeasure: measure1)] as [ImmutableMeasure]
        let actual = measureRepeat.expand()
        guard actual.count == expected.count else {
            Issue.record("actual.count(\(actual.count)) == expected.count(\(expected.count))")
            return
        }
        #expect(compareImmutableMeasureArrays(actual: actual, expected: expected))
        #expect(String(describing: measureRepeat) == "[ |4/4: [1/8c1, 1/8c1]| ] × 2")
    }

    @Test func expandSingleMeasureRepeatedMany() async throws {
        let measureRepeat = try MeasureRepeat(measures: [measure1], repeatCount: 3)
        let repeatedMeasure = RepeatedMeasure(immutableMeasure: measure1)
        let expected = [measure1, repeatedMeasure, repeatedMeasure, repeatedMeasure] as [ImmutableMeasure]
        let actual = measureRepeat.expand()
        guard actual.count == expected.count else {
            Issue.record("actual.count(\(actual.count)) == expected.count(\(expected.count))")
            return
        }
        #expect(compareImmutableMeasureArrays(actual: actual, expected: expected))
        #expect(String(describing: measureRepeat) == "[ |4/4: [1/8c1, 1/8c1]| ] × 4")
    }

    @Test func expandManyMeasuresRepeatedOnce() async throws {
        let measureRepeat = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 1)
        let repeatedMeasure1 = RepeatedMeasure(immutableMeasure: measure1)
        let repeatedMeasure2 = RepeatedMeasure(immutableMeasure: measure2)
        let expected = [measure1, measure2, repeatedMeasure1, repeatedMeasure2] as [ImmutableMeasure]
        let actual = measureRepeat.expand()
        guard actual.count == expected.count else {
            Issue.record("actual.count(\(actual.count)) == expected.count(\(expected.count))")
            return
        }
        #expect(compareImmutableMeasureArrays(actual: actual, expected: expected))
        #expect(String(describing: measureRepeat) == "[ |4/4: [1/8c1, 1/8c1]|, |4/4: [1/4d1, 1/4d1]| ] × 2")
    }

    @Test func expandManyMeasuresRepeatedMany() async throws {
        let measureRepeat = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 3)
        let repeatedMeasure1 = RepeatedMeasure(immutableMeasure: measure1)
        let repeatedMeasure2 = RepeatedMeasure(immutableMeasure: measure2)
        let expected = [
            measure1, measure2,
            repeatedMeasure1, repeatedMeasure2,
            repeatedMeasure1, repeatedMeasure2,
            repeatedMeasure1, repeatedMeasure2,
        ] as [ImmutableMeasure]
        let actual = measureRepeat.expand()
        guard actual.count == expected.count else {
            Issue.record("actual.count(\(actual.count)) == expected.count(\(expected.count))")
            return
        }
        #expect(compareImmutableMeasureArrays(actual: actual, expected: expected))
        #expect(String(describing: measureRepeat) == "[ |4/4: [1/8c1, 1/8c1]|, |4/4: [1/4d1, 1/4d1]| ] × 4")
    }

    // MARK: - ==

    // MARK: Failures

    @Test func equalitySameMeasureCountDifferentMeasures() async throws {
        let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2, measure1])
        let measureRepeat2 = try MeasureRepeat(measures: [measure2, measure1, measure2])
        #expect(measureRepeat1 != measureRepeat2)
    }

    @Test func equalityDifferentMeasureCountSameMeasures() async throws {
        let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2])
        let measureRepeat2 = try MeasureRepeat(measures: [measure1, measure2, measure1])
        #expect(measureRepeat1 != measureRepeat2)
    }

    @Test func equalityDifferentMeasureCountDifferentMeasures() async throws {
        let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2])
        let measureRepeat2 = try MeasureRepeat(measures: [measure2, measure1, measure2])
        #expect(measureRepeat1 != measureRepeat2)
    }

    @Test func equalityDifferentRepeatCount() async throws {
        let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 2)
        let measureRepeat2 = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 3)
        #expect(measureRepeat1 != measureRepeat2)
    }

    // MARK: Successes

    @Test func equalitySucceeds() async throws {
        let measureRepeat1 = try MeasureRepeat(measures: [measure1], repeatCount: 2)
        let measureRepeat2 = try MeasureRepeat(measures: [measure1], repeatCount: 2)
        #expect(measureRepeat1 == measureRepeat2)
    }

    // MARK: - Helpers

    private func compareImmutableMeasureArrays(actual: [ImmutableMeasure], expected: [ImmutableMeasure]) -> Bool {
        for (index, item) in actual.enumerated() {
            if let item = item as? RepeatedMeasure {
                if let expectedItem = expected[index] as? RepeatedMeasure {
                    if item == expectedItem {
                        continue
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else if let item = item as? Measure {
                if let expectedItem = expected[index] as? Measure {
                    if item == expectedItem {
                        continue
                    } else {
                        return false
                    }
                } else {
                    return false
                }
            } else {
                Issue.record("actual.count(\(actual.count)) == expected.count(\(expected.count))")
                return false
            }
        }
        return true
    }
}
