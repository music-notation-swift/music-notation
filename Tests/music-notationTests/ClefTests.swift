//
//  ClefTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 10/16/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCoreMac
import XCTest

class ClefTests: XCTestCase {
	// MARK: - init(pitch:lineNumber)

	// MARK: Successes

	func testInitForCustomOnLine() throws {
		let clef = Clef(pitch: SpelledPitch(noteLetter: .c, octave: .octave4),
						location: StaffLocation(type: .line, number: 0))
		XCTAssertEqual(clef.staffLocation.halfSteps, 0)
	}

	func testInitForCustomOnSpace() {
		let clef = Clef(pitch: SpelledPitch(noteLetter: .g, octave: .octave4),
						location: StaffLocation(type: .space, number: 1))
		XCTAssertEqual(clef.staffLocation.halfSteps, 3)
	}

	func testInitForCustomNegativeLedger() {
		let clef = Clef(pitch: SpelledPitch(noteLetter: .g, octave: .octave3),
						location: StaffLocation(type: .line, number: -2))
		XCTAssertEqual(clef.staffLocation.halfSteps, -4)
	}

	func testInitForCustomPositiveLedger() {
		let clef = Clef(pitch: SpelledPitch(noteLetter: .a, octave: .octave4),
						location: StaffLocation(type: .line, number: 7))
		XCTAssertEqual(clef.staffLocation.halfSteps, 14)
	}

	// MARK: - pitch(at:)

	// MARK: Failures

	func testPitchAtOctaveOutOfRange() {
		assertThrowsError(ClefError.octaveOutOfRange) {
			_ = try Clef.treble.pitch(at: StaffLocation(type: .space, number: 300))
		}

		assertThrowsError(ClefError.octaveOutOfRange) {
			_ = try Clef.treble.pitch(at: StaffLocation(type: .line, number: 300))
		}

		assertThrowsError(ClefError.octaveOutOfRange) {
			_ = try Clef.treble.pitch(at: StaffLocation(type: .space, number: -300))
		}

		assertThrowsError(ClefError.octaveOutOfRange) {
			_ = try Clef.treble.pitch(at: StaffLocation(type: .line, number: -300))
		}
	}

	// MARK: Successes

	func testPitchAtUnpitched() {
		assertNoErrorThrown {
			XCTAssertNil(try Clef.neutral.pitch(at: StaffLocation(type: .space, number: 1)))
			XCTAssertNil(try Clef.tab.pitch(at: StaffLocation(type: .space, number: 1)))
		}
	}

	func testPitchAtLocationWithinStaffIncrease() {
		assertNoErrorThrown {
			XCTAssertEqual(try Clef.treble.pitch(at: StaffLocation(type: .space, number: 2)),
						   SpelledPitch(noteLetter: .c, octave: .octave5))
			XCTAssertEqual(try Clef.treble.pitch(at: StaffLocation(type: .line, number: 2)),
						   SpelledPitch(noteLetter: .b, octave: .octave4))
			XCTAssertEqual(try Clef.bass.pitch(at: StaffLocation(type: .space, number: 3)),
						   SpelledPitch(noteLetter: .g, octave: .octave3))
			XCTAssertEqual(try Clef.alto.pitch(at: StaffLocation(type: .line, number: 4)),
						   SpelledPitch(noteLetter: .g, octave: .octave4))
			XCTAssertEqual(try Clef.soprano.pitch(at: StaffLocation(type: .space, number: 3)),
						   SpelledPitch(noteLetter: .c, octave: .octave5))

			let customBClef = Clef(
				pitch: SpelledPitch(noteLetter: .b, octave: .octave3),
				location: StaffLocation(type: .line, number: 2)
			)
			XCTAssertEqual(try customBClef.pitch(at: StaffLocation(type: .space, number: 2)),
						   SpelledPitch(noteLetter: .c, octave: .octave4))
		}
	}

	func testPitchAtLocationDecrease() {
		assertNoErrorThrown {
			XCTAssertEqual(try Clef.treble.pitch(at: StaffLocation(type: .line, number: 0)),
						   SpelledPitch(noteLetter: .e, octave: .octave4))
			XCTAssertEqual(try Clef.treble.pitch(at: StaffLocation(type: .space, number: -1)),
						   SpelledPitch(noteLetter: .d, octave: .octave4))
			XCTAssertEqual(try Clef.alto.pitch(at: StaffLocation(type: .line, number: -3)),
						   SpelledPitch(noteLetter: .g, octave: .octave2))
			XCTAssertEqual(try Clef.alto.pitch(at: StaffLocation(type: .line, number: -2)),
						   SpelledPitch(noteLetter: .b, octave: .octave2))
			XCTAssertEqual(try Clef.alto.pitch(at: StaffLocation(type: .space, number: 1)),
						   SpelledPitch(noteLetter: .b, octave: .octave3))
			XCTAssertEqual(try Clef.bass.pitch(at: StaffLocation(type: .line, number: 1)),
						   SpelledPitch(noteLetter: .b, octave: .octave2))
		}
	}

	func testPitchAtSamePitchAsClef() {
		assertNoErrorThrown {
			XCTAssertEqual(try Clef.treble.pitch(at: StaffLocation(type: .line, number: 1)),
						   SpelledPitch(noteLetter: .g, octave: .octave4))
			XCTAssertEqual(try Clef.soprano.pitch(at: StaffLocation(type: .line, number: 0)),
						   SpelledPitch(noteLetter: .c, octave: .octave4))
		}
	}

	func testPitchAtNegativeClefDecrease() {
		assertNoErrorThrown {
			let negativeClef = Clef(pitch: SpelledPitch(noteLetter: .d, octave: .octave3),
									location: StaffLocation(type: .line, number: -1))
			XCTAssertEqual(try negativeClef.pitch(at: StaffLocation(type: .line, number: -2)),
						   SpelledPitch(noteLetter: .b, octave: .octave2))
		}
	}

	// MARK: - ==

	// MARK: Failures

	func testEqualityFailStandard() {
		XCTAssertFalse(Clef.treble == Clef.bass)
	}

	func testEqualityFailDifferentPitch() {
		let custom1 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave3),
			location: StaffLocation(type: .line, number: 1)
		)
		let custom2 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .line, number: 1)
		)
		XCTAssertFalse(custom1 == custom2)
	}

	func testEqualityFailDifferentLineNumber() {
		let custom1 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .space, number: 1)
		)
		let custom2 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .space, number: 2)
		)
		XCTAssertFalse(custom1 == custom2)
	}

	// MARK: Successes

	func testEqualityStandard() {
		XCTAssertTrue(Clef.treble == Clef.treble)
	}

	func testEqualityCustom() {
		let custom1 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .line, number: 1)
		)
		let custom2 = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave2),
			location: StaffLocation(type: .line, number: 1)
		)
		XCTAssertTrue(custom1 == custom2)
	}

	func testEqualityCustomWithStandard() {
		let treble = Clef(
			pitch: SpelledPitch(noteLetter: .g, octave: .octave4),
			location: StaffLocation(type: .line, number: 1)
		)
		XCTAssertTrue(treble == Clef.treble)
	}

	// MARK: - debugDescription

	// MARK: Successes

	func testDescriptionStandard() {
		XCTAssertEqual(Clef.treble.debugDescription, "treble")
		XCTAssertEqual(Clef.bass.debugDescription, "bass")
		XCTAssertEqual(Clef.tenor.debugDescription, "tenor")
		XCTAssertEqual(Clef.alto.debugDescription, "alto")
		XCTAssertEqual(Clef.neutral.debugDescription, "neutral")
		XCTAssertEqual(Clef.tab.debugDescription, "neutral")
		XCTAssertEqual(Clef.frenchViolin.debugDescription, "frenchViolin")
		XCTAssertEqual(Clef.soprano.debugDescription, "soprano")
		XCTAssertEqual(Clef.mezzoSoprano.debugDescription, "mezzoSoprano")
		XCTAssertEqual(Clef.baritone.debugDescription, "baritone")
		XCTAssertEqual(Clef.suboctaveTreble.debugDescription, "suboctaveTreble")
	}

	func testDescriptionCustom() {
		let custom = Clef(
			pitch: SpelledPitch(noteLetter: .a, octave: .octave3),
			location: StaffLocation(type: .line, number: 1)
		)
		XCTAssertEqual(custom.debugDescription, "a3@line1")
		let customNeutral = Clef(
			pitch: nil,
			location: StaffLocation(type: .space, number: 3)
		)
		XCTAssertEqual(customNeutral.debugDescription, "neutral")
	}
}
