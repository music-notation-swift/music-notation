//
//  NoteDurationTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 8/21/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCoreMac
import XCTest

class NoteDurationTests: XCTestCase {
	let allValues: [NoteDuration.Value] = [
		.large,
		.long,
		.doubleWhole,
		.whole,
		.half,
		.quarter,
		.eighth,
		.sixteenth,
		.thirtySecond,
		.sixtyFourth,
		.oneTwentyEighth,
		.twoFiftySixth,
	]

	// MARK: - init(value:dotCount:)

	// MARK: Failures

	func testInitNegativeDotCount() {
		assertThrowsError(NoteDurationError.negativeDotCountInvalid) {
			_ = try NoteDuration(value: .quarter, dotCount: -1)
		}
	}

	// MARK: Successes

	func testInitDotCountZero() {
		let dotCount = 0

		assertNoErrorThrown {
			try allValues.forEach {
				let duration = try NoteDuration(value: $0, dotCount: dotCount)
				XCTAssertEqual(duration.value, $0)
				XCTAssertEqual(duration.dotCount, dotCount)
			}
		}
	}

	func testInitDotCountNonZero() {
		let dotCount = 2

		assertNoErrorThrown {
			try allValues.forEach {
				let duration = try NoteDuration(value: $0, dotCount: dotCount)
				XCTAssertEqual(duration.value, $0)
				XCTAssertEqual(duration.dotCount, dotCount)
			}
		}
	}

	func testInitDotCountLargerThan4() {
		let dotCount = 5

		assertNoErrorThrown {
			try allValues.forEach {
				let duration = try NoteDuration(value: $0, dotCount: dotCount)
				XCTAssertEqual(duration.value, $0)
				XCTAssertEqual(duration.dotCount, dotCount)
			}
		}
	}

	// MARK: - init(timeSignatureValue:)

	// Cannot fail

	func testInitTimeSignatureValue() {
		XCTAssertEqual(
			NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .whole)!),
			.whole
		)
		XCTAssertEqual(
			NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .half)!),
			.half
		)
		XCTAssertEqual(
			NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .quarter)!),
			.quarter
		)
		XCTAssertEqual(
			NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .eighth)!),
			.eighth
		)
		XCTAssertEqual(
			NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .sixteenth)!),
			.sixteenth
		)
		XCTAssertEqual(
			NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .thirtySecond)!),
			.thirtySecond
		)
		XCTAssertEqual(
			NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .sixtyFourth)!),
			.sixtyFourth
		)
		XCTAssertEqual(
			NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .oneTwentyEighth)!),
			.oneTwentyEighth
		)
	}

	// MARK: - number(of:equalTo:)

	// MARK: Successes

	func testEqualToForSameDuration() {
		XCTAssertEqual(NoteDuration.number(of: .large, within: .large), 1)
		XCTAssertEqual(NoteDuration.number(of: .long, within: .long), 1)
		XCTAssertEqual(NoteDuration.number(of: .doubleWhole, within: .doubleWhole), 1)
		XCTAssertEqual(NoteDuration.number(of: .whole, within: .whole), 1)
		XCTAssertEqual(NoteDuration.number(of: .half, within: .half), 1)
		XCTAssertEqual(NoteDuration.number(of: .quarter, within: .quarter), 1)
		XCTAssertEqual(NoteDuration.number(of: .eighth, within: .eighth), 1)
		XCTAssertEqual(NoteDuration.number(of: .sixteenth, within: .sixteenth), 1)
		XCTAssertEqual(NoteDuration.number(of: .thirtySecond, within: .thirtySecond), 1)
		XCTAssertEqual(NoteDuration.number(of: .sixtyFourth, within: .sixtyFourth), 1)
		XCTAssertEqual(NoteDuration.number(of: .oneTwentyEighth, within: .oneTwentyEighth), 1)
		XCTAssertEqual(NoteDuration.number(of: .twoFiftySixth, within: .twoFiftySixth), 1)
	}

	func testEqualToForSameDurationSingleDot() {
		assertNoErrorThrown {
			let noteDuration = try NoteDuration(value: .quarter, dotCount: 1)
			XCTAssertEqual(
				NoteDuration.number(of: try NoteDuration(value: .quarter, dotCount: 1), within: noteDuration),
				1
			)
		}
	}

	func testEqualToForSameDurationMultipleDot() {
		assertNoErrorThrown {
			let noteDuration = try NoteDuration(value: .quarter, dotCount: 3)
			XCTAssertEqual(
				NoteDuration.number(of: try NoteDuration(value: .quarter, dotCount: 3), within: noteDuration),
				1
			)
		}
	}

	func testEqualToForSmallerDuration() {
		let noteDuration = NoteDuration.sixteenth
		XCTAssertEqual(NoteDuration.number(of: .sixtyFourth, within: noteDuration), 4)
	}

	func testEqualToForLargerDuration() {
		let noteDuration = NoteDuration.quarter
		XCTAssertEqual(NoteDuration.number(of: .whole, within: noteDuration), 0.25)
	}

	func testEqualToForSmallerDurationSingleDotFromNoDot() {
		let noteDuration = NoteDuration.quarter
		XCTAssertEqual(
			NoteDuration.number(of: try NoteDuration(value: .eighth, dotCount: 1), within: noteDuration),
			Double(4) / 3
		)
	}

	func testEqualToForSmallerDurationSingleDotFromSingleDot() {
		assertNoErrorThrown {
			let noteDuration = try NoteDuration(value: .quarter, dotCount: 1)
			XCTAssertEqual(
				NoteDuration.number(of: try NoteDuration(value: .sixteenth, dotCount: 1), within: noteDuration),
				4
			)
		}
	}

	func testEqualToForSmallerDurationDoubleDotFromDoubleDot() {
		assertNoErrorThrown {
			let noteDuration = try NoteDuration(value: .quarter, dotCount: 2)
			XCTAssertEqual(
				NoteDuration.number(of: try NoteDuration(value: .thirtySecond, dotCount: 2), within: noteDuration),
				8
			)
		}
	}

	// MARK: - debugDescription

	func testDebugDescriptionNoDot() {
		XCTAssertEqual(NoteDuration.large.debugDescription, "8")
		XCTAssertEqual(NoteDuration.long.debugDescription, "4")
		XCTAssertEqual(NoteDuration.doubleWhole.debugDescription, "2")
		XCTAssertEqual(NoteDuration.whole.debugDescription, "1")
		XCTAssertEqual(NoteDuration.half.debugDescription, "1/2")
		XCTAssertEqual(NoteDuration.quarter.debugDescription, "1/4")
		XCTAssertEqual(NoteDuration.eighth.debugDescription, "1/8")
		XCTAssertEqual(NoteDuration.sixteenth.debugDescription, "1/16")
		XCTAssertEqual(NoteDuration.thirtySecond.debugDescription, "1/32")
		XCTAssertEqual(NoteDuration.sixtyFourth.debugDescription, "1/64")
		XCTAssertEqual(NoteDuration.oneTwentyEighth.debugDescription, "1/128")
		XCTAssertEqual(NoteDuration.twoFiftySixth.debugDescription, "1/256")
	}

	func testDebugDescriptionSingleDot() {
		XCTAssertEqual(try! NoteDuration(value: .quarter, dotCount: 1).debugDescription, "1/4.")
	}

	func testDebugDescriptionMultipleDots() {
		XCTAssertEqual(try! NoteDuration(value: .sixtyFourth, dotCount: 3).debugDescription, "1/64...")
	}

	// MARK: - timeSignatureValue

	func testTimeSignatureValue() {
		XCTAssertNil(NoteDuration.large.timeSignatureValue)
		XCTAssertNil(NoteDuration.long.timeSignatureValue)
		XCTAssertNil(NoteDuration.doubleWhole.timeSignatureValue)
		XCTAssertEqual(NoteDuration.whole.timeSignatureValue?.rawValue, 1)
		XCTAssertEqual(NoteDuration.half.timeSignatureValue?.rawValue, 2)
		XCTAssertEqual(NoteDuration.quarter.timeSignatureValue?.rawValue, 4)
		XCTAssertEqual(NoteDuration.eighth.timeSignatureValue?.rawValue, 8)
		XCTAssertEqual(NoteDuration.sixteenth.timeSignatureValue?.rawValue, 16)
		XCTAssertEqual(NoteDuration.thirtySecond.timeSignatureValue?.rawValue, 32)
		XCTAssertEqual(NoteDuration.sixtyFourth.timeSignatureValue?.rawValue, 64)
		XCTAssertEqual(NoteDuration.oneTwentyEighth.timeSignatureValue?.rawValue, 128)
		XCTAssertNil(NoteDuration.twoFiftySixth.timeSignatureValue?.rawValue)
	}
}
