//
//  MeasureRepeatTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 3/9/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCoreMac
import XCTest

class MeasureRepeatTests: XCTestCase {
	static let timeSignature = TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120)
	static let key = Key(noteLetter: .c)
	static let note1 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
	static let note2 = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .d, octave: .octave1))
	let measure1 = Measure(timeSignature: timeSignature, key: key, notes: [[note1, note1]])
	let measure2 = Measure(timeSignature: timeSignature, key: key, notes: [[note2, note2]])

	// MARK: - init(measures:repeateCount:)

	// MARK: Failures

	func testInitInvalidRepeatCount() {
		assertThrowsError(MeasureRepeatError.invalidRepeatCount) {
			_ = try MeasureRepeat(measures: [measure1], repeatCount: -2)
		}
	}

	func testInitNoMeasures() {
		assertThrowsError(MeasureRepeatError.noMeasures) {
			_ = try MeasureRepeat(measures: [])
		}
	}

	// MARK: Successes

	func testInitNotSpecifiedRepeatCount() {
		assertNoErrorThrown {
			let measureRepeat = try MeasureRepeat(measures: [measure1])
			XCTAssertEqual(measureRepeat.repeatCount, 1)
		}
	}

	func testInitSingleMeasure() {
		assertNoErrorThrown {
			_ = try MeasureRepeat(measures: [measure2], repeatCount: 3)
		}
	}

	func testInitMultipleMeasures() {
		assertNoErrorThrown {
			_ = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 4)
		}
	}

	// MARK: - expand()

	func testExpandSingleMeasureRepeatedOnce() {
		assertNoErrorThrown {
			let measureRepeat = try MeasureRepeat(measures: [measure1], repeatCount: 1)
			let expected = [measure1, RepeatedMeasure(immutableMeasure: measure1)] as [ImmutableMeasure]
			let actual = measureRepeat.expand()
			guard actual.count == expected.count else {
				XCTFail()
				return
			}
			XCTAssertTrue(compareImmutableMeasureArrays(actual: actual, expected: expected))
			XCTAssertEqual(String(describing: measureRepeat), "[ |4/4: [1/8c1, 1/8c1]| ] × 2")
		}
	}

	func testExpandSingleMeasureRepeatedMany() {
		assertNoErrorThrown {
			let measureRepeat = try MeasureRepeat(measures: [measure1], repeatCount: 3)
			let repeatedMeasure = RepeatedMeasure(immutableMeasure: measure1)
			let expected = [measure1, repeatedMeasure, repeatedMeasure, repeatedMeasure] as [ImmutableMeasure]
			let actual = measureRepeat.expand()
			guard actual.count == expected.count else {
				XCTFail()
				return
			}
			XCTAssertTrue(compareImmutableMeasureArrays(actual: actual, expected: expected))
			XCTAssertEqual(String(describing: measureRepeat), "[ |4/4: [1/8c1, 1/8c1]| ] × 4")
		}
	}

	func testExpandManyMeasuresRepeatedOnce() {
		assertNoErrorThrown {
			let measureRepeat = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 1)
			let repeatedMeasure1 = RepeatedMeasure(immutableMeasure: measure1)
			let repeatedMeasure2 = RepeatedMeasure(immutableMeasure: measure2)
			let expected = [measure1, measure2, repeatedMeasure1, repeatedMeasure2] as [ImmutableMeasure]
			let actual = measureRepeat.expand()
			guard actual.count == expected.count else {
				XCTFail()
				return
			}
			XCTAssertTrue(compareImmutableMeasureArrays(actual: actual, expected: expected))
			XCTAssertEqual(String(describing: measureRepeat), "[ |4/4: [1/8c1, 1/8c1]|, |4/4: [1/4d1, 1/4d1]| ] × 2")
		}
	}

	func testExpandManyMeasuresRepeatedMany() {
		assertNoErrorThrown {
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
				XCTFail()
				return
			}
			XCTAssertTrue(compareImmutableMeasureArrays(actual: actual, expected: expected))
			XCTAssertEqual(String(describing: measureRepeat), "[ |4/4: [1/8c1, 1/8c1]|, |4/4: [1/4d1, 1/4d1]| ] × 4")
		}
	}

	// MARK: - ==

	// MARK: Failures

	func testEqualitySameMeasureCountDifferentMeasures() {
		assertNoErrorThrown {
			let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2, measure1])
			let measureRepeat2 = try MeasureRepeat(measures: [measure2, measure1, measure2])
			XCTAssertFalse(measureRepeat1 == measureRepeat2)
		}
	}

	func testEqualityDifferentMeasureCountSameMeasures() {
		assertNoErrorThrown {
			let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2])
			let measureRepeat2 = try MeasureRepeat(measures: [measure1, measure2, measure1])
			XCTAssertFalse(measureRepeat1 == measureRepeat2)
		}
	}

	func testEqualityDifferentMeasureCountDifferentMeasures() {
		assertNoErrorThrown {
			let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2])
			let measureRepeat2 = try MeasureRepeat(measures: [measure2, measure1, measure2])
			XCTAssertFalse(measureRepeat1 == measureRepeat2)
		}
	}

	func testEqualityDifferentRepeatCount() {
		assertNoErrorThrown {
			let measureRepeat1 = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 2)
			let measureRepeat2 = try MeasureRepeat(measures: [measure1, measure2], repeatCount: 3)
			XCTAssertFalse(measureRepeat1 == measureRepeat2)
		}
	}

	// MARK: Successes

	func testEqualitySucceeds() {
		assertNoErrorThrown {
			let measureRepeat1 = try MeasureRepeat(measures: [measure1], repeatCount: 2)
			let measureRepeat2 = try MeasureRepeat(measures: [measure1], repeatCount: 2)
			XCTAssertTrue(measureRepeat1 == measureRepeat2)
		}
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
				XCTFail("Item was not a Measure nor RepeatedMeasure")
				return false
			}
		}
		return true
	}
}
