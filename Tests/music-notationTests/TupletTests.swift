//
//  TupletTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 6/19/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCoreMac
import XCTest

class TupletTests: XCTestCase {
	let pitch1 = SpelledPitch(noteLetter: .a, octave: .octave1)
	let pitch2 = SpelledPitch(noteLetter: .b, accidental: .sharp, octave: .octave1)
	let pitch3 = SpelledPitch(noteLetter: .d, accidental: .natural, octave: .octave1)
	let quarterRest = Note(restDuration: .quarter)
	let eighthRest = Note(restDuration: .eighth)
	let dottedQuarterNote = Note(noteDuration: try! NoteDuration(value: .quarter, dotCount: 1),
								 pitch: SpelledPitch(noteLetter: .c, octave: .octave3))
	var quarterNote1: Note!
	var quarterNote2: Note!
	var quarterNote3: Note!
	var eighthNote: Note!
	var quarterChord: Note!
	var eighthChord: Note!
	var sixteenthNote: Note!

	override func setUp() {
		super.setUp()
		quarterNote1 = Note(noteDuration: .quarter, pitch: pitch1)
		quarterNote2 = Note(noteDuration: .quarter, pitch: pitch1)
		quarterNote3 = Note(noteDuration: .quarter, pitch: pitch2)
		eighthNote = Note(noteDuration: .eighth, pitch: pitch1)
		quarterChord = Note(noteDuration: .quarter, pitches: [pitch1, pitch2, pitch3])
		eighthChord = Note(noteDuration: .eighth, pitches: [pitch1, pitch2, pitch3])
		sixteenthNote = Note(noteDuration: .sixteenth, pitch: pitch1)
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	// MARK: - init(notes:)

	// MARK: Failures

	func testInitFailForCountLessThan2() {
		assertThrowsError(TupletError.countMustBeLargerThan1) {
			_ = try Tuplet(1, .quarter, notes: [quarterNote1])
		}
	}

	func testInitFailForOddCountNoBaseCount() {
		// count specified is something not in 2-9 range and no base count specified
		assertThrowsError(TupletError.countHasNoStandardRatio) {
			_ = try Tuplet(
				10,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
				]
			)
		}
	}

	func testInitFailForEmptyNotes() {
		// standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(3, .eighth, notes: [])
		}

		// non-standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(11, .eighth, inSpaceOf: 9, notes: [])
		}
	}

	func testInitFailForNotesSameDurationNotEnough() {
		// standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2])
		}

		// non-standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(11, .quarter, inSpaceOf: 9, notes: [quarterNote1, quarterNote2, quarterNote3])
		}
	}

	func testInitFailForNotesSameDurationTooMany() {
		// standard ratio
		assertThrowsError(TupletError.notesOverfillTuplet) {
			_ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1])
		}

		// non-standard ratio
		assertThrowsError(TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				5,
				.quarter,
				inSpaceOf: 2,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
				]
			)
		}
	}

	func testInitFailForNotesShorterNotEnough() {
		// standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(4, .quarter, notes: [eighthNote, eighthNote, quarterNote1])
		}

		// non-standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(
				5,
				.quarter,
				inSpaceOf: 3,
				notes: [
					eighthNote, eighthNote,
					eighthNote, eighthNote,
					quarterNote3,
				]
			)
		}
	}

	func testInitFailForShorterTooMany() {
		// standard ratio
		assertThrowsError(TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				4,
				.quarter,
				notes: [
					eighthNote, eighthNote, eighthNote, eighthNote, quarterNote1, quarterNote2, quarterNote3,
				]
			)
		}

		// non-standard ratio
		assertThrowsError(TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				5,
				.quarter,
				inSpaceOf: 2,
				notes: [
					quarterNote1, quarterNote2, quarterNote3,
					eighthNote, eighthNote, quarterNote1, eighthNote,
				]
			)
		}
	}

	func testInitFailForLongerNotEnough() {
		// standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(4, .eighth, notes: [quarterNote1, eighthNote])
		}

		// non-standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(11, .eighth, inSpaceOf: 9, notes: [eighthNote, eighthNote, quarterNote1])
		}
	}

	func testInitFailForLongerTooMany() {
		// standard ratio
		assertThrowsError(TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				5,
				.eighth,
				notes: [
					eighthNote, quarterNote1, eighthNote, quarterNote2,
				]
			)
		}

		// non-standard ratio
		assertThrowsError(TupletError.notesOverfillTuplet) {
			_ = try Tuplet(
				5,
				.eighth,
				inSpaceOf: 2,
				notes: [
					eighthNote, quarterNote1, eighthNote, quarterNote2,
				]
			)
		}
	}

	func testInitFailForSameDurationWithRestsNotEnough() {
		// standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterRest])
		}

		// non-standard ratio
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			_ = try Tuplet(11, .quarter, inSpaceOf: 9, notes: [quarterNote1, quarterRest, quarterNote3])
		}
	}

	func testInitFailForCompoundTupletTooLarge() {
		assertThrowsError(TupletError.notesOverfillTuplet) {
			// This is worth 4 quarter notes
			let quintuplet = try? Tuplet(
				5,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
				]
			)
			XCTAssertNotNil(quintuplet)
			// 8 quarter notes long instead of 7
			_ = try Tuplet(
				7,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1,
					quintuplet!,
				]
			)
		}
	}

	func testInitFailForCompoundTupletTooSmall() {
		assertThrowsError(TupletError.notesDoNotFillTuplet) {
			let triplet = try? Tuplet(
				3,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3,
				]
			)
			XCTAssertNotNil(triplet)
			_ = try Tuplet(
				7,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3,
					triplet!,
				]
			)
		}
	}

	// MARK: Successes

	func testInitSuccessForAllStandardCombinations() {
		assertNoErrorThrown {
			// Test 2 - 9
			_ = try Tuplet(
				2,
				.quarter,
				notes: [
					quarterNote1, quarterNote2,
				]
			)
			_ = try Tuplet(
				3,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3,
				]
			)
			_ = try Tuplet(
				4,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1,
				]
			)
			_ = try Tuplet(
				5,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2,
				]
			)
			_ = try Tuplet(
				6,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3,
				]
			)
			_ = try Tuplet(
				7,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
				]
			)
			_ = try Tuplet(
				8,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
					quarterNote2,
				]
			)
			_ = try Tuplet(
				9,
				.quarter,
				notes: [
					quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2, quarterNote3, quarterNote1,
					quarterNote2, quarterNote3,
				]
			)
			// Test with a chord
			_ = try Tuplet(
				2,
				.quarter,
				notes: [
					quarterNote1, quarterChord,
				]
			)
		}
	}

	func testInitSuccessForStandardMixedDurations() {
		assertNoErrorThrown {
			_ = try Tuplet(
				5,
				.quarter,
				notes: [
					quarterNote1, eighthNote, eighthNote, quarterNote2, quarterNote3, eighthNote, eighthNote,
				]
			)
		}
	}

	func testInitSuccessForStandardDottedBase() {
		assertNoErrorThrown {
			let baseDuration = try? NoteDuration(value: .quarter, dotCount: 1)
			XCTAssertNotNil(baseDuration)
			_ = try Tuplet(
				3,
				baseDuration!,
				notes: [
					dottedQuarterNote, dottedQuarterNote, dottedQuarterNote,
				]
			)
		}
	}

	func testInitSuccessForStandardDottedBaseMixedDuration() {
		assertNoErrorThrown {
			let baseDuration = try? NoteDuration(value: .quarter, dotCount: 1)
			XCTAssertNotNil(baseDuration)
			_ = try Tuplet(
				3,
				baseDuration!,
				notes: [
					dottedQuarterNote, quarterNote1, eighthNote, dottedQuarterNote,
				]
			)
		}
	}

	func testInitSuccessForStandardCompound() {
		assertNoErrorThrown {
			let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			XCTAssertNotNil(triplet)
			_ = try Tuplet(
				5,
				.eighth,
				notes: [
					triplet!, eighthNote, eighthNote, eighthNote,
				]
			)
		}
	}

	func testInitSuccessForStandardWithRests() {
		assertNoErrorThrown {
			_ = try Tuplet(3, .quarter, notes: [quarterNote1, quarterRest, quarterNote3])
		}
	}

	func testInitSuccessForNonStandardSameDuration() {
		assertNoErrorThrown {
			_ = try Tuplet(
				7,
				.eighth,
				inSpaceOf: 6,
				notes: [
					eighthNote, eighthNote, eighthNote, eighthNote,
					eighthNote, eighthNote, eighthNote,
				]
			)
		}
	}

	func testInitSuccessForNonStandardDottedBase() {
		assertNoErrorThrown {
			_ = try Tuplet(
				4,
				NoteDuration(value: .quarter, dotCount: 1),
				inSpaceOf: 2,
				notes: [
					dottedQuarterNote, dottedQuarterNote, dottedQuarterNote, dottedQuarterNote,
				]
			)
		}
	}

	func testInitSuccessForNonStandardCompound() {
		assertNoErrorThrown {
			// Space of 4 eighth notes
			let quintuplet = try? Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
			XCTAssertNotNil(quintuplet)
			_ = try Tuplet(
				11,
				.eighth,
				inSpaceOf: 9,
				notes: [
					quintuplet!, eighthNote, eighthNote, eighthNote,
					eighthNote, eighthNote, eighthNote, eighthNote,
				]
			)
		}
	}

	func testInitSuccessForNonStandardNestedCompound() {
		assertNoErrorThrown {
			// Space of 4 eighth notes
			let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			XCTAssertNotNil(triplet)
			let quintuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, triplet!])
			XCTAssertNotNil(quintuplet)
			_ = try Tuplet(
				11,
				.eighth,
				inSpaceOf: 9,
				notes: [
					quintuplet, eighthNote, eighthNote, eighthNote,
					eighthNote, eighthNote, eighthNote, eighthNote,
				]
			)
		}
	}

	func testInitSuccessForNonStandardWithRests() {
		assertNoErrorThrown {
			_ = try Tuplet(
				7,
				.quarter,
				inSpaceOf: 6,
				notes: [
					quarterNote1, quarterNote2, quarterRest, quarterNote3,
					quarterRest, quarterRest, quarterNote1,
				]
			)
		}
	}

	// MARK: - note(at:)

	// MARK: Failures

	func testNoteAtForInvalidIndexNegative() {
		assertThrowsError(TupletError.invalidIndex) {
			let tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			_ = try tuplet.note(at: -1)
		}
	}

	func testNoteAtForInvalidIndexTooLarge() {
		assertThrowsError(TupletError.invalidIndex) {
			let tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			_ = try tuplet.note(at: 5)
		}
	}

	// MARK: Successes

	func testNoteAtSuccess() {
		assertNoErrorThrown {
			let tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthRest, eighthNote, eighthNote])
			let note = try tuplet.note(at: 2)
			XCTAssertEqual(note, eighthRest)
		}
	}

	// MARK: - replaceNote<T: NoteCollection>(at:with:T)

	// MARK: Failures

	func testReplaceNoteWithNoteTooLong() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNote(at: 1, with: quarterNote1)
		}
	}

	func testReplaceNoteWithNoteTooShort() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: eighthNote)
		}
	}

	func testReplaceNoteInTupletWithNoteTooShort() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try? Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			XCTAssertNotNil(triplet)
			var tuplet = try Tuplet(5, .quarter, notes: [
				triplet!, quarterNote1, quarterNote2, quarterNote3,
			])
			try tuplet.replaceNote(at: 1, with: eighthNote)
		}
	}

	func testReplaceNoteInTupletWithNoteTooLong() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			XCTAssertNotNil(triplet)
			var tuplet = try Tuplet(5, .eighth, notes: [
				triplet!, eighthNote, eighthNote, eighthNote,
			])
			try tuplet.replaceNote(at: 1, with: quarterNote1)
		}
	}

	func testReplaceNoteWithTupletTooLong() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNote(at: 0, with: triplet)
		}
	}

	// MARK: Successes

	func testReplaceNoteWithRestOfSameDuration() {
		assertNoErrorThrown {
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: quarterRest)
			XCTAssertEqual(try tuplet.note(at: 0), quarterRest)
			XCTAssertEqual(try tuplet.note(at: 1), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 2), quarterNote3)
		}
	}

	func testReplaceNoteInTupletWithRestOfSameDuration() {
		assertNoErrorThrown {
			let triplet = try? Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			XCTAssertNotNil(triplet)
			var tuplet = try Tuplet(5, .quarter, notes: [
				triplet!, quarterNote1, quarterNote2, quarterNote3,
			])
			try tuplet.replaceNote(at: 1, with: quarterRest)
			XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 1), quarterRest)
			XCTAssertEqual(try tuplet.note(at: 2), quarterNote3)
			XCTAssertEqual(try tuplet.note(at: 3), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 4), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 5), quarterNote3)
		}
	}

	func testReplaceNoteWithNoteOfSameDuration() {
		assertNoErrorThrown {
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: quarterNote3)
			XCTAssertEqual(try tuplet.note(at: 0), quarterNote3)
			XCTAssertEqual(try tuplet.note(at: 1), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 2), quarterNote3)
		}
	}

	func testReplaceNoteInTupletWithNoteOfSameDuration() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 1, with: quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 1), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 2), quarterNote3)
			XCTAssertEqual(try tuplet.note(at: 3), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 4), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 5), quarterNote3)
		}
	}

	func testReplaceNoteTieWithNoteOfSameDuration() {
		assertNoErrorThrown {
			var beginTieNote = eighthNote!
			beginTieNote.tie = .begin
			var beginAndEndTieNote = eighthNote!
			beginAndEndTieNote.tie = .beginAndEnd
			var endTieNote = eighthNote!
			endTieNote.tie = .end

			var tupletBegin = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, beginTieNote])
			try tupletBegin.replaceNote(at: 2, with: eighthNote)
			XCTAssertEqual(try tupletBegin.note(at: 2), beginTieNote)

			var tupletBeginAndEnd = try Tuplet(3, .eighth, notes: [eighthNote, beginTieNote, beginAndEndTieNote])
			try tupletBeginAndEnd.replaceNote(at: 2, with: eighthNote)
			XCTAssertEqual(try tupletBeginAndEnd.note(at: 2), beginAndEndTieNote)

			var tupletEnd = try Tuplet(3, .eighth, notes: [endTieNote, eighthNote, eighthNote])
			try tupletEnd.replaceNote(at: 0, with: eighthNote)
			XCTAssertEqual(try tupletEnd.note(at: 0), endTieNote)
		}
	}

	func testReplaceNoteTieWithTupletSameDuration() {
		assertNoErrorThrown {
			var beginTieNote = quarterNote1!
			beginTieNote.tie = .begin
			var endTieNote = quarterNote1!
			endTieNote.tie = .end

			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])

			var tupletBegin = try Tuplet(3, .quarter, notes: [quarterNote2, quarterNote2, beginTieNote])
			try tupletBegin.replaceNote(at: 2, with: triplet)
			var eighthNoteTieBegin = eighthNote!
			eighthNoteTieBegin.tie = .begin
			XCTAssertEqual(try tupletBegin.note(at: 2), eighthNote)
			XCTAssertEqual(try tupletBegin.note(at: 3), eighthNote)
			XCTAssertEqual(try tupletBegin.note(at: 4), eighthNoteTieBegin)

			var tupletEnd = try Tuplet(3, .quarter, notes: [endTieNote, quarterNote2, quarterNote2])
			try tupletEnd.replaceNote(at: 0, with: triplet)
			var eighthNoteTieEnd = eighthNote!
			eighthNoteTieEnd.tie = .end
			XCTAssertEqual(try tupletEnd.note(at: 0), eighthNoteTieEnd)
			XCTAssertEqual(try tupletEnd.note(at: 1), eighthNote)
			XCTAssertEqual(try tupletEnd.note(at: 2), eighthNote)
		}
	}

	func testReplaceNoteBeginAndEndTieWithTupletSameDuration() {
		assertNoErrorThrown {
			var beginTieNote = quarterNote1!
			beginTieNote.tie = .begin
			var beginAndEndTieNote = quarterNote1!
			beginAndEndTieNote.tie = .beginAndEnd

			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, beginTieNote, beginAndEndTieNote])
			try tuplet.replaceNote(at: 2, with: triplet)
		}
	}

	// MARK: - replaceNote<T: NoteCollection>(at:with:[T])

	// MARK: Failures

	func testReplaceNoteWithArrayOfNotesTooLong() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			var triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			try triplet.replaceNote(at: 1, with: [eighthNote, eighthNote, eighthNote])
		}
	}

	func testReplaceNoteWithArrayOfNotesTooShort() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			var triplet = try Tuplet(3,
									 NoteDuration(value: .quarter, dotCount: 1),
									 notes: [dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
			try triplet.replaceNote(at: 1, with: [eighthNote, eighthNote])
		}
	}

	func testReplaceNoteInTupletWithArrayOfNotesTooLong() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 2, with: [quarterNote1, quarterNote2])
		}
	}

	func testReplaceNoteInTupletWithArrayOfNotesTooShort() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: [eighthNote])
		}
	}

	func testReplaceNoteInTupletWithArrayOfTupletsTooLong() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [triplet, quarterNote1, quarterNote2, quarterNote3])
			let newTuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNote(at: 0, with: [newTuplet])
		}
	}

	func testReplaceNoteInTupletWithArrayOfTupletsTooShort() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3,
									 NoteDuration(value: .quarter, dotCount: 1),
									 notes: [dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
			var tuplet = try Tuplet(5,
									NoteDuration(value: .quarter, dotCount: 1),
									notes: [triplet, dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
			let newTuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNote(at: 0, with: [newTuplet])
		}
	}

	// MARK: Successes

	func testReplaceNoteWithArrayOfNotesSameDuration() {
		assertNoErrorThrown {
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: [eighthNote, eighthNote])
			XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 2), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 3), quarterNote3)
		}
	}

	func testReplaceNoteWithArrayOfRestsSameDuration() {
		assertNoErrorThrown {
			var tuplet = try Tuplet(3,
									NoteDuration(value: .quarter, dotCount: 1),
									notes: [dottedQuarterNote, dottedQuarterNote, dottedQuarterNote])
			try tuplet.replaceNote(at: 1, with: [eighthRest, eighthRest, eighthRest])
			XCTAssertEqual(try tuplet.note(at: 0), dottedQuarterNote)
			XCTAssertEqual(try tuplet.note(at: 1), eighthRest)
			XCTAssertEqual(try tuplet.note(at: 2), eighthRest)
			XCTAssertEqual(try tuplet.note(at: 3), eighthRest)
			XCTAssertEqual(try tuplet.note(at: 4), dottedQuarterNote)
		}
	}

	func testReplaceNoteInTupletWithArrayOfNotesSameDuration() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5, .quarter, notes: [quarterNote1, triplet, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 2, with: [eighthNote, eighthNote])
			XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 1), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 2), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 3), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 4), quarterNote3)
			XCTAssertEqual(try tuplet.note(at: 5), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 6), quarterNote3)
		}
	}

	func testReplaceNoteWithArrayOfTupletsSameDuration() {
		assertNoErrorThrown {
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			try tuplet.replaceNote(at: 1, with: [triplet, triplet])
			XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 1), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 2), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 3), sixteenthNote)

			XCTAssertEqual(try tuplet.note(at: 4), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 5), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 6), sixteenthNote)

			XCTAssertEqual(try tuplet.note(at: 7), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 8), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 9), quarterNote1)
		}
	}

	func testReplaceNoteBeginTieWithArrayOfNotesSameDuration() {
		assertNoErrorThrown {
			var beginNote = quarterNote1!
			beginNote.tie = .begin

			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote2, quarterNote3, beginNote])
			try tuplet.replaceNote(at: 2, with: [eighthNote, eighthNote])
			var eighthBegin = eighthNote!
			eighthBegin.tie = .begin
			XCTAssertEqual(try tuplet.note(at: 0), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 1), quarterNote3)
			XCTAssertEqual(try tuplet.note(at: 2), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 3), eighthBegin)
		}
	}

	func testReplaceNoteBeginTieWithArrayOfTupletsSameDuration() {
		assertNoErrorThrown {
			var beginNote = quarterNote1!
			beginNote.tie = .begin

			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, beginNote])
			try tuplet.replaceNote(at: 3, with: [triplet, triplet])
			var sixteenthBegin = sixteenthNote!
			sixteenthBegin.tie = .begin
			XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 2), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 3), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 4), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 5), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 6), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 7), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 8), sixteenthBegin)
		}
	}

	func testReplaceNoteEndTieWithArrayOfNotesSameDuration() {
		assertNoErrorThrown {
			var endNote = quarterNote1!
			endNote.tie = .end

			var tuplet = try Tuplet(3, .quarter, notes: [endNote, quarterNote2, quarterNote3])
			try tuplet.replaceNote(at: 0, with: [eighthNote, eighthNote])
			var eighthEnd = eighthNote!
			eighthEnd.tie = .end
			XCTAssertEqual(try tuplet.note(at: 0), eighthEnd)
			XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 2), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 3), quarterNote3)
		}
	}

	func testReplaceNoteEndTieWithArrayOfTupletsSameDuration() {
		assertNoErrorThrown {
			var endNote = quarterNote1!
			endNote.tie = .end

			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [endNote, eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNote(at: 0, with: [triplet, triplet])
			var sixteenthEnd = sixteenthNote!
			sixteenthEnd.tie = .end
			XCTAssertEqual(try tuplet.note(at: 0), sixteenthEnd)
			XCTAssertEqual(try tuplet.note(at: 1), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 2), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 3), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 4), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 5), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 6), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 7), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 8), eighthNote)
		}
	}

	func testReplaceNoteBeginAndEndTieWithArrayOfNotes() {
		assertNoErrorThrown {
			var beginAndEndNote = quarterNote1!
			beginAndEndNote.tie = .beginAndEnd
			var beginNote = quarterNote2!
			beginNote.tie = .begin

			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, beginNote, beginAndEndNote])
			try tuplet.replaceNote(at: 2, with: [eighthNote, eighthNote])
			var endEighth = eighthNote!
			endEighth.tie = .end
			var beginEighth = eighthNote!
			beginEighth.tie = .begin
			XCTAssertEqual(try tuplet.note(at: 0), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 1), beginNote)
			XCTAssertEqual(try tuplet.note(at: 2), endEighth)
			XCTAssertEqual(try tuplet.note(at: 3), beginEighth)
		}
	}

	// MARK: - replaceNotes<T: NoteCollection>(in:with:T)

	// MARK: Failures

	func testReplaceNotesWithNoteTooLarge() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(5,
									.sixteenth,
									notes: [sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote])
			try tuplet.replaceNotes(in: 1 ... 2,
									with: quarterNote1)
		}
	}

	func testReplaceNotesWithNoteTooShort() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, quarterNote2, quarterNote3, quarterNote1, quarterNote2])
			try tuplet.replaceNotes(in: 2 ... 3,
									with: eighthNote)
		}
	}

	func testReplaceNotesInTupletWithNoteTooLarge() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5,
									.sixteenth,
									notes: [sixteenthNote, triplet, sixteenthNote, sixteenthNote])
			try tuplet.replaceNotes(in: 1 ... 2,
									with: quarterNote1)
		}
	}

	func testReplaceNotesInTupletWithNoteTooShort() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, triplet, quarterNote2, quarterNote3])
			try tuplet.replaceNotes(in: 1 ... 2,
									with: sixteenthNote)
		}
	}

	func testReplaceNotesWithTupletTooLarge() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
			let replacementTuplet = try Tuplet(
				7,
				.quarter,
				notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1]
			)
			try tuplet.replaceNotes(in: 1 ... 2, with: replacementTuplet)
		}
	}

	func testReplaceNotesWithTupletTooShort() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1])
			let replacementTuplet = try Tuplet(3,
											   .quarter,
											   notes: [quarterNote1, quarterNote1, quarterNote1])
			try tuplet.replaceNotes(in: 1 ... 3, with: replacementTuplet)
		}
	}

	func testReplaceNotesInTupletWithTupletTooLarge() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote1, quarterNote1])
			var tuplet = try Tuplet(5,
									.quarter,
									notes: [quarterNote1, triplet, quarterNote1, quarterNote1])
			let replacementTuplet = try Tuplet(
				7,
				.quarter,
				notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1]
			)
			try tuplet.replaceNotes(in: 1 ... 2, with: replacementTuplet)
		}
	}

	func testReplaceNotesInTupletWithTupletTooShort() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			let nestedTuplet = try Tuplet(
				7,
				.quarter,
				notes: [quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1, quarterNote1]
			)
			var tuplet = try Tuplet(
				9,
				.quarter,
				notes: [quarterNote1, nestedTuplet, quarterNote1, quarterNote1, quarterNote1, quarterNote1]
			)
			let replacementTuplet = try Tuplet(
				3,
				.quarter,
				notes: [quarterNote1, quarterNote1, quarterNote1]
			)
			try tuplet.replaceNotes(in: 2 ... 5, with: replacementTuplet)
		}
	}

	func testReplaceNotesInMultipleTupletsNotCompletelyCoveredWithNoteSameDuration() {
		// If the note range to replace covers only part of a tuplet, it should fail.
		assertThrowsError(TupletError.rangeToReplaceMustFullyCoverMultipleTuplets) {
			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5, .sixteenth, notes: [sixteenthNote, triplet, triplet])
			try tuplet.replaceNotes(in: 1 ... 5, with: quarterNote1)
		}
	}

	func testReplaceNotesInMultipleTupletsNotCompletelyCoveredWithTupletSameDuration() {
		// If the note range to replace covers only part of a tuplet, it should fail.
		assertThrowsError(TupletError.rangeToReplaceMustFullyCoverMultipleTuplets) {
			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5, .sixteenth, notes: [sixteenthNote, triplet, triplet])
			let replacementTuplet = try Tuplet(
				5,
				.sixteenth,
				notes: [sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote, sixteenthNote]
			)
			try tuplet.replaceNotes(in: 1 ... 5, with: replacementTuplet)
		}
	}

	func testReplaceNotesWithFirstNoteBeginAndEndTieWithNoteSameDuration() {
		assertThrowsError(TupletError.invalidTieState) {
			var beginAndEnd = eighthNote!
			beginAndEnd.tie = .beginAndEnd
			var end = eighthNote!
			end.tie = .end
			var tuplet = try Tuplet(3, .eighth, notes: [beginAndEnd, end, eighthNote])
			try tuplet.replaceNotes(in: 0 ... 1, with: quarterNote1)
		}
	}

	func testReplaceNotesWithLastNoteBeginAndEndTieWithNoteSameDuration() {
		assertThrowsError(TupletError.invalidTieState) {
			var beginAndEnd = eighthNote!
			beginAndEnd.tie = .beginAndEnd
			var begin = eighthNote!
			begin.tie = .begin
			var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, begin, beginAndEnd])
			try tuplet.replaceNotes(in: 1 ... 2, with: quarterNote1)
		}
	}

	// MARK: Successes

	func testReplaceNotesWithNoteSameDuration() {
		assertNoErrorThrown {
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNotes(in: 2 ... 3, with: quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 2), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 3), eighthNote)
		}
	}

	func testReplaceNotesWithTupletSameDuration() {
		assertNoErrorThrown {
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote])
			let triplet = try Tuplet(3, .eighth, notes: [eighthChord, eighthNote, eighthRest])
			try tuplet.replaceNotes(in: 0 ... 1, with: triplet)
			XCTAssertEqual(try tuplet.note(at: 0), eighthChord)
			XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 2), eighthRest)
			XCTAssertEqual(try tuplet.note(at: 3), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 4), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 5), eighthNote)
		}
	}

	func testReplaceNotesFromTupletAndNonTupletWithNoteSameDuration() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, triplet, eighthNote])
			try tuplet.replaceNotes(in: 2 ... 5, with: dottedQuarterNote)
			XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 2), dottedQuarterNote)
		}
	}

	func testReplaceNotesFromTupletAndNonTupletWithTupletSameDuration() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, eighthNote, triplet, eighthNote])
			let quadruplet = try Tuplet(4, .eighth, notes: [eighthChord, eighthRest, eighthNote, eighthChord])
			try tuplet.replaceNotes(in: 2 ... 5, with: quadruplet)
			XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 2), eighthChord)
			XCTAssertEqual(try tuplet.note(at: 3), eighthRest)
			XCTAssertEqual(try tuplet.note(at: 4), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 5), eighthChord)
		}
	}

	func testReplaceNotesFrom2FullTupletsWithNoteSameDuration() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .sixteenth, notes: [sixteenthNote, sixteenthNote, sixteenthNote])
			var tuplet = try Tuplet(5, .sixteenth, notes: [sixteenthNote, triplet, triplet])
			try tuplet.replaceNotes(in: 1 ... 6, with: quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 0), sixteenthNote)
			XCTAssertEqual(try tuplet.note(at: 1), quarterNote1)
		}
	}

	func testReplaceNotesFrom2FullTupletsWithTupletSameDuration() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			var tuplet = try Tuplet(5, .eighth, notes: [eighthNote, triplet, triplet])
			let replacementTuplet = try Tuplet(5,
											   .eighth,
											   notes: [eighthChord, eighthNote, eighthRest, eighthNote, eighthChord])
			try tuplet.replaceNotes(in: 1 ... 6, with: replacementTuplet)
			XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 1), eighthChord)
			XCTAssertEqual(try tuplet.note(at: 2), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 3), eighthRest)
			XCTAssertEqual(try tuplet.note(at: 4), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 5), eighthChord)
		}
	}

	// MARK: - replaceNotes<T: NoteCollection>(in:with:[T])

	// replaceNotes<T: NoteCollection>(in:with:T) calls this method, so we will just do one sanity check for failure
	// and success. There is missing coverage of multi-nested tuplets, and that will be checked here too.

	// MARK: Failures

	func testReplaceNotesInTupletWithNotesTooLarge() {
		assertThrowsError(TupletError.replacementNotSameDuration) {
			var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNotes(in: 0 ... 1, with: [eighthNote, eighthNote, eighthNote])
		}
	}

	func testReplaceNotesInvalidRangeOutOfBounds() {
		assertThrowsError(TupletError.invalidIndex) {
			var tuplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNotes(in: 1 ... 4, with: [eighthNote, eighthNote, eighthNote, eighthNote])
		}
	}

	// MARK: Successes

	func testReplaceNotesInMultiNestedCompoundTupletWithNotesOfSameDuration() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			let quintuplet = try Tuplet(5, .eighth, notes: [triplet, triplet, eighthNote])
			var tuplet = try Tuplet(9, .eighth, notes: [triplet, quintuplet, eighthNote, eighthNote, eighthNote])
			try tuplet.replaceNotes(in: 6 ... 8, with: [eighthRest, eighthRest])
			XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 2), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 3), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 4), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 5), eighthNote)

			XCTAssertEqual(try tuplet.note(at: 6), eighthRest)
			XCTAssertEqual(try tuplet.note(at: 7), eighthRest)

			XCTAssertEqual(try tuplet.note(at: 8), eighthNote)

			XCTAssertEqual(try tuplet.note(at: 9), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 10), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 11), eighthNote)
		}
	}

	func testReplaceNotesWithinMultiNestedCompoundTupletAndNotesWithNotesOfSameDuration() {
		assertNoErrorThrown {
			// Create same compound tuplet as above test
			let triplet = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			let quintuplet = try Tuplet(5, .eighth, notes: [triplet, triplet, eighthNote])
			var tuplet = try Tuplet(9, .eighth, notes: [triplet, quintuplet, eighthNote, eighthNote, eighthNote])
			let notes: [Note] = [quarterNote1, quarterNote1, eighthRest]
			try tuplet.replaceNotes(in: 3 ... 10, with: notes)
			XCTAssertEqual(try tuplet.note(at: 0), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 1), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 2), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 3), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 4), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 5), eighthRest)
			XCTAssertEqual(try tuplet.note(at: 6), eighthNote)
			XCTAssertEqual(try tuplet.note(at: 7), eighthNote)
		}
	}

	func testReplaceNotesFromFirstToLastInTupletWithNotesOfSameDuration() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(3, .quarter, notes: [quarterNote1, triplet])
			try tuplet.replaceNotes(in: 0 ... 3, with: [quarterNote3, quarterNote2, quarterNote1])
			XCTAssertEqual(try tuplet.note(at: 0), quarterNote3)
			XCTAssertEqual(try tuplet.note(at: 1), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 2), quarterNote1)
		}
	}

	func testReplaceNotesFromFirstToSecondToLastInTupletWithNotesOfSameDuration() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			var tuplet = try Tuplet(5, .quarter, notes: [quarterNote1, triplet, quarterNote2, quarterNote3])
			try tuplet.replaceNotes(in: 0 ... 3, with: [quarterNote3, quarterNote2, quarterNote1])
			XCTAssertEqual(try tuplet.note(at: 0), quarterNote3)
			XCTAssertEqual(try tuplet.note(at: 1), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 2), quarterNote1)
			XCTAssertEqual(try tuplet.note(at: 3), quarterNote2)
			XCTAssertEqual(try tuplet.note(at: 4), quarterNote3)
		}
	}

	// MARK: - isCompound

	func testIsCompoundTrue() {
		assertNoErrorThrown {
			let triplet = try? Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			XCTAssertNotNil(triplet)
			let compound = try Tuplet(
				5,
				.eighth,
				notes: [
					triplet!, eighthNote, eighthNote, eighthNote,
				]
			)
			XCTAssertTrue(compound.isCompound)
		}
	}

	func testIsCompoundFalse() {
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			XCTAssertFalse(triplet.isCompound)
		}
	}

	// MARK: - ==(lhs:rhs:)

	// MARK: Failures

	func testEqualityDifferentNumberOfNotes() {
		assertNoErrorThrown {
			let tuplet1 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			let tuplet2 = try Tuplet(3, .eighth, notes: [quarterNote1, eighthNote])
			XCTAssertFalse(tuplet1 == tuplet2)
		}
	}

	func testEqualityDifferentNotes() {
		assertNoErrorThrown {
			let tuplet1 = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote2, quarterNote3])
			let tuplet2 = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote1, quarterNote1])
			XCTAssertFalse(tuplet1 == tuplet2)
		}
	}

	func testEqualitySameNotesDifferentTimingCount() {
		assertNoErrorThrown {
			let tuplet1 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			let tuplet2 = try Tuplet(3, .eighth, inSpaceOf: 1, notes: [eighthNote, eighthNote, eighthNote])
			XCTAssertFalse(tuplet1 == tuplet2)
		}
	}

	func testEqualityDifferentDuration() {
		assertNoErrorThrown {
			let tuplet1 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			let tuplet2 = try Tuplet(3, .quarter, notes: [quarterNote1, quarterNote1, quarterNote1])
			XCTAssertFalse(tuplet1 == tuplet2)
		}
	}

	// MARK: Success

	func testEqualityTrue() {
		assertNoErrorThrown {
			let tuplet1 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			let tuplet2 = try Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
			XCTAssertTrue(tuplet1 == tuplet2)
		}
	}
}
