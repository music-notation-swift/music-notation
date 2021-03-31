//
//	StaffTests.swift
//	MusicNotationCore
//
//	Created by Steven Woolgar on 2021-01-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

@testable import MusicNotation
import XCTest

// swiftlint:disable force_try
class ScoreTests: XCTestCase {
	enum Constant {
		static let standardClef: Clef = .treble
	}

	var score: Score!
	var staff: Staff!

	var measure1: Measure!
	var measure2: Measure!
	var measure3: Measure!
	var measure4: Measure!
	var measure5: Measure!
	var measure6: Measure!
	var measure7: Measure!
	var measure8: Measure!
	var repeat1: MeasureRepeat!
	var repeat2: MeasureRepeat!

	override func setUp() {
		super.setUp()
		staff = Staff(clef: Constant.standardClef, instrument: Instrument())
		let timeSignature = TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120)
		let key = Key(noteLetter: .c)
		let note = Note(noteDuration: .sixteenth,
						pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let note2 = Note(noteDuration: .sixteenth,
						 pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let tuplet = try! Tuplet(3, .sixteenth, notes: [note, note, note])
		let tuplet2 = try! Tuplet(3, .sixteenth, notes: [note2, note, note])

		measure1 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[note, note, note, note, tuplet]]
		)
		measure2 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[tuplet, note, note]]
		)
		measure3 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[note, note, note, note, tuplet]]
		)
		measure4 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[note, note, note, note]]
		)
		measure5 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[tuplet, note, note, note, note]]
		)
		measure6 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[tuplet, tuplet, note, note]]
		)
		measure7 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[note2, tuplet, tuplet, note]]
		)
		measure8 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[tuplet2, note, note]]
		)
		repeat1 = try! MeasureRepeat(measures: [measure4])
		repeat2 = try! MeasureRepeat(measures: [measure4, measure4], repeatCount: 2)
		staff.appendMeasure(measure1)
		staff.appendMeasure(measure2)
		staff.appendMeasure(measure3)
		staff.appendMeasure(measure4)
		staff.appendMeasure(measure5)
		staff.appendRepeat(repeat1) // index = 5
		staff.appendRepeat(repeat2) // index = 7
		staff.appendMeasure(measure6) // index = 13
		staff.appendMeasure(measure3)
		staff.appendMeasure(measure7)
		staff.appendMeasure(measure8)

		score = Score(parts: [Part(staves: [staff])])
	}

	// swiftlint:disable line_length
	func testDescription() {
		XCTAssertEqual(staff!.debugDescription, "staff(treble Instrument(name: \"\", lineCount: 0, chromaticTransposition: 0, octaveTransposition: 0) |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1, 1/16c1, 1/16c1]|, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 2, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 3, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16a1, 3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1]|, |4/4: [3[1/16a1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|)")
	}
}
