//
//  PitchTests.swift
//  MusicNotationCore
//
//  Created by Rob Hudson on 7/29/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import MusicNotationCoreMac
import XCTest

class PitchTests: XCTestCase {
	func testPitch1() {
		let pitch = SpelledPitch(noteLetter: .c, octave: .octave3)
		XCTAssertTrue(pitch.debugDescription == "c3")
	}

	func testPitch2() {
		let pitch = SpelledPitch(noteLetter: .g, accidental: .sharp, octave: .octave6)
		XCTAssertTrue(pitch.debugDescription == "g♯6")
	}

	func testPitch3() {
		let pitch = SpelledPitch(noteLetter: .e, accidental: .flat, octave: .octave2)
		XCTAssertTrue(pitch.debugDescription == "e♭2")
	}

	func testPitch4() {
		let pitch = SpelledPitch(noteLetter: .a, accidental: .natural, octave: .octave4)
		XCTAssertTrue(pitch.debugDescription == "a4")
	}

	func testPitch5() {
		let pitch = SpelledPitch(noteLetter: .b, accidental: .doubleSharp, octave: .octave5)
		XCTAssertTrue(pitch.debugDescription == "b𝄪5")
	}

	func testPitch6() {
		let pitch = SpelledPitch(noteLetter: .f, accidental: .doubleFlat, octave: .octave7)
		XCTAssertTrue(pitch.debugDescription == "f𝄫7")
	}

	// MARK: - ==

	// MARK: Failures

	func testNotEqual() {
		let pitch1 = SpelledPitch(noteLetter: .b, accidental: .flat, octave: .octave5)
		let pitch2 = SpelledPitch(noteLetter: .b, accidental: .flat, octave: .octave4)

		XCTAssertNotEqual(pitch1, pitch2)
	}

	// MARK: Successes

	func testEqual() {
		let pitch1 = SpelledPitch(noteLetter: .d, accidental: .sharp, octave: .octave1)
		let pitch2 = SpelledPitch(noteLetter: .d, accidental: .sharp, octave: .octave1)

		XCTAssertEqual(pitch1, pitch2)
	}

	// MARK: - MIDI numbers

	// MARK: Successes

	func testRidiculouslyLowNote() {
		let pitch = SpelledPitch(noteLetter: .c, accidental: .natural, octave: .octaveNegative1)

		XCTAssertEqual(pitch.midiNoteNumber, 0)
	}

	func testLowNote() {
		let pitch = SpelledPitch(noteLetter: .f, accidental: .sharp, octave: .octave1)

		XCTAssertEqual(pitch.midiNoteNumber, 30)
	}

	func testMidRangeNote() {
		let pitch = SpelledPitch(noteLetter: .d, octave: .octave4)

		XCTAssertEqual(pitch.midiNoteNumber, 62)
	}

	func testHighNote() {
		let pitch = SpelledPitch(noteLetter: .c, accidental: .flat, octave: .octave8)

		XCTAssertEqual(pitch.midiNoteNumber, 107)
	}

	// MARK: - isEnharmonic(with:)

	// MARK: Failures

	func testDifferentAccidentals() {
		let pitch1 = SpelledPitch(noteLetter: .d, accidental: .flat, octave: .octave1)
		let pitch2 = SpelledPitch(noteLetter: .d, accidental: .sharp, octave: .octave1)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertFalse(pitch1.isEnharmonic(with: pitch2))
	}

	func testSamePitchDifferentOctaves() {
		let pitch1 = SpelledPitch(noteLetter: .e, accidental: .natural, octave: .octave5)
		let pitch2 = SpelledPitch(noteLetter: .e, accidental: .natural, octave: .octave6)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertFalse(pitch1.isEnharmonic(with: pitch2))
	}

	func testEnharmonicPitchDifferentOctaves() {
		let pitch1 = SpelledPitch(noteLetter: .f, accidental: .doubleSharp, octave: .octave2)
		let pitch2 = SpelledPitch(noteLetter: .g, accidental: .natural, octave: .octave5)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertFalse(pitch1.isEnharmonic(with: pitch2))
	}

	// MARK: Successes

	func testSamePitchIsEnharmonic() {
		let pitch1 = SpelledPitch(noteLetter: .g, accidental: .natural, octave: .octave6)
		let pitch2 = SpelledPitch(noteLetter: .g, accidental: .natural, octave: .octave6)

		XCTAssertEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
		// Transitive property
		XCTAssertTrue(pitch2.isEnharmonic(with: pitch1))
	}

	func testEnharmonicNotEquatable() {
		let pitch1 = SpelledPitch(noteLetter: .a, accidental: .flat, octave: .octave3)
		let pitch2 = SpelledPitch(noteLetter: .g, accidental: .sharp, octave: .octave3)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
	}

	func testNaturalAndFlat() {
		let pitch1 = SpelledPitch(noteLetter: .e, accidental: .natural, octave: .octave4)
		let pitch2 = SpelledPitch(noteLetter: .f, accidental: .flat, octave: .octave4)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
	}

	func testDoubleFlat() {
		let pitch1 = SpelledPitch(noteLetter: .b, accidental: .doubleFlat, octave: .octave2)
		let pitch2 = SpelledPitch(noteLetter: .a, octave: .octave2)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
	}

	func testDifferentOctaveNumbers() {
		let pitch1 = SpelledPitch(noteLetter: .b, accidental: .sharp, octave: .octave6)
		let pitch2 = SpelledPitch(noteLetter: .c, accidental: .natural, octave: .octave7)

		XCTAssertNotEqual(pitch1, pitch2)
		XCTAssertTrue(pitch1.isEnharmonic(with: pitch2))
	}
}
