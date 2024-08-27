//
//	MeasureTests.swift
//	MusicNotation
//
//	Created by Kyle Sherman on 2016-07-13.
//	Copyright © 2015 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class MeasureTests {
	var measure: Measure!
	var timeSignature: TimeSignature!

	init() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		timeSignature = TimeSignature(numerator: 4, denominator: 4, tempo: 120)
		measure = Measure(
			timeSignature: timeSignature,
			key: Key(noteLetter: .c)
		)
	}

	deinit {
		measure = nil
		timeSignature = nil
	}

	@Test func addNote() async throws {
		#expect(measure.notes[0].count == 0)
		measure.append(Note(.whole, pitch: SpelledPitch(.c, .octave0)))
		measure.append(Note(.quarter, pitch: SpelledPitch(.d, accidental: .sharp, .octave0)))
		measure.append(Note(.whole))
		#expect(measure.notes[0].count == 3)
	}

	// MARK: - replaceNotereplaceNote<T: NoteCollection>(at:with:T)

	// MARK: Failures

	// MARK: Successes

	@Test func replaceNoteInTuplet() async throws {
		let note = Note(.quarter, pitch: SpelledPitch(.a, .octave1))
		let notes = [
			Note(.sixteenth, pitch: SpelledPitch(.c, .octave1)),
			Note(.sixteenth, pitch: SpelledPitch(.c, .octave1)),
			Note(.sixteenth, pitch: SpelledPitch(.a, .octave1)),
		]

		let tuplet = try Tuplet(3, .sixteenth, notes: notes)
		measure.append(tuplet)
		measure.append(note)
		#expect(measure.noteCount[0] == 4)
		// TODO: confirm that 1/4 actually fits in a 3,.sixteenth Tuplet.
		try measure.replaceNote(at: 1, with: note)
	}

	@Test func replaceNote() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.whole)
		let note2 = Note(.eighth)
		measure.append(note1)
		measure.append(note2)

		#expect(measure.noteCount[0] == 2)
		try measure.replaceNote(at: 1, with: note1)
		let resultNote1 = try measure.note(at: 0, inSet: 0)
		let resultNote2 = try measure.note(at: 1, inSet: 0)
		#expect(resultNote1 == note1)
		#expect(resultNote2 == note1)
	}

	// MARK: - replaceNote<T: NoteCollection>(at:with:[T])

	// MARK: Failures

	@Test func replaceNoteWithInvalidNoteCollection() async throws {
		measure.append(Note(.whole))
		#expect(throws: MeasureError.invalidNoteCollection) {
			try measure.replaceNote(at: 0, with: [Note]())
		}
	}

	// MARK: Successes

	@Test func replaceNoteWithNotesPreservingTie() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.whole)
		let note2 = Note(.eighth)
		measure.append(note1)
		measure.append(note2)

		#expect(measure.noteCount[0] == 2)

		try measure.modifyTie(at: 0, requestedTieState: .begin, inSet: 0)
		try measure.replaceNote(at: 0, with: [note2, note1])
		#expect(measure.noteCount[0] == 3)

		var resultNote1 = try measure.note(at: 0, inSet: 0)
		var resultNote2 = try measure.note(at: 1, inSet: 0)

		#expect(resultNote1 == note2)
		#expect(resultNote2.tie == .begin)

		// Clear tie result before compare
		resultNote2.tie = nil
		#expect(resultNote2 == note1)

		// Note replace the note and index 1, which should
		// have a .beginAndEnd tie state.
		try measure.modifyTie(at: 0, requestedTieState: .begin, inSet: 0)
		try measure.replaceNote(at: 1, with: [note2])
		#expect(measure.noteCount[0] == 3)

		resultNote1 = try measure.note(at: 1, inSet: 0)
		resultNote2 = try measure.note(at: 2, inSet: 0)
		#expect(resultNote1.tie == .beginAndEnd)
		#expect(resultNote2.tie == .end)

		// Now insert a couple of notes at the index containing
		// the .beginAndEnd tie. This should change the tie.
		try measure.replaceNote(at: 1, with: [note1, note2])
		#expect(measure.noteCount[0] == 4)

		// Make sure we end up with 2 separate ties now.
		for note in [0, 2] {
			resultNote1 = try measure.note(at: note, inSet: 0)
			resultNote2 = try measure.note(at: note + 1, inSet: 0)
			#expect(resultNote1.tie == .begin)
			#expect(resultNote2.tie == .end)
		}
	}

	@Test func replaceNoteWithTupletPreservingTie() async throws {
		#expect(measure.notes[0].count == 0)
		let note = Note(.whole,  pitch: SpelledPitch(.c, .octave1))
		let notes = [
			Note(.sixteenth, pitch: SpelledPitch(.c, .octave1)),
			Note(.sixteenth, pitch: SpelledPitch(.c, .octave1)),
			Note(.sixteenth, pitch: SpelledPitch(.a, .octave1)),
		]
		measure.append(note)
		measure.append(note)

		let tuplet = try Tuplet(3, .sixteenth, notes: notes)
		#expect(measure.noteCount[0] == 2)
		try measure.startTie(at: 0, inSet: 0)

		try measure.replaceNote(at: 1, with: [tuplet])
		#expect(measure.noteCount[0] == 4)

		var resultNote = try measure.note(at: 1, inSet: 0)

		#expect(resultNote.tie == .end)
		// Clear tie result before compare
		resultNote.tie = nil
		#expect(resultNote == notes[0])
	}

	// MARK: - replaceNotes<T: NoteCollection>(in:with:T)

	// MARK: Failures

	@Test func replaceNotesInRangeInvalidIndex() async throws {
		let note = Note(.quarter, pitch: SpelledPitch(.a, .octave1))
		let notes = [
			Note(.sixteenth, pitch: SpelledPitch(.c, .octave1)),
			Note(.sixteenth, pitch: SpelledPitch(.c, .octave1)),
			Note(.sixteenth, pitch: SpelledPitch(.a, .octave1)),
		]
		let tuplet = try Tuplet(3, .sixteenth, notes: notes)
		measure.append(tuplet)
		measure.append(note)
		#expect(measure.noteCount[0] == 4)
		#expect(throws: MeasureError.tupletNotCompletelyCovered) {
			try self.measure.replaceNotes(in: 2 ... 3, with: note)
		}
	}

	// MARK: Successes

	@Test func replaceNotes() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.whole)
		let note2 = Note(.eighth)
		measure.append(note1)
		measure.append(note2)

		#expect(measure.noteCount[0] == 2)
		try measure.replaceNotes(in: 0 ... 1, with: note2)
		#expect(measure.noteCount[0] == 1)
	}

	// MARK: - replaceNotes<T: NoteCollection>(in:with:[T])

	// MARK: Failures

	@Test func replaceNotesInRangeInvalidTie() async throws {
		#expect(measure.notes[0].count == 0)
		var note1 = Note(.whole)
		note1.tie = .beginAndEnd
		let note2 = Note(.eighth)
		measure.append(note1)
		measure.append(note2)
		#expect(measure.noteCount[0] == 2)
		#expect(throws: MeasureError.invalidTieState) {
			try measure.replaceNotes(in: 0 ... 1, with: [note1, note2])
		}
	}

	@Test func replaceNotesInRangeWithInvalidIndexRange() async throws {
		let note = Note(.quarter, pitch: SpelledPitch(.a, .octave1))
		let notes = [
			Note(.sixteenth, pitch: SpelledPitch(.c, .octave1)),
			Note(.sixteenth, pitch: SpelledPitch(.c, .octave1)),
			Note(.sixteenth, pitch: SpelledPitch(.a, .octave1)),
		]
		let tuplet = try Tuplet(3, .sixteenth, notes: notes)
		measure.append(tuplet)
		measure.append(note)
		#expect(measure.noteCount[0] == 4)
		#expect(throws: MeasureError.tupletNotCompletelyCovered) {
			try measure.replaceNotes(in: 2 ... 3, with: [note, note])
		}
	}

	// MARK: Successes

	@Test func replaceNotesInRangeWithOtherNotes() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.whole)
		let note2 = Note(.eighth)
		measure.append(note1)
		measure.append(note2)

		#expect(measure.noteCount[0] == 2)
		try measure.replaceNotes(in: 0 ... 1, with: [note2, note1])
		let resultNote1 = try measure.note(at: 0, inSet: 0)
		let resultNote2 = try measure.note(at: 1, inSet: 0)
		#expect(measure.noteCount[0] == 2)
		#expect(resultNote1 == note2)
		#expect(resultNote2 == note1)
	}

	@Test func replaceTupletInRangeWithNotes() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let note2 = Note(.eighth, pitch: SpelledPitch(.a, .octave1))
		let note3 = Note(.eighth, pitch: SpelledPitch(.c, .octave1))

		let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
		measure.append(note3)
		measure.append(tuplet)
		try measure.startTie(at: 0, inSet: 0)
		#expect(measure.noteCount[0] == 4)
		try measure.replaceNotes(in: 1 ... 3, with: [note2, note1])
		var resultNote1 = try measure.note(at: 1, inSet: 0)
		let resultNote2 = try measure.note(at: 2, inSet: 0)
		#expect(measure.noteCount[0] == 3)
		#expect(resultNote1.tie == .end)
		resultNote1.tie = nil
		#expect(resultNote1 == note2)
		#expect(resultNote2 == note1)
	}

	// MARK: - insert(_:NoteCollection:at)

	// MARK: Failures

	@Test func insertNoteIndexOutOfRange() async throws {
		#expect(measure.notes[0].count == 0)
		#expect(throws: MeasureError.noteIndexOutOfRange) {
			try measure.insert(Note(.whole), at: 1)
		}
	}

	@Test func insertInvalidTupletIndex() async throws {
		let note1 = Note(.quarter, pitch: SpelledPitch(.a, .octave1))
		let note2 = Note(.quarter, pitch: SpelledPitch(.b, .octave1))
		measure.append(note1)
		measure.append(note2)
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]
		#expect(throws: MeasureError.invalidTupletIndex) {
			let tuplet = try Tuplet(3, .eighth, notes: notes)
			try measure.insert(tuplet, at: 1)
			try measure.insert(tuplet, at: 2)
		}
	}

	// MARK: Successes

	@Test func insertNote() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.whole)
		let note2 = Note(.eighth)
		let note3 = Note(.quarter)
		measure.append(note1)
		measure.append(note2)

		try measure.insert(note3, at: 1)
		#expect(measure.notes[0].count == 3)
		print(measure!)

		let resultNote1 = try measure.note(at: 0, inSet: 0)
		let resultNote2 = try measure.note(at: 1, inSet: 0)
		let resultNote3 = try measure.note(at: 2, inSet: 0)
		#expect(resultNote1 == note1)
		#expect(resultNote2 == note3)
		#expect(resultNote3 == note2)
	}

	@Test func insertTuplet() async throws {
		let note1 = Note(.quarter, pitch: SpelledPitch(.a, .octave1))
		let note2 = Note(.quarter, pitch: SpelledPitch(.b, .octave1))
		measure.append(note1)
		measure.append(note2)
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]

		let tuplet = try Tuplet(3, .eighth, notes: notes)
		try measure.insert(tuplet, at: 1)
		let resultNote1 = try measure.note(at: 0)
		let resultTuplet = measure.notes[0][1]  as! Tuplet
		let resultNote2 = try measure.note(at: 4)
		#expect(measure.noteCount[0] == 5)
		#expect(note1 == resultNote1)
		#expect(tuplet == resultTuplet)
		#expect(note2 == resultNote2)
	}

	// MARK: - removeNote(at)

	// MARK: Failures

	@Test func removeNoteFromTuplet() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.eighth)
		measure.append(note1)
		#expect(throws: MeasureError.removeNoteFromTuplet)  {
			let tuplet = try Tuplet(3, .eighth, notes: [note1, note1, note1])
			measure.append(tuplet)
			try measure.removeNote(at: 1)
		}
	}

	@Test func removeNoteInvalidTieStateStart() async throws {
		var note = Note(.quarter, pitch: SpelledPitch(.c, .octave1))
		note.tie = .end
		measure.append(note)
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		#expect(throws: MeasureError.invalidTieState) {
			try measure.removeNote(at: 0)
		}
	}

	@Test func removeNoteInvalidTieStateEnd() async throws {
		var note = Note(.quarter, pitch: SpelledPitch(.c, .octave1))
		note.tie = .begin
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(note)
		#expect(measure.noteCount[0] == 2)
		#expect(throws: MeasureError.invalidTieState) {
			try measure.removeNote(at: 1)
		}
	}

	// MARK: Successes

	@Test func removeNote() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.whole)
		let note2 = Note(.eighth)
		let note3 = Note(.quarter)
		measure.append(note1)
		measure.append(note2)
		measure.append(note3)

		try measure.removeNote(at: 1)
		#expect(measure.notes[0].count == 2)

		let resultNote1 = try measure.note(at: 0, inSet: 0)
		let resultNote2 = try measure.note(at: 1, inSet: 0)

		#expect(resultNote1 == note1)
		#expect(resultNote2 == note3)
	}

	@Test func removeNoteWithEndTie() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		try measure.startTie(at: 0, inSet: 0)
		try measure.removeNote(at: 1)
	}

	// MARK: - removeNotesInRange()

	// MARK: Failures

	@Test func removeNotesInRangeInvalidTieAtStart() async throws {
		#expect(measure.notes[0].count == 0)
		var note1 = Note(.whole)
		note1.tie = .end
		let note2 = Note(.eighth)
		measure.append(note1)
		measure.append(note2)
		#expect(measure.noteCount[0] == 2)
		#expect(throws: MeasureError.invalidTieState) {
			try measure.removeNotesInRange(0 ... 1)
		}
	}

	@Test func removeNotesInRangeInvalidTieAtEnd() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.whole)
		var note2 = Note(.eighth)
		note2.tie = .begin
		measure.append(note1)
		measure.append(note2)
		#expect(measure.noteCount[0] == 2)
		#expect(throws: MeasureError.invalidTieState) {
			try measure.removeNotesInRange(0 ... 1)
		}
	}

	@Test func removeNotesWithInvalidRangeStart() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]
		let tuplet = try Tuplet(3, .eighth, notes: notes)
		measure.append(tuplet)
		#expect(measure.noteCount[0] == 4)
		#expect(throws: MeasureError.tupletNotCompletelyCovered) {
			try measure.removeNotesInRange(0 ... 1)
		}
	}

	@Test func removeNotesWithInvalidRangeEnd() async throws {
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]
		let tuplet = try Tuplet(3, .eighth, notes: notes)
		measure.append(tuplet)
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		#expect(measure.noteCount[0] == 4)
		#expect(throws: MeasureError.tupletNotCompletelyCovered) {
			try measure.removeNotesInRange(2 ... 3)
		}
	}

	// MARK: Successes

	@Test func removeNotesInRange() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.whole)
		let note2 = Note(.eighth)
		let note3 = Note(.quarter)
		measure.append(note1)
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(note2)
		measure.append(note3)

		#expect(measure.notes[0].count == 7)
		try measure.removeNotesInRange(1 ... 4)
		#expect(measure.notes[0].count == 3)

		let resultNote1 = try measure.note(at: 0, inSet: 0)
		let resultNote2 = try measure.note(at: 1, inSet: 0)
		let resultNote3 = try measure.note(at: 2, inSet: 0)

		#expect(resultNote1 == note1)
		#expect(resultNote2 == note2)
		#expect(resultNote3 == note3)
	}

	@Test func removeNotesWithTupletsInRange() async throws {
		#expect(measure.notes[0].count == 0)
		let note1 = Note(.whole)
		let note2 = Note(.eighth)
		let note3 = Note(.quarter)
		measure.append(note1)
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(note2)
		measure.append(note3)
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]

		let tuplet = try Tuplet(3, .eighth, notes: notes)
		try measure.insert(tuplet, at: 4)

		#expect(measure.notes[0].count == 8)
		try measure.removeNotesInRange(1 ... 7)
		#expect(measure.notes[0].count == 3)

		let resultNote1 = try measure.note(at: 0, inSet: 0)
		let resultNote2 = try measure.note(at: 1, inSet: 0)
		let resultNote3 = try measure.note(at: 2, inSet: 0)

		#expect(resultNote1 == note1)
		#expect(resultNote2 == note2)
		#expect(resultNote3 == note3)
	}

	// MARK: - createTuplet()

	// MARK: Failures

	@Test func createTupletInvalidTupletIndexStart() async throws {
		let note1 = Note(.eighth, pitch: SpelledPitch(.a, .octave1))
		let note2 = Note(.eighth, pitch: SpelledPitch(.b, .octave1))
		let note3 = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		#expect(throws: MeasureError.invalidTupletIndex)  {
			let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
			measure.append(tuplet)
			measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
			try measure.createTuplet(3, .quarter, fromNotesInRange: 1 ... 3)
		}
	}

	@Test func createTupletInvalidTupletIndexEnd() async throws {
		let note1 = Note(.eighth, pitch: SpelledPitch(.a, .octave1))
		let note2 = Note(.eighth, pitch: SpelledPitch(.b, .octave1))
		let note3 = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		measure.append(note1)
		#expect(throws: MeasureError.invalidTupletIndex)  {
			let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
			measure.append(tuplet)
			try measure.createTuplet(3, .quarter, fromNotesInRange: 0 ... 2)
		}
	}

	@Test func createTupletNoteIndexOutOfRange() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.a, .octave1)))
		measure.append(Note(.quarter, pitch: SpelledPitch(.b, .octave1)))
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		#expect(throws: MeasureError.noteIndexOutOfRange)  {
			try measure.createTuplet(3, .quarter, fromNotesInRange: 0 ... 3)
		}
	}

	@Test func createTupletNoteInvalidNoteRange() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.a, .octave1)))
		measure.append(Note(.quarter, pitch: SpelledPitch(.b, .octave1)))
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		#expect(throws: MeasureError.noteIndexOutOfRange)  {
			try measure.createTuplet(3, .quarter, fromNotesInRange: 0 ... 3)
		}
	}

	// TODO: Find a way to reach the MeasureError.invalidNoteRange code path
	// https://github.com/drumnkyle/music-notation-core/issues/128

	// MARK: Successes

	@Test func createTuplet() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.a, .octave1)))
		measure.append(Note(.quarter, pitch: SpelledPitch(.b, .octave1)))
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))

		try measure.createTuplet(3, .quarter, fromNotesInRange: 0 ... 2)
		#expect(measure.notes[0].count == 1)
	}

	// MARK: - breakdownTuplet(at)

	// MARK: Failures

	@Test func breakDownTupletInvalidIndex() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.a, .octave1)))
		#expect(measure.noteCount[0] == 1)
		#expect(throws: MeasureError.invalidTupletIndex) {
			try measure.breakdownTuplet(at: 0)
		}
	}

	// MARK: Successes

	@Test func breakDownTuplet() async throws {
		let note1 = Note(.eighth, pitch: SpelledPitch(.a, .octave1))
		let note2 = Note(.eighth, pitch: SpelledPitch(.b, .octave1))
		let note3 = Note(.eighth, pitch: SpelledPitch(.c, .octave1))

		let tuplet = try Tuplet(3, .eighth, notes: [note1, note2, note3])
		measure.append(tuplet)

		try measure.breakdownTuplet(at: 0)
		#expect(measure.noteCount[0] == 3)

		let resultNote1 = try measure.note(at: 0)
		let resultNote2 = try measure.note(at: 1)
		let resultNote3 = try measure.note(at: 2)

		#expect(resultNote1 == note1)
		#expect(resultNote2 == note2)
		#expect(resultNote3 == note3)
	}

	// MARK: - prepTieForInsertion

	// MARK: Failures

	@Test func prepTieForInsertNoteRemoveTie() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		#expect(throws: MeasureError.invalidTieState) {
			try measure.startTie(at: 0, inSet: 0)
			let note = Note(.quarter, pitch: SpelledPitch(.c, .octave1))
			try measure.insert(note, at: 1, inSet: 0)
		}
	}

	// MARK: Successes

	@Test func prepTieForInsertNote() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))

		try measure.startTie(at: 1, inSet: 0)
		let note = Note(.quarter, pitch: SpelledPitch(.a, .octave1))
		try measure.insert(note, at: 1, inSet: 0)

		let note1 = try measure.note(at: 1, inSet: 0)
		let note2 = try measure.note(at: 2, inSet: 0)
		let note3 = try measure.note(at: 3, inSet: 0)

		#expect(note1.tie == nil)
		#expect(note2.tie != nil)
		#expect(note2.tie == .begin)
		#expect(note3.tie != nil)
		#expect(note3.tie == .end)
	}

	// MARK: - startTie(at:)

	// MARK: Successes

	@Test func startTieNoNextNote() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))

		// Only change note to .begin
		try measure.startTie(at: 0, inSet: 0)
		let note = measure.notes[0][0] as! Note
		#expect(note.tie != nil)
		#expect(note.tie == .begin)
	}

	@Test func startTieHasNextNote() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		try measure.startTie(at: 0, inSet: 0)
		let note1 = measure.notes[0][0] as! Note
		let note2 = measure.notes[0][1] as! Note
		#expect(note1.tie != nil)
		#expect(note1.tie == .begin)
		#expect(note2.tie != nil)
		#expect(note2.tie == .end)
	}

	@Test func startTieNoteAlreadyBeginningOfTie() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		try measure.startTie(at: 0, inSet: 0)
		try measure.startTie(at: 0, inSet: 0)
		let note1 = measure.notes[0][0] as! Note
		let note2 = measure.notes[0][1] as! Note
		#expect(note1.tie == .begin)
		#expect(note2.tie == .end)
	}

	@Test func startTieNextNoteInTuplet() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]

		// setup
		let tuplet = try Tuplet(3, .eighth, notes: notes)
		measure.append(tuplet)

		// test
		try measure.startTie(at: 2, inSet: 0)
		let note1 = measure.notes[0][2] as! Note
		let tuplet2 = measure.notes[0][3] as! Tuplet
		#expect(note1.tie == .begin)
		#expect(try tuplet2.note(at: 0).tie == .end)
	}

	@Test func startTieLastNoteOfTupletNoNextNote() async throws {
		// Just change to .begin
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]

		// setup
		let tupletSetup = try Tuplet(3, .eighth, notes: notes)
		measure.append(tupletSetup)

		// test
		try measure.startTie(at: 2, inSet: 0)
		try measure.startTie(at: 5, inSet: 0)
		let tuplet = measure.notes[0][3] as! Tuplet
		#expect(try tuplet.note(at: 2).tie == .begin)
	}

	@Test func startTieNoteIsEndOfAnotherTie() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]

		// setup
		let tupletSetup = try Tuplet(3, .eighth, notes: notes)
		measure.append(tupletSetup)
		try measure.startTie(at: 2, inSet: 0)

		// test
		try measure.startTie(at: 3, inSet: 0)
		let tuplet = measure.notes[0][3] as! Tuplet
		#expect(try tuplet.note(at: 0).tie == .beginAndEnd)
		#expect(try tuplet.note(at: 1).tie == .end)
	}

	@Test func startTieLastNoteOfTupletHasNextNote() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.c, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]

		// setup
		let tupletSetup = try Tuplet(3, .eighth, notes: notes)
		measure.append(tupletSetup)
		try measure.startTie(at: 2, inSet: 0)

		// test
		try measure.startTie(at: 5, inSet: 0)
		let tuplet = measure.notes[0][3] as! Tuplet
		#expect(try tuplet.note(at: 2).tie == .begin)
	}

	@Test func startTieLastNoteOfTupletNextNoteTuplet() async throws {
		let note = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		let tuplet1 = try Tuplet(3, .sixteenth, notes: [note, note, note])
		let tuplet2 = try Tuplet(5, .sixteenth, notes: [note, note, note, note, note])
		measure.append(tuplet1)
		measure.append(tuplet2)
		try measure.startTie(at: 2, inSet: 0)
		let note1 = noteFromMeasure(measure, noteIndex: 0, tupletIndex: 2)
		let note2 = noteFromMeasure(measure, noteIndex: 1, tupletIndex: 0)
		#expect(note1.tie == .begin)
		#expect(note2.tie == .end)
	}

	@Test func startTieInNestedTuplet() async throws {
		let note = Note(.eighth,
						pitch: SpelledPitch(.c, .octave1))
		let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
		let tuplet = try Tuplet(3, .eighth, notes: [triplet, note])
		measure.append(tuplet)
		measure.append(note)
		try measure.startTie(at: 3, inSet: 0)
		let note1 = try measure.note(at: 3)
		let note2 = try measure.note(at: 4)
		#expect(note1.tie == .begin)
		#expect(note2.tie == .end)
	}

	// MARK: - startTie(at:)

	// MARK: Failures

	@Test func startTieNoteHasDiffPitch() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.a, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		#expect(throws: MeasureError.notesMustHaveSamePitchesToTie) {
			try measure.startTie(at: 0, inSet: 0)
		}
	}

	@Test func startTieNextNoteInTupletDiffPitch() async throws {
		measure.append(Note(.quarter, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		let notes = [
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
			Note(.eighth, pitch: SpelledPitch(.a, .octave1)),
		]
		#expect(throws: MeasureError.notesMustHaveSamePitchesToTie) {
			let tuplet = try Tuplet(3, .eighth, notes: notes)
			measure.append(tuplet)
			try measure.startTie(at: 2, inSet: 0)
		}
	}

	// MARK: - removeTie(at:)

	// MARK: Failures

	@Test func removeTieNoNoteAtIndex() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		#expect(throws: MeasureError.noteIndexOutOfRange) {
			try measure.removeTie(at: 4, inSet: 0)
		}
	}

	// MARK: Successes

	@Test func removeTieNoTie() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		try measure.removeTie(at: 0, inSet: 0)
		let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
		let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
		#expect(firstNote.tie == nil)
		#expect(secondNote.tie == nil)
	}

	@Test func removeTieBeginOfTie() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		try setTie(at: 0)
		try measure.removeTie(at: 0, inSet: 0)
		let firstNote = noteFromMeasure(measure, noteIndex: 0, tupletIndex: nil)
		let secondNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
		#expect(firstNote.tie == nil)
		#expect(secondNote.tie == nil)
	}

	@Test func removeTieFromBeginAndEnd() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		try setTie(at: 0)
		try setTie(at: 1)
		try measure.removeTie(at: 1, inSet: 0)
		let firstNote = noteFromMeasure(measure, noteIndex: 1, tupletIndex: nil)
		let secondNote = noteFromMeasure(measure, noteIndex: 2, tupletIndex: nil)
		#expect(firstNote.tie == .end)
		#expect(secondNote.tie == nil)
	}

	@Test func removeTieBeginsInTuplet() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		let note = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))

		let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
		measure.append(tuplet)
		measure.append(note)

		try setTie(at: 6)
		try measure.removeTie(at: 6, inSet: 0)
		let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
		let secondNote = noteFromMeasure(measure, noteIndex: 5, tupletIndex: nil)
		#expect(firstNote.tie == nil)
		#expect(secondNote.tie == nil)
	}

	@Test func removeTieBeginAndEndInOneTuplet() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		let note = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
		measure.append(tuplet)
		measure.append(note)

		try setTie(at: 5)
		try measure.removeTie(at: 5, inSet: 0)
		let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
		let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 2)
		#expect(firstNote.tie == nil)
		#expect(secondNote.tie == nil)
	}

	@Test func removeTieEndsInTuplet() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		let note = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
		measure.append(tuplet)
		measure.append(note)

		try setTie(at: 4)
		try measure.removeTie(at: 4, inSet: 0)
		let firstNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 0)
		let secondNote = noteFromMeasure(measure, noteIndex: 4, tupletIndex: 1)
		#expect(firstNote.tie == nil)
		#expect(secondNote.tie == nil)
	}

	@Test func removeTieTupletToOtherTuplet() async throws {
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))
		measure.append(Note(.eighth, pitch: SpelledPitch(.c, .octave1)))

		let note = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		let tuplet = try Tuplet(3, .sixteenth, notes: [note, note, note])
		measure.append(tuplet)
		measure.append(note)

		let tuplet1 = try Tuplet(5, .sixteenth, notes: [note, note, note, note, note])
		let tuplet2 = try Tuplet(3, .sixteenth, notes: [note, note, note])
		measure.append(tuplet1)
		measure.append(tuplet2)
		try setTie(at: 11)
		try measure.removeTie(at: 11, inSet: 0)
		let firstNote = noteFromMeasure(measure, noteIndex: 6, tupletIndex: 3)
		let secondNote = noteFromMeasure(measure, noteIndex: 7, tupletIndex: 0)
		#expect(firstNote.tie == nil)
		#expect(secondNote.tie == nil)
	}

	// MARK: - noteCollectionIndexFromNoteIndex(_:)

	// MARK: Successes

	@Test func noteCollectionIndexFromNoteIndexNoTuplets() async throws {
		// NoteIndex should be the same if there are no tuplets
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))

		let index = try measure.noteCollectionIndex(fromNoteIndex: 2, inSet: 0)
		#expect(index.noteIndex == 2)
		#expect(index.tupletIndex == nil)
	}

	@Test func noteCollectionIndexFromNoteIndexWithinTuplet() async throws {
		// NoteIndex should be the beginning of the tuplet if the index specified
		// is within the tuplet, and tupletIndex should be the index of the note
		// within the tuplet
		measure.append(Note(.quarter))
		let note1 = Note(.eighth, pitch: SpelledPitch(.a, .octave1))
		let note2 = Note(.eighth, pitch: SpelledPitch(.b, .octave1))
		let note3 = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		measure.append(try Tuplet(3, .eighth, notes: [note1, note2, note3]))
		let index = try measure.noteCollectionIndex(fromNoteIndex: 2, inSet: 0)
		#expect(index.noteIndex == 1)
		#expect(index.tupletIndex != nil)
		#expect(index.tupletIndex! == 1)

		// Properly address regular note coming after a tuplet
		measure.append(Note(.eighth))
		let index2 = try measure.noteCollectionIndex(fromNoteIndex: 4, inSet: 0)
		#expect(index2.noteIndex == 2)
		#expect(index2.tupletIndex == nil)
	}

	// MARK: - hasClefAfterNote(at:) -> Bool

	// MARK: False

	@Test func hasClefAfterNoteInvalidIndex() async throws {
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		#expect(!measure.hasClefAfterNote(at: 3, inSet: 0))
	}

	@Test func hasClefAfterNoteNoClefsFirstIndex() async throws {
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		#expect(!measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	@Test func hasClefAfterNoteNoClefsMiddleIndex() async throws {
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		try measure.changeClef(Clef.treble, at: 0, inSet: 0)
		#expect(!measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	@Test func hasClefAfterNoteMiddleOfTuplet() async throws {
		let quarter = Note(.quarter)
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let tuplet = try Tuplet(3, .eighth, notes: [eighth, eighth, eighth])
		measure.append(quarter)
		measure.append(quarter)
		measure.append(tuplet)
		measure.append(eighth)
		measure.append(eighth)
		try measure.changeClef(Clef.treble, at: 3, inSet: 0)
		#expect(!measure.hasClefAfterNote(at: 3, inSet: 0))
	}

	func KNOWNISSUEtestHasClefAfterNoteMiddleOfCompoundTuplet() async throws {
		// FIXME: throws MeasureError.cannotCalculateTicksWithinCompoundTuplet error
		// https://github.com/drumnkyle/music-notation-core/issues/129
		let note = Note(.eighth)
		measure.append(note)
		let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
		let compoundTuplet = try Tuplet(5, .eighth, notes: [note, note, triplet, note])
		measure.append(compoundTuplet)
		try measure.changeClef(Clef.treble, at: 3, inSet: 0)
		#expect(!measure.hasClefAfterNote(at: 4, inSet: 0))
	}

	@Test func hasClefAfterNoteNoteOfClefChange() async throws {
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		try measure.changeClef(Clef.treble, at: 1, inSet: 0)
		#expect(!measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	@Test func hasClefAfterNoteNoteAfterClefChange() async throws {
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		try measure.changeClef(Clef.treble, at: 1, inSet: 0)
		#expect(!measure.hasClefAfterNote(at: 2, inSet: 0))
	}

	// MARK: True

	@Test func hasClefAfterNoteOneClefNoteBefore() async throws {
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		try measure.changeClef(Clef.treble, at: 2, inSet: 0)
		#expect(measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	@Test func hasClefAfterNoteMultipleClefsNoteBefore() async throws {
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		try measure.changeClef(Clef.treble, at: 2, inSet: 0)
		try measure.changeClef(Clef.treble, at: 3, inSet: 0)
		#expect(measure.hasClefAfterNote(at: 1, inSet: 0))
	}

	@Test func hasClefAfterNoteMultipleClefsNoteInMiddle() async throws {
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		try measure.changeClef(Clef.treble, at: 1, inSet: 0)
		try measure.changeClef(Clef.treble, at: 3, inSet: 0)
		#expect(measure.hasClefAfterNote(at: 2, inSet: 0))
	}

	// MARK: - cumulativeTicks(at:inSet:) throws -> Int

	// MARK: Failures

	@Test func cumulativeTicksInvalidNoteIndex() async throws {
		let note = Note(.quarter)
		measure.append(note)
		#expect(throws: MeasureError.noteIndexOutOfRange) {
			_ = try measure.cumulativeTicks(at: 2, inSet: 0)
		}
	}

	@Test func cumulativeTicksInvalidSetIndex() async throws {
		let note = Note(.quarter)
		measure.append(note)
		#expect(throws: MeasureError.noteIndexOutOfRange) {
			_ = try measure.cumulativeTicks(at: 0, inSet: 1)
		}
	}

	func KNOWNISSUEtestCumulativeTicksInMiddleOfCompoundTuplet() async throws {
		let note = Note(.eighth)
		measure.append(note)
		let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
		let compoundTuplet = try Tuplet(5, .eighth, notes: [note, note, triplet, note])
		measure.append(compoundTuplet)

		print(measure.debugDescription)
		// FIXME: there is no implementation of throw MeasureError.cannotCalculateTicksWithinCompoundTuplet in cumulativeTicks
		// https://github.com/drumnkyle/music-notation-core/issues/129
		#expect(throws: MeasureError.cannotCalculateTicksWithinCompoundTuplet) {
			_ = try measure.cumulativeTicks(at: 4)
		}
	}

	// MARK: Successes

	@Test func cumulativeTicksBeginning() async throws {
		let note = Note(.quarter)
		measure.append(note)
		measure.append(note)
		measure.append(note)
		measure.append(note, inSet: 1)
		#expect(try measure.cumulativeTicks(at: 0, inSet: 0) == 0)
		#expect(try measure.cumulativeTicks(at: 0, inSet: 1) == 0)
	}

	@Test func cumulativeTicksAllNotes() async throws {
		let quarter = Note(.quarter)
		let eighth = Note(.eighth)
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

		var currentValue = quarterTicks
		#expect(try measure.cumulativeTicks(at: 1, inSet: 0) == currentValue)
		currentValue += quarterTicks
		#expect(try measure.cumulativeTicks(at: 2, inSet: 0) == currentValue)
		currentValue += eighthTicks
		#expect(try measure.cumulativeTicks(at: 3, inSet: 0) == currentValue)
		currentValue += eighthTicks
		#expect(try measure.cumulativeTicks(at: 4, inSet: 0) == currentValue)
		currentValue += eighthTicks
		#expect(try measure.cumulativeTicks(at: 5, inSet: 0) == currentValue)
		currentValue += quarterTicks
		#expect(try measure.cumulativeTicks(at: 6, inSet: 0) == currentValue)
		var currentSet1Value = quarterTicks
		#expect(try measure.cumulativeTicks(at: 1, inSet: 0) == currentSet1Value)
		currentSet1Value += quarterTicks
		#expect(try measure.cumulativeTicks(at: 2, inSet: 0) == currentSet1Value)
	}

	@Test func cumulativeTicksBeginningOfTuplet() async throws {
		let quarter = Note(.quarter)
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))

		let tuplet = try Tuplet(3, .eighth, notes: [eighth, eighth, eighth])
		measure.append(quarter)
		measure.append(quarter)
		measure.append(tuplet)
		measure.append(eighth)
		measure.append(eighth)
		let quarterTicks = NoteDuration.quarter.ticks
		let eighthTicks = NoteDuration.eighth.ticks
		#expect(try measure.cumulativeTicks(at: 1, inSet: 0) == quarterTicks)
		#expect(try measure.cumulativeTicks(at: 2, inSet: 0) == 2 * quarterTicks)
		#expect(try measure.cumulativeTicks(at: 3, inSet: 0) == 2 * quarterTicks + 1 / 3 * tuplet.ticks)
		#expect(try measure.cumulativeTicks(at: 4, inSet: 0) == 2 * quarterTicks + 2 / 3 * tuplet.ticks)
		#expect(try measure.cumulativeTicks(at: 5, inSet: 0) == 2 * quarterTicks + tuplet.ticks)
		#expect(try measure.cumulativeTicks(at: 6, inSet: 0) == 2 * quarterTicks + tuplet.ticks + eighthTicks)
	}

	@Test func cumulativeTicksMiddleOfTuplet() async throws {
		let note = Note(.eighth)
		measure.append(note)

		let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
		measure.append(triplet)

		let ticks = try measure.cumulativeTicks(at: 2)
		#expect(ticks == note.ticks + note.ticks * 2 / 3)
	}

	func KNOWNISSUEtestCumulativeTicksAtBeginningOfCompoundTuplet() async throws {
		// FIXME: throws MeasureError.cannotCalculateTicksWithinCompoundTuplet
		// https://github.com/drumnkyle/music-notation-core/issues/129
		let note = Note(.eighth)
		measure.append(note)

		let triplet = try Tuplet(3, .eighth, notes: [note, note, note])
		let compoundTuplet = try Tuplet(5, .eighth, notes: [note, note, triplet, note])
		measure.append(compoundTuplet)
		print(measure.debugDescription) // |4/4: [1/8R, 6[1/8R, 1/8R, 3[1/8R, 1/8R, 1/8R], 1/8R]]|
		let eighthTicks = NoteDuration.eighth.ticks
		let eachCompoundTicks = compoundTuplet.ticks / Double(compoundTuplet.groupingOrder)
		let eachTripletTicks = 2 * eachCompoundTicks / Double(triplet.groupingOrder)
		var currentTicks = eighthTicks
		#expect(try measure.cumulativeTicks(at: 1, inSet: 0) == currentTicks)
		currentTicks += eachCompoundTicks
		#expect(try measure.cumulativeTicks(at: 2, inSet: 0) == currentTicks)
		currentTicks += eachCompoundTicks
		#expect(try measure.cumulativeTicks(at: 3, inSet: 0) == currentTicks)
		currentTicks += eachTripletTicks
		#expect(try measure.cumulativeTicks(at: 4, inSet: 0) == currentTicks)
		currentTicks += eachTripletTicks
		#expect(try measure.cumulativeTicks(at: 5, inSet: 0) == currentTicks)
		currentTicks += eachTripletTicks
		#expect(try measure.cumulativeTicks(at: 6, inSet: 0) == currentTicks)
	}

	// MARK: - clef(at:inSet:)

	// MARK: Successes

	@Test func oneClefAtBeginningNoOriginal() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [[note, note, note, note]])

		let newClef: Clef = .bass
		try testMeasure.changeClef(newClef, at: 0)
		#expect(try testMeasure.clef(at: 0, inSet: 0) == newClef)
		(1 ..< testMeasure.noteCount[0]).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == newClef)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
	}

	@Test func oneClefAtBeginningWithOriginal() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		let originalClef: Clef = .treble
		testMeasure.originalClef = originalClef

		let newClef: Clef = .bass
		try testMeasure.changeClef(newClef, at: 0)
		#expect(try testMeasure.clef(at: 0, inSet: 0) == newClef)
		(1 ..< testMeasure.noteCount[0]).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == newClef)
			} catch {
				Issue.record("Should not have thrown")
			}

		}
	}

	@Test func oneClefAtBeginningAnd1Other() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [[note, note, note, note]])

		let newClef1: Clef = .bass
		let newClef2: Clef = .alto
		try testMeasure.changeClef(newClef1, at: 0)
		try testMeasure.changeClef(newClef2, at: 2)
		#expect(try testMeasure.clef(at: 0, inSet: 0) == newClef1)
		#expect(try testMeasure.clef(at: 1, inSet: 0) == newClef1)
		#expect(try testMeasure.clef(at: 2, inSet: 0) == newClef2)
		(2 ..< testMeasure.noteCount[0]).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == newClef2)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
	}

	@Test func oneClefAtEndWithOriginal() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [[note, note, note, note]])
		let originalClef: Clef = .treble
		testMeasure.originalClef = originalClef

		let newClef: Clef = .bass
		try testMeasure.changeClef(newClef, at: 3)
		for index in 0 ..< 3 {
			#expect(try testMeasure.clef(at: index, inSet: 0) == originalClef)
		}
		for index in 3 ..< testMeasure.noteCount[0] {
			#expect(try testMeasure.clef(at: index, inSet: 0) == newClef)
		}
	}

	@Test func twoClefsInDifferentSetsWithOriginal() async throws {
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let sixteenth = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))

		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth],
			[eighth, eighth, eighth, eighth],
		])
		let originalClef: Clef = .treble
		testMeasure.originalClef = originalClef

		let newClef1: Clef = .bass
		let newClef2: Clef = .alto
		try testMeasure.changeClef(newClef1, at: 2, inSet: 1) // Set 0: 5th note changes. Set 1: 3rd note changes.
		try testMeasure.changeClef(newClef2, at: 7, inSet: 0) // Set 0: 8th note changes. Set 1: No change.

		// set 0
		(0 ..< 4).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == originalClef)
			} catch {
				Issue.record("Should not have thrown")
			}

		}
		(4 ..< 7).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == newClef1)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
		(7 ..< testMeasure.noteCount[0]).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == newClef2)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
		// set 1
		(0 ..< 2).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == originalClef)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
		(2 ..< testMeasure.noteCount[1]).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 1) == newClef1)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
	}

	@Test func twoClefsInDifferentSetsNoOriginal() async throws {
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let sixteenth = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))

		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth],
			[eighth, eighth, eighth, eighth],
		])

		let newClef1: Clef = .bass
		let newClef2: Clef = .alto
		try testMeasure.changeClef(newClef1, at: 2, inSet: 1) // Set 0: 5th note changes. Set 1: 3rd note changes.
		try testMeasure.changeClef(newClef2, at: 7, inSet: 0) // Set 0: 8th note changes. Set 1: No change.

		// set 0
		(0 ..< 4).forEach { index in
			#expect(throws: MeasureError.noClefSpecified) {
				_ = try testMeasure.clef(at: index, inSet: 0)
			}
		}
		(4 ..< 7).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == newClef1)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
		(7 ..< testMeasure.noteCount[0]).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == newClef2)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
		// set 1
		#expect(throws: MeasureError.noClefSpecified) { _ = try testMeasure.clef(at: 0, inSet: 1) }
		#expect(throws: MeasureError.noClefSpecified) { _ = try testMeasure.clef(at: 1, inSet: 1) }
		(2 ..< testMeasure.noteCount[1]).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 1) == newClef1)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
	}

	// MARK: Failures

	@Test func noClefsNoOriginal() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		(0 ..< testMeasure.noteCount[0]).forEach { index in
			#expect(throws: MeasureError.noClefSpecified) {
				_ = try testMeasure.clef(at: index, inSet: 0)
			}
		}
	}

	@Test func oneClefNotAtBeginningNoOriginal() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		var testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		let newClef: Clef = .alto
		try testMeasure.changeClef(.alto, at: 2)
		#expect(throws: MeasureError.noClefSpecified) {
			_ = try testMeasure.clef(at: 0, inSet: 0)
		}
		#expect(throws: MeasureError.noClefSpecified) {
			_ = try testMeasure.clef(at: 1, inSet: 0)
		}
		(2 ..< testMeasure.noteCount[0]).forEach {
			do {
				#expect(try testMeasure.clef(at: $0, inSet: 0) == newClef)
			} catch {
				Issue.record("Should not have thrown")
			}
		}
	}

	@Test func clefsInvalidNoteIndex() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		#expect(throws: MeasureError.noteIndexOutOfRange) {
			_ = try testMeasure.clef(at: 17, inSet: 0)
		}
	}

	@Test func clefsInvalidSetIndex() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let testMeasure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		#expect(throws: MeasureError.noteIndexOutOfRange) {
			_ = try testMeasure.clef(at: 0, inSet: 3)
		}
	}

	// MARK: - changeClef(_:at:inSet:) throws

	// MARK: Failures

	@Test func changeClefInvalidNoteIndex() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		#expect(throws: MeasureError.noteIndexOutOfRange) {
			try measure.changeClef(.bass, at: 5)
		}
		#expect(measure.originalClef == nil)
		#expect(measure.lastClef == nil)
		#expect(measure.clefs == [:])
	}

	@Test func changeClefInvalidSetIndex() async throws {
		let note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				note, note, note, note,
			],
		])
		#expect(throws: MeasureError.noteIndexOutOfRange) {
			try measure.changeClef(.bass, at: 3, inSet: 1)
		}
		#expect(measure.originalClef == nil)
		#expect(measure.lastClef == nil)
		#expect(measure.clefs == [:])
	}

	// MARK: Successes

	@Test func changeClefAtBeginningNoOthers() async throws {
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let quarter = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])

		try measure.changeClef(.bass, at: 0, inSet: 0)
		#expect(measure.clefs == [0: .bass])
		#expect(measure.lastClef == .bass)
		#expect(measure.originalClef == nil)
	}

	@Test func changeClefAtBeginningNoOthersSecondSet() async throws {
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let quarter = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])

		try measure.changeClef(.bass, at: 0, inSet: 1)
		#expect(measure.clefs == [0.0: .bass])
		#expect(measure.lastClef == .bass)
		#expect(measure.originalClef == nil)
	}

	@Test func changeClefAtBeginningAlreadyThere() async throws {
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let quarter = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])

		try measure.changeClef(.bass, at: 0, inSet: 1)
		try measure.changeClef(.treble, at: 0, inSet: 1)
		#expect(measure.clefs == [0: .treble])
		#expect(measure.lastClef == .treble)
		#expect(measure.originalClef == nil)
	}

	@Test func changeClefInMiddleNoOthers() async throws {
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let quarter = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])

		try measure.changeClef(.bass, at: 3, inSet: 1)
		#expect(measure.clefs == [3072: .bass])
		#expect(measure.lastClef == .bass)
		#expect(measure.originalClef == nil)
	}

	@Test func changeClefInMiddleHasBeginning() async throws {
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let quarter = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		try measure.changeClef(.treble, at: 0, inSet: 1)
		try measure.changeClef(.bass, at: 3, inSet: 1)
		#expect(measure.clefs == [0: .treble, 3072: .bass])
		#expect(measure.lastClef == .bass)
		#expect(measure.originalClef == nil)
	}

	@Test func changeClefInMiddleHasEnd() async throws {
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let quarter = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		print(measure.debugDescription)
		try measure.changeClef(.bass, at: 3, inSet: 1)
		try measure.changeClef(.treble, at: 7, inSet: 1)
		#expect(measure.clefs == [3072.0: .bass, 7168: .treble])
		#expect(measure.lastClef == .treble)
		#expect(measure.originalClef == nil)
	}

	@Test func changeClefInMiddleHasBeginningAndEnd() async throws {
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let quarter = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		try measure.changeClef(.treble, at: 0, inSet: 1)
		try measure.changeClef(.bass, at: 3, inSet: 1)
		try measure.changeClef(.treble, at: 7, inSet: 1)
		#expect(measure.clefs == [0: .treble, 3072: .bass, 7168: .treble])
		#expect(measure.lastClef == .treble)
		#expect(measure.originalClef == nil)
		print(measure.debugDescription)
	}

	@Test func changeClefWithinTuplet() async throws {
		let quarter = Note(.quarter)
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let tuplet = try Tuplet(3, .eighth, notes: [eighth, eighth, eighth])
		measure.append(quarter)
		measure.append(quarter)
		measure.append(tuplet)
		measure.append(eighth)
		measure.append(eighth)
		try measure.changeClef(.bass, at: 5, inSet: 0)
		#expect(measure.clefs == [6144: .bass])
		#expect(measure.lastClef == .bass)
		#expect(measure.originalClef == nil)
	}

	// MARK: - changeFirstClefIfNeeded(to:) -> Bool

	// MARK: Return False

	@Test func changeFirstClefIfNeededWhenNotEmpty() async throws {
		// Setup
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let quarter = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		try measure.changeClef(.bass, at: 0)

		// Test
		#expect(measure.changeFirstClefIfNeeded(to: .treble) == false)
		#expect(measure.lastClef == .bass)
		#expect(measure.originalClef == nil)
		#expect(measure.clefs == [0: .bass])
	}

	// MARK: Return True

	@Test func changeFirstClefIfNeededWhenEmtpy() async throws {
		// Setup
		let eighth = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
		let quarter = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		var measure = Measure(timeSignature: timeSignature, notes: [
			[
				quarter, quarter, quarter, quarter,
			],
			[
				eighth, eighth, eighth, eighth, eighth, eighth, eighth, eighth,
			],
		])
		// Test
		#expect(measure.changeFirstClefIfNeeded(to: .treble) == true)
		#expect(measure.lastClef == .treble)
		#expect(measure.originalClef == .treble)
		#expect(measure.clefs.isEmpty)
	}

	// MARK: - Collection Conformance

	@Test func mapEmpty() async throws {
		let mappedMeasureSlices = measure.compactMap { $0 }
		let expectedMeasureSlices: [MeasureSlice] = []
		#expect(mappedMeasureSlices.isEmpty)
		#expect(expectedMeasureSlices.isEmpty)

		let repeatedMeasure = RepeatedMeasure(timeSignature: timeSignature)
		let repeatedMappedMeasureSlices = repeatedMeasure.map { $0 }
		#expect(repeatedMappedMeasureSlices.isEmpty)
		#expect(expectedMeasureSlices.isEmpty)
	}

	@Test func mapSingleNoteSet() async throws {
		measure.append(Note(.quarter))
		measure.append(Note(.quarter))
		measure.append(Note(.eighth))
		measure.append(Note(.eighth))
		measure.append(Note(.quarter))

		let repeatedMeasure = RepeatedMeasure(
			timeSignature: timeSignature,
			notes: [[Note(.quarter), Note(.quarter), Note(.eighth), Note(.eighth), Note(.quarter)]]
		)
		let repeatedMappedMeasureSlices = repeatedMeasure.map { $0 }

		let mappedMeasureSlices = measure.compactMap { $0 }
		let expectedMeasureSlices: [[MeasureSlice]] = [
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(.quarter))],
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(.quarter))],
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(.eighth))],
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(.eighth))],
			[MeasureSlice(noteSetIndex: 0, noteCollection: Note(.quarter))],
		]
		var count = 0
		zip(mappedMeasureSlices, expectedMeasureSlices).forEach {
			#expect($0 == $1)
			count += 1
		}
		#expect(count == expectedMeasureSlices.count)

		var repeatedCount = 0
		zip(repeatedMappedMeasureSlices, expectedMeasureSlices).forEach {
			#expect($0 == $1)
			repeatedCount += 1
		}
		#expect(repeatedCount == expectedMeasureSlices.count)
	}

	@Test func mapMultipleNoteSets() async throws {
		measure.append(Note(.quarter), inSet: 0)
		measure.append(Note(.sixteenth), inSet: 1)
		measure.append(Note(.quarter), inSet: 0)
		measure.append(Note(.thirtySecond), inSet: 1)
		measure.append(Note(.eighth), inSet: 0)
		measure.append(Note(.quarter), inSet: 1)
		measure.append(Note(.eighth), inSet: 0)
		measure.append(Note(.quarter), inSet: 1)
		measure.append(Note(.quarter), inSet: 0)
		measure.append(Note(.quarter), inSet: 1)
		measure.append(Note(.whole), inSet: 1)
		measure.append(Note(.whole), inSet: 1)

		let repeatedMeasure = RepeatedMeasure(
			timeSignature: timeSignature,
			notes: [
				[
					Note(.quarter),
					Note(.quarter),
					Note(.eighth),
					Note(.eighth),
					Note(.quarter),

				],
				[
					Note(.sixteenth),
					Note(.thirtySecond),
					Note(.quarter),
					Note(.quarter),
					Note(.quarter),
					Note(.whole),
					Note(.whole),
				],
			]
		)
		let repeatedMappedMeasureSlices = repeatedMeasure.map { $0 }

		let mappedMeasureSlices = measure.compactMap { $0 }
		let expectedMeasureSlices: [[MeasureSlice]] = [
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(.quarter)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.sixteenth)),

			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(.quarter)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.thirtySecond)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(.eighth)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.quarter)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(.eighth)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.quarter)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(.quarter)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.quarter)),
			],
			[
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.whole)),
			],
			[
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.whole)),
			],
		]
		var count = 0
		zip(mappedMeasureSlices, expectedMeasureSlices).forEach {
			#expect($0 == $1)
			count += 1
		}
		#expect(count == expectedMeasureSlices.count)

		var repeatedCount = 0
		zip(repeatedMappedMeasureSlices, expectedMeasureSlices).forEach {
			#expect($0 == $1)
			repeatedCount += 1
		}
		#expect(repeatedCount == expectedMeasureSlices.count)
	}

	@Test func reversed() async throws {
		measure.append(Note(.whole), inSet: 0)
		measure.append(Note(.thirtySecond), inSet: 1)
		measure.append(Note(.quarter), inSet: 0)
		measure.append(Note(.sixtyFourth), inSet: 1)
		measure.append(Note(.eighth), inSet: 0)
		measure.append(Note(.oneTwentyEighth), inSet: 1)
		measure.append(Note(.sixteenth), inSet: 0)
		measure.append(Note(.twoFiftySixth), inSet: 1)

		let repeatedMeasure = RepeatedMeasure(
			timeSignature: timeSignature,
			notes: [
				[
					Note(.whole),
					Note(.quarter),
					Note(.eighth),
					Note(.sixteenth),
				],
				[
					Note(.thirtySecond),
					Note(.sixtyFourth),
					Note(.oneTwentyEighth),
					Note(.twoFiftySixth),
				],
			]
		)
		let repeatedReversedMeasureSlices = repeatedMeasure.reversed()

		let reversedMeasureSlices = measure.reversed()
		let expectedMeasureSlices: [[MeasureSlice]] = [
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(.sixteenth)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.twoFiftySixth)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(.eighth)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.oneTwentyEighth)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(.quarter)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.sixtyFourth)),
			],
			[
				MeasureSlice(noteSetIndex: 0, noteCollection: Note(.whole)),
				MeasureSlice(noteSetIndex: 1, noteCollection: Note(.thirtySecond)),
			],
		]

		var count = 0
		zip(reversedMeasureSlices, expectedMeasureSlices).forEach {
			#expect($0 == $1)
			count += 1
		}
		#expect(count == expectedMeasureSlices.count)

		var repeatedCount = 0
		zip(repeatedReversedMeasureSlices, expectedMeasureSlices).forEach {
			#expect($0 == $1)
			repeatedCount += 1
		}
		#expect(repeatedCount == expectedMeasureSlices.count)
	}

	@Test func iterator() async throws {
		measure.append(Note(.whole), inSet: 0)
		measure.append(Note(.thirtySecond), inSet: 1)
		measure.append(Note(.quarter), inSet: 0)
		measure.append(Note(.eighth), inSet: 1)

		let repeatedMeasure = RepeatedMeasure(
			timeSignature: timeSignature,
			notes: [
				[Note(.whole), Note(.quarter)],
				[Note(.thirtySecond), Note(.eighth)],
			]
		)

		let expectedMeasureSlice1: [MeasureSlice] = [
			MeasureSlice(noteSetIndex: 0, noteCollection: Note(.whole)),
			MeasureSlice(noteSetIndex: 1, noteCollection: Note(.thirtySecond)),
		]
		let expectedMeasureSlice2: [MeasureSlice] = [
			MeasureSlice(noteSetIndex: 0, noteCollection: Note(.quarter)),
			MeasureSlice(noteSetIndex: 1, noteCollection: Note(.eighth)),
		]
		let expectedMeasureSlices = [expectedMeasureSlice1, expectedMeasureSlice2]
		var iterator = measure.makeIterator()
		var iteratorCount = 0
		while let next = iterator.next() {
			#expect(next == expectedMeasureSlices[iteratorCount])
			iteratorCount += 1
		}
		#expect(iteratorCount == expectedMeasureSlices.count)

		var repeatedIterator = repeatedMeasure.makeIterator()
		var repeatedIteratorCount = 0
		while let next = repeatedIterator.next() {
			#expect(next == expectedMeasureSlices[repeatedIteratorCount])
			repeatedIteratorCount += 1
		}
		#expect(repeatedIteratorCount == expectedMeasureSlices.count)
	}

	// MARK: - Helpers

	private func setTie(at index: Int, functionName: String = #function, lineNum: Int = #line) throws {
		try measure.startTie(at: index, inSet: 0)
		let noteCollectionIndex1 = try measure.noteCollectionIndex(fromNoteIndex: index, inSet: 0)
		let noteCollectionIndex2 = try measure.noteCollectionIndex(fromNoteIndex: index + 1, inSet: 0)
		let firstNote = noteFromMeasure(measure, noteIndex: noteCollectionIndex1.noteIndex,
										tupletIndex: noteCollectionIndex1.tupletIndex)
		let secondNote = noteFromMeasure(measure, noteIndex: noteCollectionIndex2.noteIndex,
										 tupletIndex: noteCollectionIndex2.tupletIndex)
		#expect(firstNote.tie == .begin || firstNote.tie == .beginAndEnd)
		#expect(secondNote.tie == .end || secondNote.tie == .beginAndEnd)
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
