//
//  StaffTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 9/5/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCoreMac
import XCTest

class StaffTests: XCTestCase {
	enum Constant {
		static let standardClef: Clef = .treble
	}

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
		staff = Staff(clef: Constant.standardClef, instrument: .guitar6)
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
	}

	// MARK: - insertMeasure(_:, at:)

	// MARK: Failures

	func testInsertMeasureInvalidIndex() {
		let measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .c)
		)

		assertThrowsError(StaffError.measureIndexOutOfRange) {
			try staff.insertMeasure(measure, at: 17)
		}
	}

	func testInsertMeasureInRepeatedMeasures() {
		let measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .c)
		)

		assertThrowsError(MeasureRepeatError.cannotModifyRepeatedMeasures) {
			try staff.insertMeasure(measure, at: 10, beforeRepeat: true)
		}
	}

	// MARK: Successes

	func testDescription() {
		XCTAssertEqual(staff!.debugDescription, "staff(treble guitar6 |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1, 1/16c1, 1/16c1]|, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 2, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 3, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16a1, 3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1]|, |4/4: [3[1/16a1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|)")
	}

	func testInsertMeasureNoRepeat() {
		let measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .c)
		)
		assertNoErrorThrown {
			try staff.insertMeasure(measure, at: 1)
			let addedMeasure = try staff.measure(at: 1)
			let beforeMeasure = try staff.measure(at: 0)
			let afterMeasure = try staff.measure(at: 2)
			XCTAssertEqual(Measure(addedMeasure), changedClef(of: measure))
			// Initial measure don't have the clef set before being added to the staff
			// But then after they are in the staff, they do have the clef set.
			XCTAssertEqual(Measure(beforeMeasure), changedClef(of: measure1))
			XCTAssertEqual(Measure(afterMeasure), changedClef(of: measure2))
		}
	}

	func testInsertMeasureNoRepeatAtEnd() {
		let measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .c)
		)
		assertNoErrorThrown {
			try staff.insertMeasure(measure, at: 14)
			let addedMeasure = try staff.measure(at: 14)
			let beforeMeasure = try staff.measure(at: 13)
			let afterMeasure = try staff.measure(at: 15)
			XCTAssertEqual(Measure(addedMeasure), changedClef(of: measure))
			XCTAssertEqual(Measure(beforeMeasure), changedClef(of: measure6))
			XCTAssertEqual(Measure(afterMeasure), changedClef(of: measure3))
		}
	}

	func testInsertMeasureInRepeat() {
		var measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .c)
		)
		measure.lastClef = staff.clef
		measure.originalClef = staff.clef
		assertNoErrorThrown {
			try staff.insertMeasure(measure, at: 5, beforeRepeat: false)
			let actualRepeat = try staff.measureRepeat(at: 5)
			let expectedRepeat = try MeasureRepeat(measures: [measure, measure4])
			XCTAssertEqual(actualRepeat, changedClef(ofAllMeasuresInRepeat: expectedRepeat))
		}
	}

	func testInsertMeasureInRepeatAtEnd() {
		var measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .c)
		)
		measure.lastClef = staff.clef
		measure.originalClef = staff.clef
		assertNoErrorThrown {
			try staff.insertMeasure(measure, at: 6, beforeRepeat: false)
			let actualRepeat = try staff.measureRepeat(at: 5)
			let expectedRepeat = try MeasureRepeat(measures: [measure4, measure])
			XCTAssertEqual(actualRepeat, changedClef(ofAllMeasuresInRepeat: expectedRepeat))
		}
	}

	func testInsertMeasureBeforeRepeat() {
		let measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .c)
		)
		assertNoErrorThrown {
			try staff.insertMeasure(measure, at: 5, beforeRepeat: true)
			_ = try staff.measureRepeat(at: 6)
			let addedMeasure = try staff.measure(at: 5)
			let beforeMeasure = try staff.measure(at: 4)
			XCTAssertEqual(Measure(addedMeasure), changedClef(of: measure))
			XCTAssertEqual(Measure(beforeMeasure), changedClef(of: measure5))
		}
	}

	func testInsertMeasureNoRepeatWithWrongFlag() {
		let measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .c)
		)
		assertNoErrorThrown {
			// Ignores the flag, since it's not a repeat
			try staff.insertMeasure(measure, at: 1, beforeRepeat: false)
			let addedMeasure = try staff.measure(at: 1)
			let beforeMeasure = try staff.measure(at: 0)
			let afterMeasure = try staff.measure(at: 2)
			XCTAssertEqual(Measure(addedMeasure), changedClef(of: measure))
			XCTAssertEqual(Measure(beforeMeasure), changedClef(of: measure1))
			XCTAssertEqual(Measure(afterMeasure), changedClef(of: measure2))
		}
	}

	func testInsertMeasureInMeasureRepeatWithWrongFlag() {
		var measure = Measure(
			timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
			key: Key(noteLetter: .c)
		)
		measure.lastClef = staff.clef
		measure.originalClef = staff.clef
		assertNoErrorThrown {
			// Ignores the flag since you can only insert it into the repeat
			try staff.insertMeasure(measure, at: 6, beforeRepeat: true)
			let actualRepeat = try staff.measureRepeat(at: 5)
			let expectedRepeat = try MeasureRepeat(measures: [measure4, measure])
			XCTAssertEqual(actualRepeat, changedClef(ofAllMeasuresInRepeat: expectedRepeat))
		}
	}

	// MARK: - insertRepeat(_:, at:)

	// MARK: Failures

	func testInsertRepeatInvalidIndex() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			let measureRepeat = try MeasureRepeat(measures: [measure4])
			try staff.insertRepeat(measureRepeat, at: 50)
		}
	}

	func testInsertRepeatInRepeat() {
		assertThrowsError(StaffError.cannotInsertRepeatWhereOneAlreadyExists) {
			let measureRepeat = try MeasureRepeat(measures: [measure5])
			try staff.insertRepeat(measureRepeat, at: 6)
		}
	}

	// MARK: Successes

	func testInsertRepeatSingleMeasure() {
		assertNoErrorThrown {
			let measureRepeat = try MeasureRepeat(measures: [measure4])
			try staff.insertRepeat(measureRepeat, at: 1)
			let beforeRepeat = try staff.measure(at: 0)
			let actualRepeat = try staff.measureRepeat(at: 1)
			let afterRepeat = try staff.measure(at: 3)
			XCTAssertEqual(Measure(beforeRepeat), changedClef(of: measure1))
			measure2.originalClef = staff.clef
			measure2.lastClef = staff.clef
			XCTAssertEqual(Measure(afterRepeat), changedClef(of: measure2))
			XCTAssertEqual(actualRepeat, changedClef(ofAllMeasuresInRepeat: measureRepeat))
		}
	}

	func testInsertRepeatBeforeOtherRepeat() {
		assertNoErrorThrown {
			let measureRepeat = try MeasureRepeat(measures: [measure5])
			try staff.insertRepeat(measureRepeat, at: 5)
			let beforeRepeat = try staff.measure(at: 4)
			let actualRepeat = try staff.measureRepeat(at: 5)
			let afterRepeat = try staff.measureRepeat(at: 7)
			XCTAssertEqual(Measure(beforeRepeat), changedClef(of: measure5))
			XCTAssertEqual(afterRepeat, changedClef(ofAllMeasuresInRepeat: repeat1))
			XCTAssertEqual(actualRepeat, changedClef(ofAllMeasuresInRepeat: measureRepeat))
		}
	}

	// MARK: - startTieFromNote(at:, inMeasureAt:)

	// MARK: Failures

	func testStartTieFailIfNoteIndexInvalid() {
		assertThrowsError(StaffError.noteIndexOutOfRange) {
			try staff.startTieFromNote(at: 10, inMeasureAt: 0)
		}
	}

	func testStartTieFailIfMeasureIndexInvalid() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			try staff.startTieFromNote(at: 0, inMeasureAt: 25)
		}
	}

	func testStartTieFailIfNoNextNote() {
		assertThrowsError(StaffError.noNextNoteToTie) {
			try staff.startTieFromNote(at: 4, inMeasureAt: 16)
		}
	}

	func testStartTieFailIfLastNoteOfSingleMeasureRepeat() {
		// Reason: can't finish in the next measure
		assertThrowsError(StaffError.repeatedMeasureCannotHaveTie) {
			try staff.startTieFromNote(at: 3, inMeasureAt: 5)
		}
	}

	func testStartTieFailIfLastNoteInLastMeasureOfMultiMeasureRepeat() {
		assertThrowsError(StaffError.repeatedMeasureCannotHaveTie) {
			try staff.startTieFromNote(at: 3, inMeasureAt: 8)
		}
	}

	func testStartTieFailIfNotesWithinRepeatAfterTheFirstCount() {
		assertThrowsError(StaffError.repeatedMeasureCannotHaveTie) {
			try staff.startTieFromNote(at: 0, inMeasureAt: 9)
		}
	}

	func testStartTieAcrossMeasuresTupletToNoteDiffPitch() {
		assertThrowsError(StaffError.notesMustHaveSamePitchesToTie) {
			try staff.startTieFromNote(at: 6, inMeasureAt: 14)
		}
	}

	func testStartTieAcrossMeasuresNoteToTupletDiffPitch() {
		assertThrowsError(StaffError.notesMustHaveSamePitchesToTie) {
			try staff.startTieFromNote(at: 7, inMeasureAt: 15)
		}
	}

	// MARK: Successes

	func testStartTieWithinMeasureIfHasNextNote() {
		assertNoErrorThrown {
			let firstNoteIndex = 0
			let firstMeasureIndex = 0
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[0][firstNoteIndex] as! Note
			let secondNote = measure.notes[0][firstNoteIndex + 1] as! Note
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
		}
	}

	func testStartTieWithinMeasureIfAlreadyEndOfTie() {
		assertNoErrorThrown {
			let firstNoteIndex = 0
			let firstMeasureIndex = 0
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			try staff.startTieFromNote(at: firstNoteIndex + 1, inMeasureAt: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[0][firstNoteIndex] as! Note
			let secondNote = measure.notes[0][firstNoteIndex + 1] as! Note
			let thirdNote = measure.notes[0][firstNoteIndex + 2] as! Note
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .beginAndEnd)
			XCTAssert(thirdNote.tie == .end)
		}
	}

	func testStartTieWithinMeasureTupletToTuplet() {
		assertNoErrorThrown {
			let firstNoteIndex = 2
			let firstMeasureIndex = 13
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let measure = staff.notesHolders[7] as! Measure
			let firstNote = try (measure.notes[0][0] as! Tuplet).note(at: 2)
			let secondNote = try (measure.notes[0][1] as! Tuplet).note(at: 0)
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
		}
	}

	func testStartTieAcrossMeasuresNoteToNote() {
		assertNoErrorThrown {
			let firstNoteIndex = 4
			let firstMeasureIndex = 1
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
			let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = firstMeasure.notes[0][2] as! Note
			let secondNote = secondMeasure.notes[0][0] as! Note
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
		}
	}

	func testStartTieAcrossMeasuresNoteToTuplet() {
		assertNoErrorThrown {
			let firstNoteIndex = 3
			let firstMeasureIndex = 3
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
			let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = firstMeasure.notes[0][3] as! Note
			let secondNote = try (secondMeasure.notes[0][0] as! Tuplet).note(at: 0)
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
		}
	}

	func testStartTieAcrossMeasuresTupletToNote() {
		assertNoErrorThrown {
			let firstNoteIndex = 6
			let firstMeasureIndex = 2
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
			let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = try (firstMeasure.notes[0][4] as! Tuplet).note(at: 2)
			let secondNote = secondMeasure.notes[0][0] as! Note
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
		}
	}

	func testStartTieAcrossMeasuresTupletToTuplet() {
		assertNoErrorThrown {
			let firstNoteIndex = 6
			let firstMeasureIndex = 0
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
			let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = try (firstMeasure.notes[0][4] as! Tuplet).note(at: 2)
			let secondNote = try (secondMeasure.notes[0][0] as! Tuplet).note(at: 0)
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
		}
	}

	func testStartTieBothNotesWithinSingleMeasureRepeat() {
		assertNoErrorThrown {
			let firstNoteIndex = 0
			let firstMeasureIndex = 5
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let firstMeasure = (staff.notesHolders[firstMeasureIndex] as! MeasureRepeat).measures[0]
			let firstNote = firstMeasure.notes[0][firstNoteIndex] as! Note
			let secondNote = firstMeasure.notes[0][firstNoteIndex + 1] as! Note
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
		}
	}

	func testStartTieBothNotesWithinMultiMeasureRepeat() {
		assertNoErrorThrown {
			let firstNoteIndex = 0
			let firstMeasureIndex = 7
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let firstMeasure = (staff.notesHolders[6] as! MeasureRepeat).measures[0]
			let firstNote = firstMeasure.notes[0][firstNoteIndex] as! Note
			let secondNote = firstMeasure.notes[0][firstNoteIndex + 1] as! Note
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
		}
	}

	func testStartTieNotesFromContiguousMeasuresWithinRepeat() {
		assertNoErrorThrown {
			let firstNoteIndex = 3
			let firstMeasureIndex = 7
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let measureRepeat = staff.notesHolders[6] as! MeasureRepeat
			let firstMeasure = measureRepeat.measures[0]
			let secondMeasure = measureRepeat.measures[1]
			let firstNote = firstMeasure.notes[0][firstNoteIndex] as! Note
			let secondNote = secondMeasure.notes[0][0] as! Note
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
		}
	}

	// MARK: - removeTieFromNote(at:, inMeasureAt:)

	// MARK: Failures

	func testRemoveTieFailIfNoteIndexInvalid() {
		assertThrowsError(StaffError.noteIndexOutOfRange) {
			try staff.removeTieFromNote(at: 10, inMeasureAt: 0)
		}
	}

	func testRemoveTieFailIfMeasureIndexInvalid() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			try staff.removeTieFromNote(at: 0, inMeasureAt: 25)
		}
	}

	// MARK: Successes

	func testRemoveTieIfNotTied() {
		assertNoErrorThrown {
			try staff.removeTieFromNote(at: 0, inMeasureAt: 0)
			let measure = staff.notesHolders[0] as! Measure
			let firstNote = measure.notes[0][0] as! Note
			XCTAssertNil(firstNote.tie)
		}
	}

	func testRemoveTieIfEndOfTie() {
		assertNoErrorThrown {
			try staff.startTieFromNote(at: 0, inMeasureAt: 0)
			try staff.removeTieFromNote(at: 1, inMeasureAt: 0)
			let measure = staff.notesHolders[0] as! Measure
			let firstNote = measure.notes[0][0] as! Note
			let secondNote = measure.notes[0][1] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieBeginIfBeginAndEndOfTie() {
		assertNoErrorThrown {
			try staff.startTieFromNote(at: 0, inMeasureAt: 0)
			try staff.startTieFromNote(at: 1, inMeasureAt: 0)
			try staff.removeTieFromNote(at: 1, inMeasureAt: 0)
			let measure = staff.notesHolders[0] as! Measure
			let firstNote = measure.notes[0][0] as! Note
			let secondNote = measure.notes[0][1] as! Note
			XCTAssertEqual(firstNote.tie, .begin)
			XCTAssertEqual(secondNote.tie, .end)
		}
	}

	func testRemoveTieWithinMeasureNoteToNote() {
		assertNoErrorThrown {
			let firstNoteIndex = 0
			let firstMeasureIndex = 0
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[0][firstNoteIndex] as! Note
			let secondNote = measure.notes[0][firstNoteIndex + 1] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieWithinMeasureWithinTuplet() {
		assertNoErrorThrown {
			let firstNoteIndex = 4
			let firstMeasureIndex = 0
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = try (measure.notes[0][firstNoteIndex] as! Tuplet).note(at: 0)
			let secondNote = try (measure.notes[0][firstNoteIndex] as! Tuplet).note(at: 1)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieWithinMeasureFromTupletToNote() {
		assertNoErrorThrown {
			let firstNoteIndex = 2
			let firstMeasureIndex = 1
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = try (measure.notes[0][0] as! Tuplet).note(at: firstNoteIndex)
			let secondNote = measure.notes[0][1] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieWithinMeasureFromTupletToNewTuplet() {
		assertNoErrorThrown {
			let firstNoteIndex = 2
			let firstMeasureIndex = 13
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let measure = staff.notesHolders[7] as! Measure
			let firstNote = try (measure.notes[0][0] as! Tuplet).note(at: firstNoteIndex)
			let secondNote = try (measure.notes[0][1] as! Tuplet).note(at: 0)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieAcrossMeasuresFromTupletToNote() {
		assertNoErrorThrown {
			let firstNoteIndex = 4
			let firstMeasureIndex = 2
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let measure1 = staff.notesHolders[firstMeasureIndex] as! Measure
			let measure2 = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = try (measure1.notes[0][4] as! Tuplet).note(at: 2)
			let secondNote = measure2.notes[0][0] as! Note
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieAcrosssMeasuresFromTupletToNewTuplet() {
		assertNoErrorThrown {
			let firstNoteIndex = 6
			let firstMeasureIndex = 0
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			let measure1 = staff.notesHolders[firstMeasureIndex] as! Measure
			let measure2 = staff.notesHolders[firstMeasureIndex + 1] as! Measure
			let firstNote = try (measure1.notes[0][4] as! Tuplet).note(at: 2)
			let secondNote = try (measure2.notes[0][0] as! Tuplet).note(at: 0)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testremoveTieFromNoteThatIsBeginAndEnd() {
		assertNoErrorThrown {
			let firstNoteIndex = 0
			let firstMeasureIndex = 0
			try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
			try staff.startTieFromNote(at: firstNoteIndex + 1, inMeasureAt: firstMeasureIndex)
			try staff.removeTieFromNote(at: firstNoteIndex + 1, inMeasureAt: firstMeasureIndex)
			let measure = staff.notesHolders[firstMeasureIndex] as! Measure
			let firstNote = measure.notes[0][firstNoteIndex] as! Note
			let secondNote = measure.notes[0][firstNoteIndex + 1] as! Note
			let thirdNote = measure.notes[0][firstNoteIndex + 2] as! Note
			XCTAssert(firstNote.tie == .begin)
			XCTAssert(secondNote.tie == .end)
			XCTAssertNil(thirdNote.tie)
		}
	}

	// MARK: - notesHolderIndexFromMeasureIndex(_: Int) -> (Int, Int?)

	// MARK: Failures

	func testNotesHolderIndexForOutOfRangeMeasureIndex() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			_ = try staff.notesHolderIndexFromMeasureIndex(20)
		}
	}

	// MARK: Successes

	func testNotesHolderIndexForNoRepeats() {
		assertNoErrorThrown {
			let indexes = try staff.notesHolderIndexFromMeasureIndex(2)
			XCTAssertEqual(indexes.notesHolderIndex, 2)
			XCTAssertNil(indexes.repeatMeasureIndex)
		}
	}

	func testNotesHolderIndexForOriginalRepeatedMeasure() {
		assertNoErrorThrown {
			let indexes = try staff.notesHolderIndexFromMeasureIndex(8)
			XCTAssertEqual(indexes.notesHolderIndex, 6)
			XCTAssertEqual(indexes.repeatMeasureIndex, 1)
		}
	}

	func testNotesHolderIndexForRepeatedMeasure() {
		assertNoErrorThrown {
			let indexes = try staff.notesHolderIndexFromMeasureIndex(9)
			XCTAssertEqual(indexes.notesHolderIndex, 6)
			XCTAssertEqual(indexes.repeatMeasureIndex, 2)
		}
	}

	func testNotesHolderIndexForAfterRepeat() {
		assertNoErrorThrown {
			let indexes = try staff.notesHolderIndexFromMeasureIndex(13)
			XCTAssertEqual(indexes.notesHolderIndex, 7)
			XCTAssertNil(indexes.repeatMeasureIndex)
		}
	}

	// MARK: - notesHolderAtMeasureIndex(_: Int) -> NotesHolder

	// MARK: Failures

	func testNotesHolderAtMeasureIndexForInvalidIndexNegative() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			_ = try staff.notesHolderAtMeasureIndex(-3)
		}
	}

	func testNotesHolderAtMeasureIndexForInvalidIndexTooLarge() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			_ = try staff.notesHolderAtMeasureIndex(99)
		}
	}

	// MARK: Successes

	func testNotesHolderAtMeasureIndexForFirstMeasureThatIsRepeated() {
		assertNoErrorThrown {
			let actual = try staff.notesHolderAtMeasureIndex(5)
			let expected = staff.notesHolders[5]
			XCTAssertEqual(actual as? MeasureRepeat, expected as? MeasureRepeat)
		}
	}

	func testNotesHolderAtMeasureIndexForSecondMeasureThatIsRepeated() {
		assertNoErrorThrown {
			let actual = try staff.notesHolderAtMeasureIndex(8)
			let expected = staff.notesHolders[6]
			XCTAssertEqual(actual as? MeasureRepeat, expected as? MeasureRepeat)
		}
	}

	func testNotesHolderAtMeasureIndexForRepeatedMeasureInFirstRepeat() {
		assertNoErrorThrown {
			let actual = try staff.notesHolderAtMeasureIndex(6)
			let expected = staff.notesHolders[5]
			XCTAssertEqual(actual as? MeasureRepeat, expected as? MeasureRepeat)
		}
	}

	func testNotesHolderAtMeasureIndexForRepeatedMeasureInSecondRepeat() {
		assertNoErrorThrown {
			let actual = try staff.notesHolderAtMeasureIndex(12)
			let expected = staff.notesHolders[6]
			XCTAssertEqual(actual as? MeasureRepeat, expected as? MeasureRepeat)
		}
	}

	func testNotesHolderAtMeasureIndexForRegularMeasure() {
		assertNoErrorThrown {
			let actual = try staff.notesHolderAtMeasureIndex(0)
			let expected = staff.notesHolders[0]
			XCTAssertEqual(actual as? Measure, expected as? Measure)
		}
	}

	// MARK: - measure(at:_: Int) -> ImmutableMeasure

	// MARK: Failures

	func testMeasureAtIndexForInvalidIndexNegative() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			_ = try staff.measure(at: -1)
		}
	}

	func testMeasureAtIndexForInvalidIndexTooLarge() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			_ = try staff.measure(at: staff.notesHolders.count + 10)
		}
	}

	// MARK: Successes

	func testMeasureAtIndexForRegularMeasure() {
		assertNoErrorThrown {
			let measure = try staff.measure(at: 1)
			XCTAssertEqual(measure as? Measure, staff.notesHolders[1] as? Measure)
		}
	}

	func testMeasureAtIndexForMeasureThatRepeats() {
		assertNoErrorThrown {
			let measureThatRepeats = try staff.measure(at: 5)
			let measureRepeat = staff.notesHolders[5] as! MeasureRepeat
			XCTAssertEqual(measureThatRepeats as? RepeatedMeasure, measureRepeat.expand()[0] as? RepeatedMeasure)
		}
	}

	func testMeasureAtIndexForRepeatedMeasure() {
		assertNoErrorThrown {
			let repeatedMeasure = try staff.measure(at: 6)
			let measureRepeat = staff.notesHolders[5] as! MeasureRepeat
			let expectedMeasure = measureRepeat.expand()[1]
			XCTAssertNotNil(expectedMeasure as? RepeatedMeasure)
			XCTAssertEqual(repeatedMeasure as? RepeatedMeasure, expectedMeasure as? RepeatedMeasure)
		}
	}

	// MARK: - measureRepeat(at:_: Int) -> MeasureRepeat

	// MARK: Failures

	func testMeasureRepeatAtIndexForInvalidIndexNegative() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			_ = try staff.measureRepeat(at: -1)
		}
	}

	func testMeasureRepeatAtIndexForInvalidIndexTooLarge() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			_ = try staff.measureRepeat(at: staff.notesHolders.count + 10)
		}
	}

	// MARK: Successes

	func testMeasureRepeatAtIndexForMeasureNotPartOfRepeat() {
		assertNoErrorThrown {
			let measureRepeat = try staff.measureRepeat(at: 1)
			XCTAssertNil(measureRepeat)
		}
	}

	func testMeasureRepeatAtIndexForFirstMeasureThatIsRepeated() {
		assertNoErrorThrown {
			let measureRepeat = try staff.measureRepeat(at: 5)
			let expected = staff.notesHolders[5] as! MeasureRepeat
			XCTAssertEqual(measureRepeat, expected)
		}
	}

	func testMeasureRepeatAtIndexForSecondMeasureThatIsRepeated() {
		assertNoErrorThrown {
			let measureRepeat = try staff.measureRepeat(at: 8)
			let expected = staff.notesHolders[6] as! MeasureRepeat
			XCTAssertEqual(measureRepeat, expected)
		}
	}

	func testMeasureRepeatAtIndexForRepeatedMeasureInFirstRepeat() {
		assertNoErrorThrown {
			let measureRepeat = try staff.measureRepeat(at: 6)
			let expected = staff.notesHolders[5] as! MeasureRepeat
			XCTAssertEqual(measureRepeat, expected)
		}
	}

	func testMeasureRepeatAtIndexForRepeatedMeasureInSecondRepeat() {
		assertNoErrorThrown {
			let measureRepeat = try staff.measureRepeat(at: 12)
			let expected = staff.notesHolders[6] as! MeasureRepeat
			XCTAssertEqual(measureRepeat, expected)
		}
	}

	// MARK: - replaceMeasure(at:, with:)

	// MARK: Failures

	func testReplaceRepeatedMeasure() {
		assertThrowsError(StaffError.repeatedMeasureCannotBeModified) {
			try staff.replaceMeasure(at: 6, with: measure1)
		}
	}

	// MARK: Successes

	func testReplaceMeasureAtIndex() {
		assertNoErrorThrown {
			try staff.replaceMeasure(at: 0, with: measure2)
			let replacedMeasure = Measure(try staff.measure(at: 0))
			XCTAssertEqual(replacedMeasure, changedClef(of: measure2))
		}
	}

	func testReplaceMeasureWithRepeat() {
		assertNoErrorThrown {
			try staff.replaceMeasure(at: 5, with: measure1)
			let replacedMeasure = Measure(try staff.measure(at: 5))
			let repeatedMeasure = Measure(try staff.measure(at: 6))
			XCTAssertEqual(replacedMeasure, changedClef(of: measure1))
			XCTAssertEqual(repeatedMeasure, changedClef(of: measure1))
		}
	}

	// MARK: - changeClef(_:, in:, at:, inSet:)

	// MARK: Failures

	func testChangeClefInvalidMeasureIndex() {
		assertThrowsError(StaffError.measureIndexOutOfRange) {
			try staff.changeClef(.bass, in: 17, atNote: 0, inSet: 0)
		}
	}

	func testChangeClefRepeatedMeasure() {
		assertThrowsError(StaffError.repeatedMeasureCannotBeModified) {
			try staff.changeClef(.bass, in: 6, atNote: 0, inSet: 0)
		}
	}

	// MARK: Successes

	func testChangeClefAtBeginningOfMeasure() {
		assertNoErrorThrown {
			try verifyAndChangeClef(to: .bass, in: 2, atNote: 0)
		}
	}

	func testChangeClefAtBeginningOfStaff() {
		assertNoErrorThrown {
			try verifyAndChangeClef(to: .alto, in: 0, atNote: 0)
		}
	}

	func testChangeClefAtMiddleOfMeasure() {
		assertNoErrorThrown {
			try verifyAndChangeClef(to: .baritone, in: 3, atNote: 2)
		}
	}

	func testChangeClefTwiceInOneMeasure() {
		assertNoErrorThrown {
			let newClef1: Clef = .bass
			let newClef2: Clef = .alto

			try staff.changeClef(newClef1, in: 1, atNote: 1)
			try staff.changeClef(newClef2, in: 1, atNote: 2)

			try verifyClefsUnchanged(before: 1)
			try verifyClefsChanged(to: newClef2, after: 1)
		}
	}

	func testChangeClefTwiceAcross2Measures() {
		assertNoErrorThrown {
			let newClef1: Clef = .tenor
			let newClef2: Clef = .bass

			try staff.changeClef(newClef1, in: 2, atNote: 0)
			try staff.changeClef(newClef2, in: 4, atNote: 0)

			try verifyClefsUnchanged(before: 2)
			try verifyClefsChanged(to: newClef1, after: 2, until: 4)
			try verifyClefsChanged(to: newClef2, after: 4)
		}
	}

	func testChangeClefTwiceAcross2NoteSetsIn1Measure() {
		assertNoErrorThrown {
			let sixteenth = Note(noteDuration: .sixteenth,
								 pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
			let quarter = Note(noteDuration: .quarter,
							   pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
			staff.appendMeasure(
				Measure(timeSignature: TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120),
						notes: [
							[
								sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth,
							],
							[
								quarter, quarter, quarter, quarter,
							],
						])
			)

			let newLastMeasureIndex = 17
			let newClef1: Clef = .bass
			let newClef2 = Clef(
				pitch: SpelledPitch(noteLetter: .c, accidental: .sharp, octave: .octave3),
				location: StaffLocation(type: .space, number: 3)
			)
			try staff.changeClef(newClef1, in: newLastMeasureIndex, atNote: 1, inSet: 0)
			try staff.changeClef(newClef2, in: newLastMeasureIndex, atNote: 2, inSet: 1)
			let measure = Measure(try staff.measure(at: newLastMeasureIndex))
			try verifyClefsUnchanged(before: newLastMeasureIndex)
			XCTAssertNotNil(measure.lastClef)
			XCTAssertEqual(measure.lastClef, newClef2)
			let firstChangeTicks = try measure.cumulativeTicks(at: 1, inSet: 0)
			let secondChangeTicks = try measure.cumulativeTicks(at: 2, inSet: 1)
			XCTAssertEqual(measure.clefs, [firstChangeTicks: newClef1, secondChangeTicks: newClef2])
		}
	}

	func testChangeClefAtBeginningOfFirstMeasureWithinRepeat() {
		assertNoErrorThrown {
			let newClef: Clef = .bass
			try staff.changeClef(newClef, in: 5, atNote: 0, inSet: 0)
			try verifyClefsUnchanged(before: 5)
			try verifyClefsChanged(to: newClef, after: 6)
			let immutableMeasure1 = try staff.measure(at: 5)
			let immutableMeasure2 = try staff.measure(at: 6)
			XCTAssertEqual(immutableMeasure1.lastClef, .bass)
			XCTAssertEqual(immutableMeasure2.lastClef, .bass)
			XCTAssertEqual(immutableMeasure1.clefs, [0: .bass])
			XCTAssertEqual(immutableMeasure2.clefs, [0: .bass])
		}
	}

	func testChangeClefInMeasureRepeatWith1Measure() {
		assertNoErrorThrown {
			let newClef: Clef = .bass
			try staff.changeClef(newClef, in: 5, atNote: 1, inSet: 0)
			try verifyClefsUnchanged(before: 5)
			try verifyClefsChanged(to: newClef, after: 6)
			let immutableMeasure1 = try staff.measure(at: 5)
			let immutableMeasure2 = try staff.measure(at: 6)
			let ticks = try Measure(immutableMeasure1).cumulativeTicks(at: 1)
			XCTAssertEqual(immutableMeasure1.lastClef, newClef)
			XCTAssertEqual(immutableMeasure2.lastClef, newClef)
			XCTAssertEqual(immutableMeasure1.clefs, [ticks: newClef])
			XCTAssertEqual(immutableMeasure2.clefs, [ticks: newClef])
		}
	}

	func testChangeClefInEachMeasureInRepeat() {
		assertNoErrorThrown {
			let newClef1: Clef = .bass
			let newClef2: Clef = .alto
			try staff.changeClef(newClef1, in: 7, atNote: 0, inSet: 0)
			try staff.changeClef(newClef2, in: 8, atNote: 1, inSet: 0)
			try verifyClefsUnchanged(before: 7)
			try verifyClefsChanged(to: newClef2, after: 12)
			let firstChangeMeasures = [try staff.measure(at: 7), try staff.measure(at: 9), try staff.measure(at: 11)]
			let secondChangeMeasures = [try staff.measure(at: 8), try staff.measure(at: 10), try staff.measure(at: 12)]
			let secondChangeTicks = try Measure(secondChangeMeasures[0]).cumulativeTicks(at: 1)
			firstChangeMeasures.forEach {
				XCTAssertEqual($0.lastClef, newClef1)
				XCTAssertEqual($0.clefs, [0: newClef1])
			}
			secondChangeMeasures.forEach {
				XCTAssertEqual($0.lastClef, newClef2)
				XCTAssertEqual($0.clefs, [secondChangeTicks: newClef2])
			}
		}
	}

	private func verifyAndChangeClef(to clef: Clef,
									 in measureIndex: Int,
									 atNote noteIndex: Int,
									 inSet setIndex: Int = 0,
									 inFile file: StaticString = #file,
									 atLine line: UInt = #line) throws {
		let newClef: Clef = .bass
		try staff.changeClef(newClef, in: measureIndex, atNote: noteIndex, inSet: setIndex)
		try verifyClefsUnchanged(before: measureIndex)
		try verifyClefsChanged(to: newClef, after: measureIndex)
	}

	private func verifyClefsUnchanged(before measureIndex: Int,
									  file: StaticString = #file,
									  line: UInt = #line) throws {
		let notesHolderIndexPrevious = try? staff.notesHolderIndexFromMeasureIndex(measureIndex - 1)
		if let notesHolderIndexPrevious = notesHolderIndexPrevious {
			staff[0 ..< notesHolderIndexPrevious.notesHolderIndex].forEach { notesHolder in
				switch notesHolder {
				case let measure as Measure:
					XCTAssertEqual(measure.lastClef, Constant.standardClef, file: file, line: line)
					XCTAssertEqual(measure.originalClef, Constant.standardClef, file: file, line: line)
				case let measureRepeat as MeasureRepeat:
					measureRepeat.expand().forEach {
						XCTAssertEqual($0.lastClef, Constant.standardClef, file: file, line: line)
						XCTAssertEqual($0.originalClef, Constant.standardClef, file: file, line: line)
					}
				default: XCTFail("Invalid type. Should be Measure or MeasureRepeat")
				}
			}
		}
	}

	/**
	 - parameter endingIndex: if it is not specified, it will check to the end.
	     Otherwise, it will check everything up to, but not including the measure at this index.
	 */
	private func verifyClefsChanged(to newClef: Clef,
									after measureIndex: Int,
									until endingIndex: Int? = nil,
									file: StaticString = #file,
									line: UInt = #line) throws {
		let notesHolderIndexNext = try? staff.notesHolderIndexFromMeasureIndex(measureIndex + 1)
		if let notesHolderIndexNext = notesHolderIndexNext {
			staff[notesHolderIndexNext.notesHolderIndex ..< (endingIndex ?? staff.endIndex)].forEach { notesHolder in
				switch notesHolder {
				case let measure as Measure:
					XCTAssertEqual(measure.lastClef, newClef, file: file, line: line)
					XCTAssertEqual(measure.originalClef, newClef, file: file, line: line)
				case let measureRepeat as MeasureRepeat:
					measureRepeat.expand().forEach {
						XCTAssertEqual($0.lastClef, newClef, file: file, line: line)
						XCTAssertEqual($0.originalClef, newClef, file: file, line: line)
					}
				default: XCTFail("Invalid type. Should be Measure or MeasureRepeat")
				}
			}
		}
	}

	// MARK: - Collection Conformance

	func testMap() {
		let mappedNotesHolders: [NotesHolder] = staff.map { $0 }
		let expectedNotesHolders: [NotesHolder] = [
			changedClef(of: measure1),
			changedClef(of: measure2),
			changedClef(of: measure3),
			changedClef(of: measure4),
			changedClef(of: measure5),
			changedClef(ofAllMeasuresInRepeat: repeat1),
			changedClef(ofAllMeasuresInRepeat: repeat2),
			changedClef(of: measure6),
			changedClef(of: measure3),
			changedClef(of: measure7),
			changedClef(of: measure8),
		]
		var count = 0
		zip(mappedNotesHolders, expectedNotesHolders).forEach { actualNotesHolder, expectedNotesHolder in
			switch (actualNotesHolder, expectedNotesHolder) {
			case let (actual as Measure, expected as Measure):
				XCTAssertEqual(actual, expected)
			case let (actual as MeasureRepeat, expected as MeasureRepeat):
				XCTAssertEqual(actual, expected)
			default:
				XCTFail("NotesHolders not equal")
			}
			count += 1
		}
		XCTAssertEqual(count, expectedNotesHolders.count)
	}

	func testReversed() {
		let reversedNotesHolders = staff.reversed()
		let expectedNotesHolders: [NotesHolder] = [
			changedClef(of: measure1),
			changedClef(of: measure2),
			changedClef(of: measure3),
			changedClef(of: measure4),
			changedClef(of: measure5),
			changedClef(ofAllMeasuresInRepeat: repeat1),
			changedClef(ofAllMeasuresInRepeat: repeat2),
			changedClef(of: measure6),
			changedClef(of: measure3),
			changedClef(of: measure7),
			changedClef(of: measure8),
		].reversed()
		var count = 0
		zip(reversedNotesHolders, expectedNotesHolders).forEach { actualNotesHolder, expectedNotesHolder in
			switch (actualNotesHolder, expectedNotesHolder) {
			case let (actual as Measure, expected as Measure):
				XCTAssertEqual(actual, expected)
			case let (actual as MeasureRepeat, expected as MeasureRepeat):
				XCTAssertEqual(actual, expected)
			default:
				XCTFail("NotesHolders not equal")
			}
			count += 1
		}
		XCTAssertEqual(count, expectedNotesHolders.count)
	}

	func testIterator() {
		var iterator = staff.makeIterator()
		if let actual = iterator.next() as? Measure {
			XCTAssertEqual(actual, changedClef(of: measure1))
		} else {
			XCTFail("Iterator didn't return correct value for next()")
		}
	}

	private func changedClef(of measure: Measure, toClef clef: Clef = Constant.standardClef) -> Measure {
		var mutatingMeasure = measure
		_ = mutatingMeasure.changeFirstClefIfNeeded(to: clef)
		return mutatingMeasure
	}

	private func changedClef(ofAllMeasuresInRepeat measureRepeat: MeasureRepeat,
							 toClef clef: Clef = Constant.standardClef) -> MeasureRepeat {
		let newMeasures = measureRepeat.measures.map { (measure: Measure) -> Measure in
			var measureCopy = measure
			_ = measureCopy.changeFirstClefIfNeeded(to: clef)
			return measureCopy
		}
		var newRepeat = measureRepeat
		newRepeat.measures = newMeasures
		return newRepeat
	}
}
