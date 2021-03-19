//
//  MeasureTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 7/13/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCoreMac
import XCTest

class MeasureTests: XCTestCase {
	var measure: Measure!
	var timeSignature: TimeSignature!

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
		timeSignature = TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120)
		measure = Measure(
			timeSignature: timeSignature,
			key: Key(noteLetter: .c)
		)
	}

	override func tearDown() {
		super.tearDown()
		measure = nil
		timeSignature = nil
	}

	func testAddNote() {
		XCTAssertEqual(measure.notes[0].count, 0)
		measure.append(Note(noteDuration: .whole, pitch: SpelledPitch(noteLetter: .c, octave: .octave0)))
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .d, accidental: .sharp, octave: .octave0)))
		measure.append(Note(restDuration: .whole))
		XCTAssertEqual(measure.notes[0].count, 3)
	}

	// MARK: - replaceNotereplaceNote<T: NoteCollection>(at:with:T)

	// MARK: Failures

	// MARK: Successes

	func testReplaceNoteInTuplet() {
		let note = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let notes = [
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .sixteenth, notes: notes)
			measure.append(tuplet)
			measure.append(note)
			XCTAssertEqual(measure.noteCount[0], 4)
			// TODO: confirm that 1/4 actually fits in a 3,.sixteenth Tuplet.
			try measure.replaceNote(at: 1, with: note)
		}
	}

	func testReplaceNote() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .whole)
		let note2 = Note(restDuration: .eighth)
		measure.append(note1)
		measure.append(note2)
		assertNoErrorThrown {
			XCTAssertEqual(measure.noteCount[0], 2)
			try measure.replaceNote(at: 1, with: note1)
			let resultNote1 = try measure.note(at: 0, inSet: 0)
			let resultNote2 = try measure.note(at: 1, inSet: 0)
			XCTAssertEqual(resultNote1, note1)
			XCTAssertEqual(resultNote2, note1)
		}
	}

	// MARK: - replaceNote<T: NoteCollection>(at:with:[T])

	// MARK: Failures

	func testRepalceNoteWithInvalidNoteCollection() {
		measure.append(Note(restDuration: .whole))
		assertThrowsError(MeasureError.invalidNoteCollection) {
			try measure.replaceNote(at: 0, with: [Note]())
		}
	}

	// MARK: Successes

	func testReplaceNoteWithNotesPreservingTie() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .whole)
		let note2 = Note(restDuration: .eighth)
		measure.append(note1)
		measure.append(note2)
		assertNoErrorThrown {
			XCTAssertEqual(measure.noteCount[0], 2)

			try measure.modifyTie(at: 0, requestedTieState: .begin, inSet: 0)
			try measure.replaceNote(at: 0, with: [note2, note1])
			XCTAssertEqual(measure.noteCount[0], 3)

			var resultNote1 = try measure.note(at: 0, inSet: 0)
			var resultNote2 = try measure.note(at: 1, inSet: 0)

			XCTAssertEqual(resultNote1, note2)
			XCTAssertEqual(resultNote2.tie, .begin)

			// Clear tie result before compare
			resultNote2.tie = nil
			XCTAssertEqual(resultNote2, note1)

			// Note replace the note and index 1, which should
			// have a .beginAndEnd tie state.
			try measure.modifyTie(at: 0, requestedTieState: .begin, inSet: 0)
			try measure.replaceNote(at: 1, with: [note2])
			XCTAssertEqual(measure.noteCount[0], 3)

			resultNote1 = try measure.note(at: 1, inSet: 0)
			resultNote2 = try measure.note(at: 2, inSet: 0)
			XCTAssertEqual(resultNote1.tie, .beginAndEnd)
			XCTAssertEqual(resultNote2.tie, .end)

			// Now insert a couple of notes at the index containing
			// the .beginAndEnd tie. This should change the tie.
			try measure.replaceNote(at: 1, with: [note1, note2])
			XCTAssertEqual(measure.noteCount[0], 4)

			// Make sure we end up with 2 separate ties now.
			for i in [0, 2] {
				resultNote1 = try measure.note(at: i, inSet: 0)
				resultNote2 = try measure.note(at: i + 1, inSet: 0)
				XCTAssertEqual(resultNote1.tie, .begin)
				XCTAssertEqual(resultNote2.tie, .end)
			}
		}
	}

	func testReplaceNoteWithTupletPreservingTie() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note = Note(noteDuration: .whole,  pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let notes = [
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		measure.append(note)
		measure.append(note)
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .sixteenth, notes: notes)
			XCTAssertEqual(measure.noteCount[0], 2)
			try measure.startTie(at: 0, inSet: 0)

			try measure.replaceNote(at: 1, with: [tuplet])
			XCTAssertEqual(measure.noteCount[0], 4)

			var resultNote = try measure.note(at: 1, inSet: 0)

			XCTAssertEqual(resultNote.tie, .end)
			// Clear tie result before compare
			resultNote.tie = nil
			XCTAssertEqual(resultNote, notes[0])
		}
	}

	// MARK: - replaceNotes<T: NoteCollection>(in:with:T)

	// MARK: Failures

	func testReplaceNotesInRangeInvalidIndex() {
		let note = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let notes = [
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertThrowsError(MeasureError.tupletNotCompletelyCovered) {
			let tuplet = try Tuplet(3, .sixteenth, notes: notes)
			measure.append(tuplet)
			measure.append(note)
			XCTAssertEqual(measure.noteCount[0], 4)
			try measure.replaceNotes(in: 2 ... 3, with: note)
		}
	}

	// MARK: Successes

	func testReplaceNotes() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .whole)
		let note2 = Note(restDuration: .eighth)
		measure.append(note1)
		measure.append(note2)
		assertNoErrorThrown {
			XCTAssertEqual(measure.noteCount[0], 2)
			try measure.replaceNotes(in: 0 ... 1, with: note2)
			XCTAssertEqual(measure.noteCount[0], 1)
		}
	}

	// MARK: - replaceNotes<T: NoteCollection>(in:with:[T])

	// MARK: Failures

	func testReplaceNotesInRangeInvalidTie() {
		XCTAssertEqual(measure.notes[0].count, 0)
		var note1 = Note(restDuration: .whole)
		note1.tie = .beginAndEnd
		let note2 = Note(restDuration: .eighth)
		measure.append(note1)
		measure.append(note2)
		assertThrowsError(MeasureError.invalidTieState) {
			XCTAssertEqual(measure.noteCount[0], 2)
			try measure.replaceNotes(in: 0 ... 1, with: [note1, note2])
		}
	}

	func testReplaceNotesInRangeWithInvalidIndexRange() {
		let note = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let notes = [
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertThrowsError(MeasureError.tupletNotCompletelyCovered) {
			let tuplet = try Tuplet(3, .sixteenth, notes: notes)
			measure.append(tuplet)
			measure.append(note)
			XCTAssertEqual(measure.noteCount[0], 4)
			try measure.replaceNotes(in: 2 ... 3, with: [note, note])
		}
	}

	// MARK: Successes

	func testReplaceNotesInRangeWithOtherNotes() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .whole)
		let note2 = Note(restDuration: .eighth)
		measure.append(note1)
		measure.append(note2)
		assertNoErrorThrown {
			XCTAssertEqual(measure.noteCount[0], 2)
			try measure.replaceNotes(in: 0 ... 1, with: [note2, note1])
			let resultNote1 = try measure.note(at: 0, inSet: 0)
			let resultNote2 = try measure.note(at: 1, inSet: 0)
			XCTAssertEqual(measure.noteCount[0], 2)
			XCTAssertEqual(resultNote1, note2)
			XCTAssertEqual(resultNote2, note1)
		}
	}

	func testReplaceTupletInRangeWithNotes() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let note2 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let note3 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
			measure.append(note3)
			measure.append(tuplet)
			try measure.startTie(at: 0, inSet: 0)
			XCTAssertEqual(measure.noteCount[0], 4)
			try measure.replaceNotes(in: 1 ... 3, with: [note2, note1])
			var resultNote1 = try measure.note(at: 1, inSet: 0)
			let resultNote2 = try measure.note(at: 2, inSet: 0)
			XCTAssertEqual(measure.noteCount[0], 3)
			XCTAssertEqual(resultNote1.tie, .end)
			resultNote1.tie = nil
			XCTAssertEqual(resultNote1, note2)
			XCTAssertEqual(resultNote2, note1)
		}
	}

	// MARK: - insert(_:NoteCollection:at)

	// MARK: Failures

	func testInsertNoteIndexOutOfRange() {
		XCTAssertEqual(measure.notes[0].count, 0)
		assertThrowsError(MeasureError.noteIndexOutOfRange) {
			try measure.insert(Note(restDuration: .whole), at: 1)
		}
	}

	func testInsertInvalidTupletIndex() {
		let note1 = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let note2 = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .b, octave: .octave1))
		measure.append(note1)
		measure.append(note2)
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertThrowsError(MeasureError.invalidTupletIndex) {
			let tuplet = try Tuplet(3, .eighth, notes: notes)
			try measure.insert(tuplet, at: 1)
			try measure.insert(tuplet, at: 2)
		}
	}

	// MARK: Successes

	func testInsertNote() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .whole)
		let note2 = Note(restDuration: .eighth)
		let note3 = Note(restDuration: .quarter)
		measure.append(note1)
		measure.append(note2)
		assertNoErrorThrown {
			try measure.insert(note3, at: 1)
			XCTAssertEqual(measure.notes[0].count, 3)
			print(measure!)

			let resultNote1 = try measure.note(at: 0, inSet: 0)
			let resultNote2 = try measure.note(at: 1, inSet: 0)
			let resultNote3 = try measure.note(at: 2, inSet: 0)
			XCTAssertEqual(resultNote1, note1)
			XCTAssertEqual(resultNote2, note3)
			XCTAssertEqual(resultNote3, note2)
		}
	}

	func testInsertTuplet() {
		let note1 = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let note2 = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .b, octave: .octave1))
		measure.append(note1)
		measure.append(note2)
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .eighth, notes: notes)
			try measure.insert(tuplet, at: 1)
			let resultNote1 = try measure.note(at: 0)
			let resultTuplet = measure.notes[0][1]  as! Tuplet
			let resultNote2 = try measure.note(at: 4)
			XCTAssertEqual(measure.noteCount[0], 5)
			XCTAssertEqual(note1, resultNote1)
			XCTAssertEqual(tuplet, resultTuplet)
			XCTAssertEqual(note2, resultNote2)
		}
	}

	// MARK: - removeNote(at)

	// MARK: Failures

	func testRemoveNoteFromTuplet() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .eighth)
		measure.append(note1)
		assertThrowsError(MeasureError.removeNoteFromTuplet)  {
			let tuplet = try Tuplet(3, .eighth, notes: [note1, note1, note1])
			measure.append(tuplet)
			try measure.removeNote(at: 1)
		}
	}

	func testRemoveNoteInvalidTieStateStart() {
		var note = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		note.tie = .end
		measure.append(note)
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertThrowsError(MeasureError.invalidTieState) {
			try measure.removeNote(at: 0)
		}
	}

	func testRemoveNoteInvalidTieStateEnd() {
		var note = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		note.tie = .begin
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(note)
		assertThrowsError(MeasureError.invalidTieState) {
			XCTAssertEqual(measure.noteCount[0], 2)
			try measure.removeNote(at: 1)
		}
	}

	// MARK: Successes

	func testRemoveNote() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .whole)
		let note2 = Note(restDuration: .eighth)
		let note3 = Note(restDuration: .quarter)
		measure.append(note1)
		measure.append(note2)
		measure.append(note3)
		assertNoErrorThrown {
			try measure.removeNote(at: 1)
			XCTAssertEqual(measure.notes[0].count, 2)

			let resultNote1 = try measure.note(at: 0, inSet: 0)
			let resultNote2 = try measure.note(at: 1, inSet: 0)

			XCTAssertEqual(resultNote1, note1)
			XCTAssertEqual(resultNote2, note3)
		}
	}

	func testRemoveNoteWithEndTie() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertNoErrorThrown {
			try measure.startTie(at: 0, inSet: 0)
			try measure.removeNote(at: 1)
		}
	}

	// MARK: - removeNotesInRange()

	// MARK: Failures

	func testRemoveNotesInRangeInvalidTieAtStart() {
		XCTAssertEqual(measure.notes[0].count, 0)
		var note1 = Note(restDuration: .whole)
		note1.tie = .end
		let note2 = Note(restDuration: .eighth)
		measure.append(note1)
		measure.append(note2)
		assertThrowsError(MeasureError.invalidTieState) {
			XCTAssertEqual(measure.noteCount[0], 2)
			try measure.removeNotesInRange(0 ... 1)
		}
	}

	func testRemoveNotesInRangeInvalidTieAtEnd() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .whole)
		var note2 = Note(restDuration: .eighth)
		note2.tie = .begin
		measure.append(note1)
		measure.append(note2)
		assertThrowsError(MeasureError.invalidTieState) {
			XCTAssertEqual(measure.noteCount[0], 2)
			try measure.removeNotesInRange(0 ... 1)
		}
	}

	func testRemoveNotesWithInvalidRangeStart() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertThrowsError(MeasureError.tupletNotCompletelyCovered) {
			let tuplet = try Tuplet(3, .eighth, notes: notes)
			measure.append(tuplet)
			XCTAssertEqual(measure.noteCount[0], 4)
			try measure.removeNotesInRange(0 ... 1)
		}
	}

	func testRemoveNotesWithInvalidRangeEnd() {
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertThrowsError(MeasureError.tupletNotCompletelyCovered) {
			let tuplet = try Tuplet(3, .eighth, notes: notes)
			measure.append(tuplet)
			measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
			XCTAssertEqual(measure.noteCount[0], 4)
			try measure.removeNotesInRange(2 ... 3)
		}
	}

	// MARK: Successes

	func testRemoveNotesInRange() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .whole)
		let note2 = Note(restDuration: .eighth)
		let note3 = Note(restDuration: .quarter)
		measure.append(note1)
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(note2)
		measure.append(note3)
		assertNoErrorThrown {
			XCTAssertEqual(measure.notes[0].count, 7)
			try measure.removeNotesInRange(1 ... 4)
			XCTAssertEqual(measure.notes[0].count, 3)

			let resultNote1 = try measure.note(at: 0, inSet: 0)
			let resultNote2 = try measure.note(at: 1, inSet: 0)
			let resultNote3 = try measure.note(at: 2, inSet: 0)

			XCTAssertEqual(resultNote1, note1)
			XCTAssertEqual(resultNote2, note2)
			XCTAssertEqual(resultNote3, note3)
		}
	}

	func testRemoveNotesWithTupletsInRange() {
		XCTAssertEqual(measure.notes[0].count, 0)
		let note1 = Note(restDuration: .whole)
		let note2 = Note(restDuration: .eighth)
		let note3 = Note(restDuration: .quarter)
		measure.append(note1)
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(note2)
		measure.append(note3)
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .eighth, notes: notes)
			try measure.insert(tuplet, at: 4)

			XCTAssertEqual(measure.notes[0].count, 8)
			try measure.removeNotesInRange(1 ... 7)
			XCTAssertEqual(measure.notes[0].count, 3)

			let resultNote1 = try measure.note(at: 0, inSet: 0)
			let resultNote2 = try measure.note(at: 1, inSet: 0)
			let resultNote3 = try measure.note(at: 2, inSet: 0)

			XCTAssertEqual(resultNote1, note1)
			XCTAssertEqual(resultNote2, note2)
			XCTAssertEqual(resultNote3, note3)
		}
	}

	// MARK: - createTuplet()

	// MARK: Failures

	func testCreateTupletInvalidTupletIndexStart() {
		let note1 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let note2 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .b, octave: .octave1))
		let note3 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertThrowsError(MeasureError.invalidTupletIndex)  {
			let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
			measure.append(tuplet)
			measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
			try measure.createTuplet(3, .quarter, fromNotesInRange: 1 ... 3)
		}
	}

	func testCreateTupletInvalidTupletIndexEnd() {
		let note1 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let note2 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .b, octave: .octave1))
		let note3 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		measure.append(note1)
		assertThrowsError(MeasureError.invalidTupletIndex)  {
			let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
			measure.append(tuplet)
			try measure.createTuplet(3, .quarter, fromNotesInRange: 0 ... 2)
		}
	}

	func testCreateTupletNoteIndexOutOfRange() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)))
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .b, octave: .octave1)))
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertThrowsError(MeasureError.noteIndexOutOfRange)  {
			try measure.createTuplet(3, .quarter, fromNotesInRange: 0 ... 3)
		}
	}

	func testCreateTupletNoteInvalidNoteRange() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)))
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .b, octave: .octave1)))
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertThrowsError(MeasureError.noteIndexOutOfRange)  {
			try measure.createTuplet(3, .quarter, fromNotesInRange: 0 ... 3)
		}
	}

	// TODO: Find a way to reach the MeasureError.invalidNoteRange code path
	// https://github.com/drumnkyle/music-notation-core/issues/128

	// MARK: Successes

	func testCreateTuplet() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)))
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .b, octave: .octave1)))
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertNoErrorThrown {
			try measure.createTuplet(3, .quarter, fromNotesInRange: 0 ... 2)
			XCTAssert(measure.notes[0].count == 1)
		}
	}

	// MARK: - breakdownTuplet(at)

	// MARK: Failures

	func testBreakDownTupletInvalidIndex() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)))
		assertThrowsError(MeasureError.invalidTupletIndex) {
			XCTAssert(measure.noteCount[0] == 1)
			try measure.breakdownTuplet(at: 0)
		}
	}

	// MARK: Successes

	func testBreakDownTuplet() {
		let note1 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
		let note2 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .b, octave: .octave1))
		let note3 = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
			measure.append(tuplet)

			try measure.breakdownTuplet(at: 0)
			XCTAssert(measure.noteCount[0] == 3)

			let resultNote1 = try measure.note(at: 0)
			let resultNote2 = try measure.note(at: 1)
			let resultNote3 = try measure.note(at: 2)

			XCTAssertEqual(resultNote1, note1)
			XCTAssertEqual(resultNote2, note2)
			XCTAssertEqual(resultNote3, note3)
		}
	}

	// MARK: - prepTieForInsertion

	// MARK: Failures

	func testPrepTieForInsertNoteRemoveTie() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertThrowsError(MeasureError.invalidTieState) {
			try measure.startTie(at: 0, inSet: 0)
			let note = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
			try measure.insert(note, at: 1, inSet: 0)
		}
	}

	// MARK: Successes

	func testPrepTieForInsertNote() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertNoErrorThrown {
			try measure.startTie(at: 1, inSet: 0)
			let note = Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
			try measure.insert(note, at: 1, inSet: 0)

			let note1 = try measure.note(at: 1, inSet: 0)
			let note2 = try measure.note(at: 2, inSet: 0)
			let note3 = try measure.note(at: 3, inSet: 0)

			XCTAssertNil(note1.tie)
			XCTAssertNotNil(note2.tie)
			XCTAssert(note2.tie == .begin)
			XCTAssertNotNil(note3.tie)
			XCTAssert(note3.tie == .end)
		}
	}

	// MARK: - startTie(at:)

	// MARK: Successes

	func testStartTieNoNextNote() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		// Only change note to .begin
		assertNoErrorThrown {
			try measure.startTie(at: 0, inSet: 0)
			let note = measure.notes[0][0] as! Note
			XCTAssertNotNil(note.tie)
			XCTAssert(note.tie == .begin)
		}
	}

	func testStartTieHasNextNote() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertNoErrorThrown {
			try measure.startTie(at: 0, inSet: 0)
			let note1 = measure.notes[0][0] as! Note
			let note2 = measure.notes[0][1] as! Note
			XCTAssertNotNil(note1.tie)
			XCTAssert(note1.tie == .begin)
			XCTAssertNotNil(note2.tie)
			XCTAssert(note2.tie == .end)
		}
	}

	func testStartTieNoteAlreadyBeginningOfTie() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertNoErrorThrown {
			try measure.startTie(at: 0, inSet: 0)
			try measure.startTie(at: 0, inSet: 0)
			let note1 = measure.notes[0][0] as! Note
			let note2 = measure.notes[0][1] as! Note
			XCTAssert(note1.tie == .begin)
			XCTAssert(note2.tie == .end)
		}
	}

	func testStartTieNextNoteInTuplet() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertNoErrorThrown {
			// setup
			let tuplet = try Tuplet(3, .eighth, notes: notes)
			measure.append(tuplet)

			// test
			try measure.startTie(at: 2, inSet: 0)
			let note1 = measure.notes[0][2] as! Note
			let tuplet2 = measure.notes[0][3] as! Tuplet
			XCTAssert(note1.tie == .begin)
			XCTAssert(try tuplet2.note(at: 0).tie == .end)
		}
	}

	func testStartTieLastNoteOfTupletNoNextNote() {
		// Just change to .begin
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertNoErrorThrown {
			// setup
			let tupletSetup = try Tuplet(3, .eighth, notes: notes)
			measure.append(tupletSetup)

			// test
			try measure.startTie(at: 2, inSet: 0)
			try measure.startTie(at: 5, inSet: 0)
			let tuplet = measure.notes[0][3] as! Tuplet
			XCTAssert(try tuplet.note(at: 2).tie == .begin)
		}
	}

	func testStartTieNoteIsEndOfAnotherTie() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertNoErrorThrown {
			// setup
			let tupletSetup = try Tuplet(3, .eighth, notes: notes)
			measure.append(tupletSetup)
			try measure.startTie(at: 2, inSet: 0)

			// test
			try measure.startTie(at: 3, inSet: 0)
			let tuplet = measure.notes[0][3] as! Tuplet
			XCTAssert(try tuplet.note(at: 0).tie == .beginAndEnd)
			XCTAssert(try tuplet.note(at: 1).tie == .end)
		}
	}

	func testStartTieLastNoteOfTupletHasNextNote() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertNoErrorThrown {
			// setup
			let tupletSetup = try Tuplet(3, .eighth, notes: notes)
			measure.append(tupletSetup)
			try measure.startTie(at: 2, inSet: 0)

			// test
			try measure.startTie(at: 5, inSet: 0)
			let tuplet = measure.notes[0][3] as! Tuplet
			XCTAssert(try tuplet.note(at: 2).tie == .begin)
		}
	}

	func testStartTieLastNoteOfTupletNextNoteTuplet() {
		assertNoErrorThrown {
			let note = Note(noteDuration: .sixteenth,
							pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
			let tuplet1 = try Tuplet(3, .sixteenth, notes: [note, note, note])
			let tuplet2 = try Tuplet(5, .sixteenth, notes: [note, note, note, note, note])
			measure.append(tuplet1)
			measure.append(tuplet2)
			try measure.startTie(at: 2, inSet: 0)
			let note1 = noteFromMeasure(measure, noteIndex: 0, tupletIndex: 2)
			let note2 = noteFromMeasure(measure, noteIndex: 1, tupletIndex: 0)
			XCTAssert(note1.tie == .begin)
			XCTAssert(note2.tie == .end)
		}
	}

	func testStartTieInNestedTuplet() {
		assertNoErrorThrown {
			let note = Note(noteDuration: .eighth,
							pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
			let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
			let tuplet = try Tuplet(3, .eighth, notes: [triplet, note])
			measure.append(tuplet)
			measure.append(note)
			try measure.startTie(at: 3, inSet: 0)
			let note1 = try measure.note(at: 3)
			let note2 = try measure.note(at: 4)
			XCTAssert(note1.tie == .begin)
			XCTAssert(note2.tie == .end)
		}
	}

	// MARK: - startTie(at:)

	// MARK: Failures

	func testStartTieNoteHasDiffPitch() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		assertThrowsError(MeasureError.notesMustHaveSamePitchesToTie) {
			try measure.startTie(at: 0, inSet: 0)
		}
	}

	func testStartTieNextNoteInTupletDiffPitch() {
		measure.append(Note(noteDuration: .quarter, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		let notes = [
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
			Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .a, octave: .octave1)),
		]
		assertThrowsError(MeasureError.notesMustHaveSamePitchesToTie) {
			let tuplet = try Tuplet(3, .eighth, notes: notes)
			measure.append(tuplet)
			try measure.startTie(at: 2, inSet: 0)
		}
	}

	// MARK: - removeTie(at:)

	// MARK: Failures

	func testRemoveTieNoNoteAtIndex() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))

		assertThrowsError(MeasureError.noteIndexOutOfRange) {
			try measure.removeTie(at: 4, inSet: 0)
		}
	}

	// MARK: Successes

	func testRemoveTieNoTie() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))

		assertNoErrorThrown {
			try measure.removeTie(at: 0, inSet: 0)
			let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
			let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieBeginOfTie() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))

		assertNoErrorThrown {
			setTie(at: 0)
			try measure.removeTie(at: 0, inSet: 0)
			let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
			let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieFromBeginAndEnd() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))

		assertNoErrorThrown {
			setTie(at: 0)
			setTie(at: 1)
			try measure.removeTie(at: 1, inSet: 0)
			let firstNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
			let secondNote = noteFromMeasure(measure, noteIndex: 2, tupletIndex: nil)
			XCTAssert(firstNote.tie == .end)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieBeginsInTuplet() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))

		let note = Note(noteDuration: .sixteenth,
						pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
			measure.append(tuplet)
			measure.append(note)
		}

		assertNoErrorThrown {
			setTie(at: 6)
			try measure.removeTie(at: 6, inSet: 0)
			let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
			let secondNote = noteFromMeasure(measure, noteIndex: 5, tupletIndex: nil)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieBeginAndEndInOneTuplet() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))

		let note = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
			measure.append(tuplet)
			measure.append(note)
		}

		assertNoErrorThrown {
			setTie(at: 5)
			try measure.removeTie(at: 5, inSet: 0)
			let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
			let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieEndsInTuplet() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))

		let note = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
			measure.append(tuplet)
			measure.append(note)
		}

		assertNoErrorThrown {
			setTie(at: 4)
			try measure.removeTie(at: 4, inSet: 0)
			let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 0)
			let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	func testRemoveTieTupletToOtherTuplet() {
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))
		measure.append(Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1)))

		let note = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
			measure.append(tuplet)
			measure.append(note)
		}

		assertNoErrorThrown {
			let tuplet1 = try Tuplet(5, .sixteenth, notes: [note, note, note, note, note])
			let tuplet2 = try Tuplet(3, .sixteenth, notes: [note, note, note])
			measure.append(tuplet1)
			measure.append(tuplet2)
			setTie(at: 11)
			try measure.removeTie(at: 11, inSet: 0)
			let firstNote = noteFromMeasure(measure, noteIndex: 6, tupletIndex: 3)
			let secondNote = noteFromMeasure(measure, noteIndex: 7, tupletIndex: 0)
			XCTAssertNil(firstNote.tie)
			XCTAssertNil(secondNote.tie)
		}
	}

	// MARK: - noteCollectionIndexFromNoteIndex(_:)

	// MARK: Successes

	func testNoteCollectionIndexFromNoteIndexNoTuplets() {
		// NoteIndex should be the same if there are no tuplets
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))

		assertNoErrorThrown {
			let index = try measure.noteCollectionIndex(fromNoteIndex: 2, inSet: 0)
			XCTAssertEqual(index.noteIndex, 2)
			XCTAssertNil(index.tupletIndex)
		}
	}

	func testNoteCollectionIndexFromNoteIndexWithinTuplet() {
		// NoteIndex should be the beginning of the tuplet if the index specified
		// is within the tuplet, and tupletIndex should be the index of the note
		// within the tuplet
		measure.append(Note(restDuration: .quarter))
		assertNoErrorThrown {
			let note1 = Note(noteDuration: .eighth,
							 pitch: SpelledPitch(noteLetter: .a, octave: .octave1))
			let note2 = Note(noteDuration: .eighth,
							 pitch: SpelledPitch(noteLetter: .b, octave: .octave1))
			let note3 = Note(noteDuration: .eighth,
							 pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
			measure.append(try Tuplet(3, .eighth, notes: [note1, note2, note3]))
			let index = try measure.noteCollectionIndex(fromNoteIndex: 2, inSet: 0)
			XCTAssertEqual(index.noteIndex, 1)
			XCTAssertNotNil(index.tupletIndex)
			XCTAssertEqual(index.tupletIndex!, 1)

			// Properly address regular note coming after a tuplet
			measure.append(Note(restDuration: .eighth))
			let index2 = try measure.noteCollectionIndex(fromNoteIndex: 4, inSet: 0)
			XCTAssertEqual(index2.noteIndex, 2)
			XCTAssertNil(index2.tupletIndex)
		}
	}

	// MARK: - hasClefAfterNote(at:) -> Bool

	// MARK: False

	func testHasClefAfterNoteInvalidIndex() {
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		XCTAssertFalse(measure.hasClefAfterNote(at: 3, inSet: 0))
	}

	func testHasClefAfterNoteNoClefsFirstIndex() {
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		XCTAssertFalse(measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	func testHasClefAfterNoteNoClefsMiddleIndex() {
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		assertNoErrorThrown {
			try measure.changeClef(Clef.treble, at: 0, inSet: 0)
		}
		XCTAssertFalse(measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	func testHasClefAfterNoteMiddleOfTuplet() {
		let quarter = Note(restDuration: .quarter)
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .eighth, notes: [eighth, eighth, eighth])
			measure.append(quarter)
			measure.append(quarter)
			measure.append(tuplet)
			measure.append(eighth)
			measure.append(eighth)
			try measure.changeClef(Clef.treble, at: 3, inSet: 0)
		}
		XCTAssertFalse(measure.hasClefAfterNote(at: 3, inSet: 0))
	}

	func KNOWNISSUEtestHasClefAfterNoteMiddleOfCompoundTuplet() {
		// FIXME: throws MeasureError.cannotCalculateTicksWithinCompoundTuplet error
		// https://github.com/drumnkyle/music-notation-core/issues/129
		let note = Note(restDuration: .eighth)
		measure.append(note)
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
			let compoundTuplet = try Tuplet(5, .eighth, notes: [note, note, triplet, note])
			measure.append(compoundTuplet)
			try measure.changeClef(Clef.treble, at: 3, inSet: 0)
		}
		XCTAssertFalse(measure.hasClefAfterNote(at: 4, inSet: 0))
	}

	func testHasClefAfterNoteNoteOfClefChange() {
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		assertNoErrorThrown {
			try measure.changeClef(Clef.treble, at: 1, inSet: 0)
		}
		XCTAssertFalse(measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	func testHasClefAfterNoteNoteAfterClefChange() {
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		assertNoErrorThrown {
			try measure.changeClef(Clef.treble, at: 1, inSet: 0)
		}
		XCTAssertFalse(measure.hasClefAfterNote(at: 2, inSet: 0))
	}

	// MARK: True

	func testHasClefAfterNoteOneClefNoteBefore() {
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		assertNoErrorThrown {
			try measure.changeClef(Clef.treble, at: 2, inSet: 0)
		}
		XCTAssertTrue(measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	func testHasClefAfterNoteMultipleClefsNoteBefore() {
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		assertNoErrorThrown {
			try measure.changeClef(Clef.treble, at: 2, inSet: 0)
			try measure.changeClef(Clef.treble, at: 3, inSet: 0)
		}
		XCTAssertTrue(measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	func testHasClefAfterNoteMultipleClefsNoteInMiddle() {
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		assertNoErrorThrown {
			try measure.changeClef(Clef.treble, at: 1, inSet: 0)
			try measure.changeClef(Clef.treble, at: 3, inSet: 0)
		}
		XCTAssertTrue(measure.hasClefAfterNote(at: 2, inSet: 0))
	}

	// MARK: - cumulativeTicks(at:inSet:) throws -> Int

	// MARK: Failures

	func testCumulativeTicksInvalidNoteIndex() {
		let note = Note(restDuration: .quarter)
		measure.append(note)
		assertThrowsError(MeasureError.noteIndexOutOfRange) {
			_ = try measure.cumulativeTicks(at: 2, inSet: 0)
		}
	}

	func testCumulativeTicksInvalidSetIndex() {
		let note = Note(restDuration: .quarter)
		measure.append(note)
		assertThrowsError(MeasureError.noteIndexOutOfRange) {
			_ = try measure.cumulativeTicks(at: 0, inSet: 1)
		}
	}

	func KNOWNISSUEtestCumulativeTicksInMiddleOfCompoundTuplet() {
		let note = Note(restDuration: .eighth)
		measure.append(note)
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
			let compoundTuplet = try Tuplet(5, .eighth, notes: [note, note, triplet, note])
			measure.append(compoundTuplet)
		}
		print(measure.debugDescription)
		// FIXME: there is no implementation of throw MeasureError.cannotCalculateTicksWithinCompoundTuplet in cumulativeTicks
		// https://github.com/drumnkyle/music-notation-core/issues/129
		assertThrowsError(MeasureError.cannotCalculateTicksWithinCompoundTuplet) {
			_ = try measure.cumulativeTicks(at: 4)
		}
	}

	// MARK: Successes

	func testCumulativeTicksBeginning() {
		let note = Note(restDuration: .quarter)
		measure.append(note)
		measure.append(note)
		measure.append(note)
		measure.append(note, inSet: 1)
		assertNoErrorThrown {
			XCTAssertEqual(try measure.cumulativeTicks(at: 0, inSet: 0), 0)
			XCTAssertEqual(try measure.cumulativeTicks(at: 0, inSet: 1), 0)
		}
	}

	func testCumulativeTicksAllNotes() {
		let quarter = Note(restDuration: .quarter)
		let eighth = Note(restDuration: .eighth)
		measure.append(quarter)
		measure.append(quarter)
		measure.append(eighth)
		measure.append(eighth)
		measure.append(eighth)
		measure.append(quarter)
		measure.append(quarter)
		measure.append(quarter, inSet: 1)
		measure.append(quarter, inSet: 1)
		measure.append(quarter, inSet: 1)
		let quarterTicks = NoteDuration.quarter.ticks
		let eighthTicks = NoteDuration.eighth.ticks
		assertNoErrorThrown {
			var currentValue = quarterTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 1, inSet: 0), currentValue)
			currentValue += quarterTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 2, inSet: 0), currentValue)
			currentValue += eighthTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 3, inSet: 0), currentValue)
			currentValue += eighthTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 4, inSet: 0), currentValue)
			currentValue += eighthTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 5, inSet: 0), currentValue)
			currentValue += quarterTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 6, inSet: 0), currentValue)
			var currentSet1Value = quarterTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 1, inSet: 0), currentSet1Value)
			currentSet1Value += quarterTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 2, inSet: 0), currentSet1Value)
		}
	}

	func testCumulativeTicksBeginningOfTuplet() {
		let quarter = Note(restDuration: .quarter)
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .eighth, notes: [eighth, eighth, eighth])
			measure.append(quarter)
			measure.append(quarter)
			measure.append(tuplet)
			measure.append(eighth)
			measure.append(eighth)
			let quarterTicks = NoteDuration.quarter.ticks
			let eighthTicks = NoteDuration.eighth.ticks
			XCTAssertEqual(try measure.cumulativeTicks(at: 1, inSet: 0), quarterTicks)
			XCTAssertEqual(try measure.cumulativeTicks(at: 2, inSet: 0), 2 * quarterTicks)
			XCTAssertEqual(try measure.cumulativeTicks(at: 3, inSet: 0), 2 * quarterTicks + 1 / 3 * tuplet.ticks)
			XCTAssertEqual(try measure.cumulativeTicks(at: 4, inSet: 0), 2 * quarterTicks + 2 / 3 * tuplet.ticks)
			XCTAssertEqual(try measure.cumulativeTicks(at: 5, inSet: 0), 2 * quarterTicks + tuplet.ticks)
			XCTAssertEqual(try measure.cumulativeTicks(at: 6, inSet: 0), 2 * quarterTicks + tuplet.ticks + eighthTicks)
		}
	}

	func testCumulativeTicksMiddleOfTuplet() {
		let note = Note(restDuration: .eighth)
		measure.append(note)
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
			measure.append(triplet)
		}
		assertNoErrorThrown {
			let ticks = try measure.cumulativeTicks(at: 2)
			XCTAssertEqual(ticks, note.ticks + note.ticks * 2 / 3)
		}
	}

	func KNOWNISSUEtestCumulativeTicksAtBeginningOfCompoundTuplet() {
		// FIXME: throws MeasureError.cannotCalculateTicksWithinCompoundTuplet
		// https://github.com/drumnkyle/music-notation-core/issues/129
		let note = Note(restDuration: .eighth)
		measure.append(note)
		assertNoErrorThrown {
			let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
			let compoundTuplet = try Tuplet(5, .eighth, notes: [note, note, triplet, note])
			measure.append(compoundTuplet)
			print(measure.debugDescription) // |4/4: [1/8R, 6[1/8R, 1/8R, 3[1/8R, 1/8R, 1/8R], 1/8R]]|
			let eighthTicks = NoteDuration.eighth.ticks
			let eachCompoundTicks = compoundTuplet.ticks / Double(compoundTuplet.groupingOrder)
			let eachTripletTicks = 2 * eachCompoundTicks / Double(triplet.groupingOrder)
			var currentTicks = eighthTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 1, inSet: 0), currentTicks)
			currentTicks += eachCompoundTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 2, inSet: 0), currentTicks)
			currentTicks += eachCompoundTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 3, inSet: 0), currentTicks)
			currentTicks += eachTripletTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 4, inSet: 0), currentTicks)
			currentTicks += eachTripletTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 5, inSet: 0), currentTicks)
			currentTicks += eachTripletTicks
			XCTAssertEqual(try measure.cumulativeTicks(at: 6, inSet: 0), currentTicks)
		}
	}

	// MARK: - clef(at:inSet:)

	// MARK: Successes

	func test1ClefAtBeginningNoOriginal() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		assertNoErrorThrown {
			let newClef: Clef = .bass
			try testMeasure.changeClef(newClef, at: 0)
			XCTAssertEqual(try testMeasure.clef(at: 0, inSet: 0), newClef)
			try (1 ..< testMeasure.noteCount[0]).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef)
			}
		}
	}

	func test1ClefAtBeginningWithOriginal() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		let originalClef: Clef = .treble
		testMeasure.originalClef = originalClef
		assertNoErrorThrown {
			let newClef: Clef = .bass
			try testMeasure.changeClef(newClef, at: 0)
			XCTAssertEqual(try testMeasure.clef(at: 0, inSet: 0), newClef)
			try (1 ..< testMeasure.noteCount[0]).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef)
			}
		}
	}

	func test1ClefAtBeginningAnd1Other() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		assertNoErrorThrown {
			let newClef1: Clef = .bass
			let newClef2: Clef = .alto
			try testMeasure.changeClef(newClef1, at: 0)
			try testMeasure.changeClef(newClef2, at: 2)
			try (0 ..< 2).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef1)
			}
			try (2 ..< testMeasure.noteCount[0]).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef2)
			}
		}
	}

	func test1ClefAtEndWithOriginal() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		let originalClef: Clef = .treble
		testMeasure.originalClef = originalClef
		assertNoErrorThrown {
			let newClef: Clef = .bass
			try testMeasure.changeClef(newClef, at: 3)
			try (0 ..< 3).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), originalClef)
			}
			try (3 ..< testMeasure.noteCount[0]).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef)
			}
		}
	}

	func test2ClefsInDifferentSetsWithOriginal() {
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let sixteenth = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))

		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth,
			],
			[
				eighth, eighth, eighth, eighth,
			],
		])
		let originalClef: Clef = .treble
		testMeasure.originalClef = originalClef
		assertNoErrorThrown {
			let newClef1: Clef = .bass
			let newClef2: Clef = .alto
			try testMeasure.changeClef(newClef1, at: 2, inSet: 1) // Set 0: 5th note changes. Set 1: 3rd note changes.
			try testMeasure.changeClef(newClef2, at: 7, inSet: 0) // Set 0: 8th note changes. Set 1: No change.

			// set 0
			try (0 ..< 4).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), originalClef)
			}
			try (4 ..< 7).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef1)
			}
			try (7 ..< testMeasure.noteCount[0]).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef2)
			}
			// set 1
			try (0 ..< 2).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 1), originalClef)
			}
			try (2 ..< testMeasure.noteCount[1]).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 1), newClef1)
			}
		}
	}

	func test2ClefsInDifferentSetsNoOriginal() {
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let sixteenth = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))

		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth,
			],
			[
				eighth, eighth, eighth, eighth,
			],
		])
		assertNoErrorThrown {
			let newClef1: Clef = .bass
			let newClef2: Clef = .alto
			try testMeasure.changeClef(newClef1, at: 2, inSet: 1) // Set 0: 5th note changes. Set 1: 3rd note changes.
			try testMeasure.changeClef(newClef2, at: 7, inSet: 0) // Set 0: 8th note changes. Set 1: No change.

			// set 0
			(0 ..< 4).forEach { index in
				assertThrowsError(MeasureError.noClefSpecified) {
					_ = try testMeasure.clef(at: index, inSet: 0)
				}
			}
			try (4 ..< 7).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef1)
			}
			try (7 ..< testMeasure.noteCount[0]).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef2)
			}
			// set 1
			(0 ..< 2).forEach { index in
				assertThrowsError(MeasureError.noClefSpecified) {
					_ = try testMeasure.clef(at: index, inSet: 1)
				}
			}
			try (2 ..< testMeasure.noteCount[1]).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 1), newClef1)
			}
		}
	}

	// MARK: Failures

	func testNoClefsNoOriginal() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		(0 ..< testMeasure.noteCount[0]).forEach { index in
			assertThrowsError(MeasureError.noClefSpecified) {
				_ = try testMeasure.clef(at: index, inSet: 0)
			}
		}
	}

	func test1ClefNotAtBeginningNoOriginal() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		let newClef: Clef = .alto
		assertNoErrorThrown {
			try testMeasure.changeClef(.alto, at: 2)
		}
		(0 ..< 2).forEach { index in
			assertThrowsError(MeasureError.noClefSpecified) {
				_ = try testMeasure.clef(at: index, inSet: 0)
			}
		}
		assertNoErrorThrown {
			try (2 ..< testMeasure.noteCount[0]).forEach {
				XCTAssertEqual(try testMeasure.clef(at: $0, inSet: 0), newClef)
			}
		}
	}

	func testClefsInvalidNoteIndex() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		assertThrowsError(MeasureError.noteIndexOutOfRange) {
			_ = try testMeasure.clef(at: 17, inSet: 0)
		}
	}

	func testClefsInvalidSetIndex() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		assertThrowsError(MeasureError.noteIndexOutOfRange) {
			_ = try testMeasure.clef(at: 0, inSet: 3)
		}
	}

	// MARK: - changeClef(_:at:inSet:) throws

	// MARK: Failures

	func testChangeClefInvalidNoteIndex() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		assertThrowsError(MeasureError.noteIndexOutOfRange) {
			try measure.changeClef(.bass, at: 5)
		}
		XCTAssertNil(measure.originalClef)
		XCTAssertNil(measure.lastClef)
		XCTAssertEqual(measure.clefs, [:])
	}

	func testChangeClefInvalidSetIndex() {
		let note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		assertThrowsError(MeasureError.noteIndexOutOfRange) {
			try measure.changeClef(.bass, at: 3, inSet: 1)
		}
		XCTAssertNil(measure.originalClef)
		XCTAssertNil(measure.lastClef)
		XCTAssertEqual(measure.clefs, [:])
	}

	// MARK: Successes

	func testChangeClefAtBeginningNoOthers() {
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let quarter = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		assertNoErrorThrown {
			try measure.changeClef(.bass, at: 0, inSet: 0)
			XCTAssertEqual(measure.clefs, [0: .bass])
			XCTAssertEqual(measure.lastClef, .bass)
			XCTAssertEqual(measure.originalClef, nil)
		}
	}

	func testChangeClefAtBeginningNoOthersSecondSet() {
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let quarter = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		assertNoErrorThrown {
			try measure.changeClef(.bass, at: 0, inSet: 1)
			XCTAssertEqual(measure.clefs, [0: .bass])
			XCTAssertEqual(measure.lastClef, .bass)
			XCTAssertEqual(measure.originalClef, nil)
		}
	}

	func testChangeClefAtBeginningAlreadyThere() {
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let quarter = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		assertNoErrorThrown {
			try measure.changeClef(.bass, at: 0, inSet: 1)
			try measure.changeClef(.treble, at: 0, inSet: 1)
			XCTAssertEqual(measure.clefs, [0: .treble])
			XCTAssertEqual(measure.lastClef, .treble)
			XCTAssertEqual(measure.originalClef, nil)
		}
	}

	func testChangeClefInMiddleNoOthers() {
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let quarter = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		assertNoErrorThrown {
			try measure.changeClef(.bass, at: 3, inSet: 1)
			XCTAssertEqual(measure.clefs, [3072: .bass])
			XCTAssertEqual(measure.lastClef, .bass)
			XCTAssertEqual(measure.originalClef, nil)
		}
	}

	func testChangeClefInMiddleHasBeginning() {
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let quarter = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		assertNoErrorThrown {
			try measure.changeClef(.treble, at: 0, inSet: 1)
			try measure.changeClef(.bass, at: 3, inSet: 1)
			XCTAssertEqual(measure.clefs, [0: .treble, 3072: .bass])
			XCTAssertEqual(measure.lastClef, .bass)
			XCTAssertEqual(measure.originalClef, nil)
		}
	}

	func testChangeClefInMiddleHasEnd() {
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let quarter = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		print(measure.debugDescription)
		assertNoErrorThrown {
			try measure.changeClef(.bass, at: 3, inSet: 1)
			try measure.changeClef(.treble, at: 7, inSet: 1)
			XCTAssertEqual(measure.clefs, [3072: .bass, 7168: .treble])
			XCTAssertEqual(measure.lastClef, .treble)
			XCTAssertEqual(measure.originalClef, nil)
		}
	}

	func testChangeClefInMiddleHasBeginningAndEnd() {
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let quarter = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		assertNoErrorThrown {
			try measure.changeClef(.treble, at: 0, inSet: 1)
			try measure.changeClef(.bass, at: 3, inSet: 1)
			try measure.changeClef(.treble, at: 7, inSet: 1)
			XCTAssertEqual(measure.clefs, [0: .treble, 3072: .bass, 7168: .treble])
			XCTAssertEqual(measure.lastClef, .treble)
			XCTAssertEqual(measure.originalClef, nil)
		}
		print(measure.debugDescription)
	}

	func testChangeClefWithinTuplet() {
		let quarter = Note(restDuration: .quarter)
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		assertNoErrorThrown {
			let tuplet = try Tuplet(3, .eighth, notes: [eighth, eighth, eighth])
			measure.append(quarter)
			measure.append(quarter)
			measure.append(tuplet)
			measure.append(eighth)
			measure.append(eighth)
			try measure.changeClef(.bass, at: 5, inSet: 0)
			XCTAssertEqual(measure.clefs, [6144: .bass])
			XCTAssertEqual(measure.lastClef, .bass)
			XCTAssertEqual(measure.originalClef, nil)
		}
	}

	// MARK: - changeFirstClefIfNeeded(to:) -> Bool

	// MARK: Return False

	func testChangeFirstClefIfNeededWhenNotEmpty() {
		// Setup
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let quarter = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		assertNoErrorThrown {
			try measure.changeClef(.bass, at: 0)
		}

		// Test
		XCTAssertEqual(measure.changeFirstClefIfNeeded(to: .treble), false)
		XCTAssertEqual(measure.lastClef, .bass)
		XCTAssertEqual(measure.originalClef, nil)
		XCTAssertEqual(measure.clefs, [0: .bass])
	}

	// MARK: Return True

	func testChangeFirstClefIfNeededWhenEmtpy() {
		// Setup
		let eighth = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		let quarter = Note(noteDuration: .sixteenth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		// Test
		XCTAssertEqual(measure.changeFirstClefIfNeeded(to: .treble), true)
		XCTAssertEqual(measure.lastClef, .treble)
		XCTAssertEqual(measure.originalClef, .treble)
		XCTAssertTrue(measure.clefs.isEmpty)
	}

	// MARK: - Collection Conformance

	func testMapEmpty() {
		let mappedMeasureSlices = measure.compactMap { $0 }
		let expectedMeasureSlices: [MeasureSlice] = []
		XCTAssertTrue(mappedMeasureSlices.isEmpty)
		XCTAssertTrue(expectedMeasureSlices.isEmpty)

		let repeatedMeasure = RepeatedMeasure(timeSignature: timeSignature)
		let repeatedMappedMeasureSlices = repeatedMeasure.map { $0 }
		XCTAssertTrue(repeatedMappedMeasureSlices.isEmpty)
		XCTAssertTrue(expectedMeasureSlices.isEmpty)
	}

	func testMapSingleNoteSet() {
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .quarter))
		measure.append(Note(restDuration: .eighth))
		measure.append(Note(restDuration: .eighth))
		measure.append(Note(restDuration: .quarter))

		let repeatedMeasure = RepeatedMeasure(
			timeSignature: timeSignature,
			notes: [
				[
					Note(restDuration: .quarter),
					Note(restDuration: .quarter),
					Note(restDuration: .eighth),
					Note(restDuration: .eighth),
					Note(restDuration: .quarter),
				],
			]
		)
		let repeatedMappedMeasureSlices = repeatedMeasure.map { $0 }

		let mappedMeasureSlices = measure.compactMap { $0 }
		let expectedMeasureSlices: [[MeasureSlice]] = [
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .quarter))],
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .quarter))],
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .eighth))],
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .eighth))],
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .quarter))],
		]
		var count = 0
		zip(mappedMeasureSlices, expectedMeasureSlices).forEach {
			XCTAssertEqual($0, $1)
			count += 1
		}
		XCTAssertEqual(count, expectedMeasureSlices.count)

		var repeatedCount = 0
		zip(repeatedMappedMeasureSlices, expectedMeasureSlices).forEach {
			XCTAssertEqual($0, $1)
			repeatedCount += 1
		}
		XCTAssertEqual(repeatedCount, expectedMeasureSlices.count)
	}

	func testMapMultipleNoteSets() {
		measure.append(Note(restDuration: .quarter), inSet: 0)
		measure.append(Note(restDuration: .sixteenth), inSet: 1)
		measure.append(Note(restDuration: .quarter), inSet: 0)
		measure.append(Note(restDuration: .thirtySecond), inSet: 1)
		measure.append(Note(restDuration: .eighth), inSet: 0)
		measure.append(Note(restDuration: .quarter), inSet: 1)
		measure.append(Note(restDuration: .eighth), inSet: 0)
		measure.append(Note(restDuration: .quarter), inSet: 1)
		measure.append(Note(restDuration: .quarter), inSet: 0)
		measure.append(Note(restDuration: .quarter), inSet: 1)
		measure.append(Note(restDuration: .whole), inSet: 1)
		measure.append(Note(restDuration: .whole), inSet: 1)

		let repeatedMeasure = RepeatedMeasure(
			timeSignature: timeSignature,
			notes: [
				[
					Note(restDuration: .quarter),
					Note(restDuration: .quarter),
					Note(restDuration: .eighth),
					Note(restDuration: .eighth),
					Note(restDuration: .quarter),

				],
				[
					Note(restDuration: .sixteenth),
					Note(restDuration: .thirtySecond),
					Note(restDuration: .quarter),
					Note(restDuration: .quarter),
					Note(restDuration: .quarter),
					Note(restDuration: .whole),
					Note(restDuration: .whole),
				],
			]
		)
		let repeatedMappedMeasureSlices = repeatedMeasure.map { $0 }

		let mappedMeasureSlices = measure.compactMap { $0 }
		let expectedMeasureSlices: [[MeasureSlice]] = [
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .quarter)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .sixteenth)),

			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .quarter)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .thirtySecond)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .eighth)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .quarter)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .eighth)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .quarter)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .quarter)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .quarter)),
			],
			[
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .whole)),
			],
			[
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .whole)),
			],
		]
		var count = 0
		zip(mappedMeasureSlices, expectedMeasureSlices).forEach {
			XCTAssertEqual($0, $1)
			count += 1
		}
		XCTAssertEqual(count, expectedMeasureSlices.count)

		var repeatedCount = 0
		zip(repeatedMappedMeasureSlices, expectedMeasureSlices).forEach {
			XCTAssertEqual($0, $1)
			repeatedCount += 1
		}
		XCTAssertEqual(repeatedCount, expectedMeasureSlices.count)
	}

	func testReversed() {
		measure.append(Note(restDuration: .whole), inSet: 0)
		measure.append(Note(restDuration: .thirtySecond), inSet: 1)
		measure.append(Note(restDuration: .quarter), inSet: 0)
		measure.append(Note(restDuration: .sixtyFourth), inSet: 1)
		measure.append(Note(restDuration: .eighth), inSet: 0)
		measure.append(Note(restDuration: .oneTwentyEighth), inSet: 1)
		measure.append(Note(restDuration: .sixteenth), inSet: 0)
		measure.append(Note(restDuration: .twoFiftySixth), inSet: 1)

		let repeatedMeasure = RepeatedMeasure(
			timeSignature: timeSignature,
			notes: [
				[
					Note(restDuration: .whole),
					Note(restDuration: .quarter),
					Note(restDuration: .eighth),
					Note(restDuration: .sixteenth),
				],
				[
					Note(restDuration: .thirtySecond),
					Note(restDuration: .sixtyFourth),
					Note(restDuration: .oneTwentyEighth),
					Note(restDuration: .twoFiftySixth),
				],
			]
		)
		let repeatedReversedMeasureSlices = repeatedMeasure.reversed()

		let reversedMeasureSlices = measure.reversed()
		let expectedMeasureSlices: [[MeasureSlice]] = [
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .sixteenth)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .twoFiftySixth)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .eighth)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .oneTwentyEighth)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .quarter)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .sixtyFourth)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .whole)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .thirtySecond)),
			],
		]

		var count = 0
		zip(reversedMeasureSlices, expectedMeasureSlices).forEach {
			XCTAssertEqual($0, $1)
			count += 1
		}
		XCTAssertEqual(count, expectedMeasureSlices.count)

		var repeatedCount = 0
		zip(repeatedReversedMeasureSlices, expectedMeasureSlices).forEach {
			XCTAssertEqual($0, $1)
			repeatedCount += 1
		}
		XCTAssertEqual(repeatedCount, expectedMeasureSlices.count)
	}

	func testIterator() {
		measure.append(Note(restDuration: .whole), inSet: 0)
		measure.append(Note(restDuration: .thirtySecond), inSet: 1)
		measure.append(Note(restDuration: .quarter), inSet: 0)
		measure.append(Note(restDuration: .eighth), inSet: 1)

		let repeatedMeasure = RepeatedMeasure(
			timeSignature: timeSignature,
			notes: [
				[
					Note(restDuration: .whole),
					Note(restDuration: .quarter),
				],
				[
					Note(restDuration: .thirtySecond),
					Note(restDuration: .eighth),
				],
			]
		)

		let expectedMeasureSlice1: [MeasureSlice] = [
			MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .whole)),
			MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .thirtySecond)),
		]
		let expectedMeasureSlice2: [MeasureSlice] = [
			MeasureSlice(noteSetIndex: 0, noteCollection: Note(restDuration: .quarter)),
			MeasureSlice(noteSetIndex: 1, noteCollection: Note(restDuration: .eighth)),
		]
		let expectedMeasureSlices = [expectedMeasureSlice1, expectedMeasureSlice2]
		var iterator = measure.makeIterator()
		var iteratorCount = 0
		while let next = iterator.next() {
			XCTAssertEqual(next, expectedMeasureSlices[iteratorCount])
			iteratorCount += 1
		}
		XCTAssertEqual(iteratorCount, expectedMeasureSlices.count)

		var repeatedIterator = repeatedMeasure.makeIterator()
		var repeatedIteratorCount = 0
		while let next = repeatedIterator.next() {
			XCTAssertEqual(next, expectedMeasureSlices[repeatedIteratorCount])
			repeatedIteratorCount += 1
		}
		XCTAssertEqual(repeatedIteratorCount, expectedMeasureSlices.count)
	}

	// MARK: - Helpers

	private func setTie(at index: Int, functionName: String = #function, lineNum: Int = #line) {
		assertNoErrorThrown {
			try measure.startTie(at: index, inSet: 0)
			let noteCollectionIndex1 = try measure.noteCollectionIndex(fromNoteIndex: index, inSet: 0)
			let noteCollectionIndex2 = try measure.noteCollectionIndex(fromNoteIndex: index + 1, inSet: 0)
			let firstNote = noteFromMeasure(measure, noteIndex: noteCollectionIndex1.noteIndex,
											tupletIndex: noteCollectionIndex1.tupletIndex)
			let secondNote = noteFromMeasure(measure, noteIndex: noteCollectionIndex2.noteIndex,
											 tupletIndex: noteCollectionIndex2.tupletIndex)
			XCTAssert(firstNote.tie == .begin || firstNote.tie == .beginAndEnd,
					  "\(functionName): \(lineNum)")
			XCTAssert(secondNote.tie == .end || secondNote.tie == .beginAndEnd,
					  "\(functionName): \(lineNum)")
		}
	}

	private func noteFromMeasure(_ measure: Measure, noteIndex: Int, tupletIndex: Int?) -> Note {
		if let tupletIndex = tupletIndex {
			let tuplet = measure.notes[0][noteIndex] as! Tuplet
			return try! tuplet.note(at: tupletIndex)
		} else {
			return measure.notes[0][noteIndex] as! Note
		}
	}
}
