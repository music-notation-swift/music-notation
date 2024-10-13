//
//	StaffTests.swift
//	MusicNotation
//
//	Created by Kyle Sherman on 2016-09-05.
//	Copyright © 2015 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class StaffTests {
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

    init() {
        staff = Staff(clef: Constant.standardClef, instrument: Instrument())
        let timeSignature = TimeSignature(numerator: 4, denominator: 4, tempo: 120)
        let key = Key(noteLetter: .c)
        let note = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
        let note2 = Note(.sixteenth, pitch: SpelledPitch(.a, .octave1))
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

    @Test func insertMeasureInvalidIndex() async throws {
        let measure = Measure(
            timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
            key: Key(noteLetter: .c)
        )

        #expect(throws: StaffError.measureIndexOutOfRange) {
            try staff.insertMeasure(measure, at: 17)
        }
    }

    @Test func insertMeasureInRepeatedMeasures() async throws {
        let measure = Measure(
            timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
            key: Key(noteLetter: .c)
        )

        #expect(throws: MeasureRepeatError.cannotModifyRepeatedMeasures) {
            try staff.insertMeasure(measure, at: 10, beforeRepeat: true)
        }
    }

    // MARK: Successes

    @Test func description() async throws {
        #expect(staff!.debugDescription == "staff(treble Instrument(lineCount: 0, chromaticTransposition: 0, octaveTransposition: 0) |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1, 1/16c1, 1/16c1]|, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 2, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 3, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16a1, 3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1]|, |4/4: [3[1/16a1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|)")
    }

    @Test func insertMeasureNoRepeat() async throws {
        let measure = Measure(
            timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
            key: Key(noteLetter: .c)
        )

        try staff.insertMeasure(measure, at: 1)
        let addedMeasure = try staff.measure(at: 1)
        let beforeMeasure = try staff.measure(at: 0)
        let afterMeasure = try staff.measure(at: 2)
        #expect(Measure(addedMeasure) == changedClef(of: measure))
        // Initial measure don't have the clef set before being added to the staff
        // But then after they are in the staff, they do have the clef set.
        #expect(Measure(beforeMeasure) == changedClef(of: measure1))
        #expect(Measure(afterMeasure) == changedClef(of: measure2))
    }

    @Test func insertMeasureNoRepeatAtEnd() async throws {
        let measure = Measure(
            timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
            key: Key(noteLetter: .c)
        )

        try staff.insertMeasure(measure, at: 14)
        let addedMeasure = try staff.measure(at: 14)
        let beforeMeasure = try staff.measure(at: 13)
        let afterMeasure = try staff.measure(at: 15)
        #expect(Measure(addedMeasure) == changedClef(of: measure))
        #expect(Measure(beforeMeasure) == changedClef(of: measure6))
        #expect(Measure(afterMeasure) == changedClef(of: measure3))
    }

    @Test func insertMeasureInRepeat() async throws {
        var measure = Measure(
            timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
            key: Key(noteLetter: .c)
        )
        measure.lastClef = staff.clef
        measure.originalClef = staff.clef

        try staff.insertMeasure(measure, at: 5, beforeRepeat: false)
        let actualRepeat = try staff.measureRepeat(at: 5)
        let expectedRepeat = try MeasureRepeat(measures: [measure, measure4])
        #expect(actualRepeat == changedClef(ofAllMeasuresInRepeat: expectedRepeat))
    }

    @Test func insertMeasureInRepeatAtEnd() async throws {
        var measure = Measure(
            timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
            key: Key(noteLetter: .c)
        )
        measure.lastClef = staff.clef
        measure.originalClef = staff.clef

        try staff.insertMeasure(measure, at: 6, beforeRepeat: false)
        let actualRepeat = try staff.measureRepeat(at: 5)
        let expectedRepeat = try MeasureRepeat(measures: [measure4, measure])
        #expect(actualRepeat == changedClef(ofAllMeasuresInRepeat: expectedRepeat))
    }

    @Test func insertMeasureBeforeRepeat() async throws {
        let measure = Measure(
            timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
            key: Key(noteLetter: .c)
        )

        try staff.insertMeasure(measure, at: 5, beforeRepeat: true)
        _ = try staff.measureRepeat(at: 6)
        let addedMeasure = try staff.measure(at: 5)
        let beforeMeasure = try staff.measure(at: 4)
        #expect(Measure(addedMeasure) == changedClef(of: measure))
        #expect(Measure(beforeMeasure) == changedClef(of: measure5))
    }

    @Test func insertMeasureNoRepeatWithWrongFlag() async throws {
        let measure = Measure(
            timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
            key: Key(noteLetter: .c)
        )

        // Ignores the flag, since it's not a repeat
        try staff.insertMeasure(measure, at: 1, beforeRepeat: false)
        let addedMeasure = try staff.measure(at: 1)
        let beforeMeasure = try staff.measure(at: 0)
        let afterMeasure = try staff.measure(at: 2)
        #expect(Measure(addedMeasure) == changedClef(of: measure))
        #expect(Measure(beforeMeasure) == changedClef(of: measure1))
        #expect(Measure(afterMeasure) == changedClef(of: measure2))
    }

    @Test func insertMeasureInMeasureRepeatWithWrongFlag() async throws {
        var measure = Measure(
            timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
            key: Key(noteLetter: .c)
        )
        measure.lastClef = staff.clef
        measure.originalClef = staff.clef

        // Ignores the flag since you can only insert it into the repeat
        try staff.insertMeasure(measure, at: 6, beforeRepeat: true)
        let actualRepeat = try staff.measureRepeat(at: 5)
        let expectedRepeat = try MeasureRepeat(measures: [measure4, measure])
        #expect(actualRepeat == changedClef(ofAllMeasuresInRepeat: expectedRepeat))
    }

    // MARK: - insertRepeat(_:, at:)

    // MARK: Failures

    @Test func insertRepeatInvalidIndex() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            let measureRepeat = try MeasureRepeat(measures: [measure4])
            try staff.insertRepeat(measureRepeat, at: 50)
        }
    }

    @Test func insertRepeatInRepeat() async throws {
        #expect(throws: StaffError.cannotInsertRepeatWhereOneAlreadyExists) {
            let measureRepeat = try MeasureRepeat(measures: [measure5])
            try staff.insertRepeat(measureRepeat, at: 6)
        }
    }

    // MARK: Successes

    @Test func insertRepeatSingleMeasure() async throws {
        let measureRepeat = try MeasureRepeat(measures: [measure4])
        try staff.insertRepeat(measureRepeat, at: 1)
        let beforeRepeat = try staff.measure(at: 0)
        let actualRepeat = try staff.measureRepeat(at: 1)
        let afterRepeat = try staff.measure(at: 3)
        #expect(Measure(beforeRepeat) == changedClef(of: measure1))
        measure2.originalClef = staff.clef
        measure2.lastClef = staff.clef
        #expect(Measure(afterRepeat) == changedClef(of: measure2))
        #expect(actualRepeat == changedClef(ofAllMeasuresInRepeat: measureRepeat))
    }

    @Test func insertRepeatBeforeOtherRepeat() async throws {
        let measureRepeat = try MeasureRepeat(measures: [measure5])
        try staff.insertRepeat(measureRepeat, at: 5)
        let beforeRepeat = try staff.measure(at: 4)
        let actualRepeat = try staff.measureRepeat(at: 5)
        let afterRepeat = try staff.measureRepeat(at: 7)
        #expect(Measure(beforeRepeat) == changedClef(of: measure5))
        #expect(afterRepeat == changedClef(ofAllMeasuresInRepeat: repeat1))
        #expect(actualRepeat == changedClef(ofAllMeasuresInRepeat: measureRepeat))
    }

    // MARK: - startTieFromNote(at:, inMeasureAt:)

    // MARK: Failures

    @Test func startTieFailIfNoteIndexInvalid() async throws {
        #expect(throws: StaffError.noteIndexOutOfRange) {
            try staff.startTieFromNote(at: 10, inMeasureAt: 0)
        }
    }

    @Test func startTieFailIfMeasureIndexInvalid() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            try staff.startTieFromNote(at: 0, inMeasureAt: 25)
        }
    }

    @Test func startTieFailIfNoNextNote() async throws {
        #expect(throws: StaffError.noNextNoteToTie) {
            try staff.startTieFromNote(at: 4, inMeasureAt: 16)
        }
    }

    @Test func startTieFailIfLastNoteOfSingleMeasureRepeat() async throws {
        // Reason: can't finish in the next measure
        #expect(throws: StaffError.repeatedMeasureCannotHaveTie) {
            try staff.startTieFromNote(at: 3, inMeasureAt: 5)
        }
    }

    @Test func startTieFailIfLastNoteInLastMeasureOfMultiMeasureRepeat() async throws {
        #expect(throws: StaffError.repeatedMeasureCannotHaveTie) {
            try staff.startTieFromNote(at: 3, inMeasureAt: 8)
        }
    }

    @Test func startTieFailIfNotesWithinRepeatAfterTheFirstCount() async throws {
        #expect(throws: StaffError.repeatedMeasureCannotHaveTie) {
            try staff.startTieFromNote(at: 0, inMeasureAt: 9)
        }
    }

    @Test func startTieAcrossMeasuresTupletToNoteDiffPitch() async throws {
        #expect(throws: StaffError.notesMustHaveSamePitchesToTie) {
            try staff.startTieFromNote(at: 6, inMeasureAt: 14)
        }
    }

    @Test func startTieAcrossMeasuresNoteToTupletDiffPitch() async throws {
        #expect(throws: StaffError.notesMustHaveSamePitchesToTie) {
            try staff.startTieFromNote(at: 7, inMeasureAt: 15)
        }
    }

    // MARK: Successes

    @Test func startTieWithinMeasureIfHasNextNote() async throws {
        let firstNoteIndex = 0
        let firstMeasureIndex = 0
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let measure = staff.notesHolders[firstMeasureIndex] as! Measure
        let firstNote = measure.notes[0][firstNoteIndex] as! Note
        let secondNote = measure.notes[0][firstNoteIndex + 1] as! Note
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    @Test func startTieWithinMeasureIfAlreadyEndOfTie() async throws {
        let firstNoteIndex = 0
        let firstMeasureIndex = 0
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        try staff.startTieFromNote(at: firstNoteIndex + 1, inMeasureAt: firstMeasureIndex)
        let measure = staff.notesHolders[firstMeasureIndex] as! Measure
        let firstNote = measure.notes[0][firstNoteIndex] as! Note
        let secondNote = measure.notes[0][firstNoteIndex + 1] as! Note
        let thirdNote = measure.notes[0][firstNoteIndex + 2] as! Note
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .beginAndEnd)
        #expect(thirdNote.tie == .end)
    }

    @Test func startTieWithinMeasureTupletToTuplet() async throws {
        let firstNoteIndex = 2
        let firstMeasureIndex = 13
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let measure = staff.notesHolders[7] as! Measure
        let firstNote = try (measure.notes[0][0] as! Tuplet).note(at: 2)
        let secondNote = try (measure.notes[0][1] as! Tuplet).note(at: 0)
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    @Test func startTieAcrossMeasuresNoteToNote() async throws {
        let firstNoteIndex = 4
        let firstMeasureIndex = 1
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
        let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
        let firstNote = firstMeasure.notes[0][2] as! Note
        let secondNote = secondMeasure.notes[0][0] as! Note
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    @Test func startTieAcrossMeasuresNoteToTuplet() async throws {
        let firstNoteIndex = 3
        let firstMeasureIndex = 3
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
        let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
        let firstNote = firstMeasure.notes[0][3] as! Note
        let secondNote = try (secondMeasure.notes[0][0] as! Tuplet).note(at: 0)
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    @Test func startTieAcrossMeasuresTupletToNote() async throws {
        let firstNoteIndex = 6
        let firstMeasureIndex = 2
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
        let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
        let firstNote = try (firstMeasure.notes[0][4] as! Tuplet).note(at: 2)
        let secondNote = secondMeasure.notes[0][0] as! Note
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    @Test func startTieAcrossMeasuresTupletToTuplet() async throws {
        let firstNoteIndex = 6
        let firstMeasureIndex = 0
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let firstMeasure = staff.notesHolders[firstMeasureIndex] as! Measure
        let secondMeasure = staff.notesHolders[firstMeasureIndex + 1] as! Measure
        let firstNote = try (firstMeasure.notes[0][4] as! Tuplet).note(at: 2)
        let secondNote = try (secondMeasure.notes[0][0] as! Tuplet).note(at: 0)
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    @Test func startTieBothNotesWithinSingleMeasureRepeat() async throws {
        let firstNoteIndex = 0
        let firstMeasureIndex = 5
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let firstMeasure = (staff.notesHolders[firstMeasureIndex] as! MeasureRepeat).measures[0]
        let firstNote = firstMeasure.notes[0][firstNoteIndex] as! Note
        let secondNote = firstMeasure.notes[0][firstNoteIndex + 1] as! Note
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    @Test func startTieBothNotesWithinMultiMeasureRepeat() async throws {
        let firstNoteIndex = 0
        let firstMeasureIndex = 7
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let firstMeasure = (staff.notesHolders[6] as! MeasureRepeat).measures[0]
        let firstNote = firstMeasure.notes[0][firstNoteIndex] as! Note
        let secondNote = firstMeasure.notes[0][firstNoteIndex + 1] as! Note
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    @Test func startTieNotesFromContiguousMeasuresWithinRepeat() async throws {
        let firstNoteIndex = 3
        let firstMeasureIndex = 7
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let measureRepeat = staff.notesHolders[6] as! MeasureRepeat
        let firstMeasure = measureRepeat.measures[0]
        let secondMeasure = measureRepeat.measures[1]
        let firstNote = firstMeasure.notes[0][firstNoteIndex] as! Note
        let secondNote = secondMeasure.notes[0][0] as! Note
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    // MARK: - removeTieFromNote(at:, inMeasureAt:)

    // MARK: Failures

    @Test func removeTieFailIfNoteIndexInvalid() async throws {
        #expect(throws: StaffError.noteIndexOutOfRange) {
            try staff.removeTieFromNote(at: 10, inMeasureAt: 0)
        }
    }

    @Test func removeTieFailIfMeasureIndexInvalid() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            try staff.removeTieFromNote(at: 0, inMeasureAt: 25)
        }
    }

    // MARK: Successes

    @Test func removeTieIfNotTied() async throws {
        try staff.removeTieFromNote(at: 0, inMeasureAt: 0)
        let measure = staff.notesHolders[0] as! Measure
        let firstNote = measure.notes[0][0] as! Note
        #expect(firstNote.tie == nil)
    }

    @Test func removeTieIfEndOfTie() async throws {
        try staff.startTieFromNote(at: 0, inMeasureAt: 0)
        try staff.removeTieFromNote(at: 1, inMeasureAt: 0)
        let measure = staff.notesHolders[0] as! Measure
        let firstNote = measure.notes[0][0] as! Note
        let secondNote = measure.notes[0][1] as! Note
        #expect(firstNote.tie == nil)
        #expect(secondNote.tie == nil)
    }

    @Test func removeTieBeginIfBeginAndEndOfTie() async throws {
        try staff.startTieFromNote(at: 0, inMeasureAt: 0)
        try staff.startTieFromNote(at: 1, inMeasureAt: 0)
        try staff.removeTieFromNote(at: 1, inMeasureAt: 0)
        let measure = staff.notesHolders[0] as! Measure
        let firstNote = measure.notes[0][0] as! Note
        let secondNote = measure.notes[0][1] as! Note
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
    }

    @Test func removeTieWithinMeasureNoteToNote() async throws {
        let firstNoteIndex = 0
        let firstMeasureIndex = 0
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let measure = staff.notesHolders[firstMeasureIndex] as! Measure
        let firstNote = measure.notes[0][firstNoteIndex] as! Note
        let secondNote = measure.notes[0][firstNoteIndex + 1] as! Note
        #expect(firstNote.tie == nil)
        #expect(secondNote.tie == nil)
    }

    @Test func removeTieWithinMeasureWithinTuplet() async throws {
        let firstNoteIndex = 4
        let firstMeasureIndex = 0
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let measure = staff.notesHolders[firstMeasureIndex] as! Measure
        let firstNote = try (measure.notes[0][firstNoteIndex] as! Tuplet).note(at: 0)
        let secondNote = try (measure.notes[0][firstNoteIndex] as! Tuplet).note(at: 1)
        #expect(firstNote.tie == nil)
        #expect(secondNote.tie == nil)
    }

    @Test func removeTieWithinMeasureFromTupletToNote() async throws {
        let firstNoteIndex = 2
        let firstMeasureIndex = 1
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let measure = staff.notesHolders[firstMeasureIndex] as! Measure
        let firstNote = try (measure.notes[0][0] as! Tuplet).note(at: firstNoteIndex)
        let secondNote = measure.notes[0][1] as! Note
        #expect(firstNote.tie == nil)
        #expect(secondNote.tie == nil)
    }

    @Test func removeTieWithinMeasureFromTupletToNewTuplet() async throws {
        let firstNoteIndex = 2
        let firstMeasureIndex = 13
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let measure = staff.notesHolders[7] as! Measure
        let firstNote = try (measure.notes[0][0] as! Tuplet).note(at: firstNoteIndex)
        let secondNote = try (measure.notes[0][1] as! Tuplet).note(at: 0)
        #expect(firstNote.tie == nil)
        #expect(secondNote.tie == nil)
    }

    @Test func removeTieAcrossMeasuresFromTupletToNote() async throws {
        let firstNoteIndex = 4
        let firstMeasureIndex = 2
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let measure1 = staff.notesHolders[firstMeasureIndex] as! Measure
        let measure2 = staff.notesHolders[firstMeasureIndex + 1] as! Measure
        let firstNote = try (measure1.notes[0][4] as! Tuplet).note(at: 2)
        let secondNote = measure2.notes[0][0] as! Note
        #expect(firstNote.tie == nil)
        #expect(secondNote.tie == nil)
    }

    @Test func removeTieAcrosssMeasuresFromTupletToNewTuplet() async throws {
        let firstNoteIndex = 6
        let firstMeasureIndex = 0
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        try staff.removeTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        let measure1 = staff.notesHolders[firstMeasureIndex] as! Measure
        let measure2 = staff.notesHolders[firstMeasureIndex + 1] as! Measure
        let firstNote = try (measure1.notes[0][4] as! Tuplet).note(at: 2)
        let secondNote = try (measure2.notes[0][0] as! Tuplet).note(at: 0)
        #expect(firstNote.tie == nil)
        #expect(secondNote.tie == nil)
    }

    @Test func removeTieFromNoteThatIsBeginAndEnd() async throws {
        let firstNoteIndex = 0
        let firstMeasureIndex = 0
        try staff.startTieFromNote(at: firstNoteIndex, inMeasureAt: firstMeasureIndex)
        try staff.startTieFromNote(at: firstNoteIndex + 1, inMeasureAt: firstMeasureIndex)
        try staff.removeTieFromNote(at: firstNoteIndex + 1, inMeasureAt: firstMeasureIndex)
        let measure = staff.notesHolders[firstMeasureIndex] as! Measure
        let firstNote = measure.notes[0][firstNoteIndex] as! Note
        let secondNote = measure.notes[0][firstNoteIndex + 1] as! Note
        let thirdNote = measure.notes[0][firstNoteIndex + 2] as! Note
        #expect(firstNote.tie == .begin)
        #expect(secondNote.tie == .end)
        #expect(thirdNote.tie == nil)
    }

    // MARK: - notesHolderIndexFromMeasureIndex(_: Int) -> (Int, Int?)

    // MARK: Failures

    @Test func notesHolderIndexForOutOfRangeMeasureIndex() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            _ = try staff.notesHolderIndexFromMeasureIndex(20)
        }
    }

    // MARK: Successes

    @Test func notesHolderIndexForNoRepeats() async throws {
        let indexes = try staff.notesHolderIndexFromMeasureIndex(2)
        #expect(indexes.notesHolderIndex == 2)
        #expect(indexes.repeatMeasureIndex == nil)
    }

    @Test func notesHolderIndexForOriginalRepeatedMeasure() async throws {
        let indexes = try staff.notesHolderIndexFromMeasureIndex(8)
        #expect(indexes.notesHolderIndex == 6)
        #expect(indexes.repeatMeasureIndex == 1)
    }

    @Test func notesHolderIndexForRepeatedMeasure() async throws {
        let indexes = try staff.notesHolderIndexFromMeasureIndex(9)
        #expect(indexes.notesHolderIndex == 6)
        #expect(indexes.repeatMeasureIndex == 2)
    }

    @Test func notesHolderIndexForAfterRepeat() async throws {
        let indexes = try staff.notesHolderIndexFromMeasureIndex(13)
        #expect(indexes.notesHolderIndex == 7)
        #expect(indexes.repeatMeasureIndex == nil)
    }

    // MARK: - notesHolderAtMeasureIndex(_: Int) -> NotesHolder

    // MARK: Failures

    @Test func notesHolderAtMeasureIndexForInvalidIndexNegative() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            _ = try staff.notesHolderAtMeasureIndex(-3)
        }
    }

    @Test func notesHolderAtMeasureIndexForInvalidIndexTooLarge() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            _ = try staff.notesHolderAtMeasureIndex(99)
        }
    }

    // MARK: Successes

    @Test func notesHolderAtMeasureIndexForFirstMeasureThatIsRepeated() async throws {
        let actual = try staff.notesHolderAtMeasureIndex(5)
        let expected = staff.notesHolders[5]
        #expect(actual as? MeasureRepeat == expected as? MeasureRepeat)
    }

    @Test func notesHolderAtMeasureIndexForSecondMeasureThatIsRepeated() async throws {
        let actual = try staff.notesHolderAtMeasureIndex(8)
        let expected = staff.notesHolders[6]
        #expect(actual as? MeasureRepeat == expected as? MeasureRepeat)
    }

    @Test func notesHolderAtMeasureIndexForRepeatedMeasureInFirstRepeat() async throws {
        let actual = try staff.notesHolderAtMeasureIndex(6)
        let expected = staff.notesHolders[5]
        #expect(actual as? MeasureRepeat == expected as? MeasureRepeat)
    }

    @Test func notesHolderAtMeasureIndexForRepeatedMeasureInSecondRepeat() async throws {
        let actual = try staff.notesHolderAtMeasureIndex(12)
        let expected = staff.notesHolders[6]
        #expect(actual as? MeasureRepeat == expected as? MeasureRepeat)
    }

    @Test func notesHolderAtMeasureIndexForRegularMeasure() async throws {
        let actual = try staff.notesHolderAtMeasureIndex(0)
        let expected = staff.notesHolders[0]
        #expect(actual as? Measure == expected as? Measure)
    }

    // MARK: - measure(at:_: Int) -> ImmutableMeasure

    // MARK: Failures

    @Test func measureAtIndexForInvalidIndexNegative() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            _ = try staff.measure(at: -1)
        }
    }

    @Test func measureAtIndexForInvalidIndexTooLarge() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            _ = try staff.measure(at: staff.notesHolders.count + 10)
        }
    }

    // MARK: Successes

    @Test func measureAtIndexForRegularMeasure() async throws {
        let measure = try staff.measure(at: 1)
        #expect(measure as? Measure == staff.notesHolders[1] as? Measure)
    }

    @Test func measureAtIndexForMeasureThatRepeats() async throws {
        let measureThatRepeats = try staff.measure(at: 5)
        let measureRepeat = staff.notesHolders[5] as! MeasureRepeat
        #expect(measureThatRepeats as? RepeatedMeasure == measureRepeat.expand()[0] as? RepeatedMeasure)
    }

    @Test func measureAtIndexForRepeatedMeasure() async throws {
        let repeatedMeasure = try staff.measure(at: 6)
        let measureRepeat = staff.notesHolders[5] as! MeasureRepeat
        let expectedMeasure = measureRepeat.expand()[1]
        #expect(expectedMeasure as? RepeatedMeasure != nil)
        #expect(repeatedMeasure as? RepeatedMeasure == expectedMeasure as? RepeatedMeasure)
    }

    // MARK: - measureRepeat(at:_: Int) -> MeasureRepeat

    // MARK: Failures

    @Test func measureRepeatAtIndexForInvalidIndexNegative() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            _ = try staff.measureRepeat(at: -1)
        }
    }

    @Test func measureRepeatAtIndexForInvalidIndexTooLarge() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            _ = try staff.measureRepeat(at: staff.notesHolders.count + 10)
        }
    }

    // MARK: Successes

    @Test func measureRepeatAtIndexForMeasureNotPartOfRepeat() async throws {
        let measureRepeat = try staff.measureRepeat(at: 1)
        #expect(measureRepeat == nil)
    }

    @Test func measureRepeatAtIndexForFirstMeasureThatIsRepeated() async throws {
        let measureRepeat = try staff.measureRepeat(at: 5)
        let expected = staff.notesHolders[5] as! MeasureRepeat
        #expect(measureRepeat == expected)
    }

    @Test func measureRepeatAtIndexForSecondMeasureThatIsRepeated() async throws {
        let measureRepeat = try staff.measureRepeat(at: 8)
        let expected = staff.notesHolders[6] as! MeasureRepeat
        #expect(measureRepeat == expected)
    }

    @Test func measureRepeatAtIndexForRepeatedMeasureInFirstRepeat() async throws {
        let measureRepeat = try staff.measureRepeat(at: 6)
        let expected = staff.notesHolders[5] as! MeasureRepeat
        #expect(measureRepeat == expected)
    }

    @Test func measureRepeatAtIndexForRepeatedMeasureInSecondRepeat() async throws {
        let measureRepeat = try staff.measureRepeat(at: 12)
        let expected = staff.notesHolders[6] as! MeasureRepeat
        #expect(measureRepeat == expected)
    }

    // MARK: - replaceMeasure(at:, with:)

    // MARK: Failures

    @Test func replaceRepeatedMeasure() async throws {
        #expect(throws: StaffError.repeatedMeasureCannotBeModified) {
            try staff.replaceMeasure(at: 6, with: measure1)
        }
    }

    // MARK: Successes

    @Test func replaceMeasureAtIndex() async throws {
        try staff.replaceMeasure(at: 0, with: measure2)
        let replacedMeasure = Measure(try staff.measure(at: 0))
        #expect(replacedMeasure == changedClef(of: measure2))
    }

    @Test func replaceMeasureWithRepeat() async throws {
        try staff.replaceMeasure(at: 5, with: measure1)
        let replacedMeasure = Measure(try staff.measure(at: 5))
        let repeatedMeasure = Measure(try staff.measure(at: 6))
        #expect(replacedMeasure == changedClef(of: measure1))
        #expect(repeatedMeasure == changedClef(of: measure1))
    }

    // MARK: - changeClef(_:, in:, at:, inSet:)

    // MARK: Failures

    @Test func changeClefInvalidMeasureIndex() async throws {
        #expect(throws: StaffError.measureIndexOutOfRange) {
            try staff.changeClef(.bass, in: 17, atNote: 0, inSet: 0)
        }
    }

    @Test func changeClefRepeatedMeasure() async throws {
        #expect(throws: StaffError.repeatedMeasureCannotBeModified) {
            try staff.changeClef(.bass, in: 6, atNote: 0, inSet: 0)
        }
    }

    // MARK: Successes

    @Test func changeClefAtBeginningOfMeasure() async throws {
        try verifyAndChangeClef(to: .bass, in: 2, atNote: 0)
    }

    @Test func changeClefAtBeginningOfStaff() async throws {
        try verifyAndChangeClef(to: .alto, in: 0, atNote: 0)
    }

    @Test func changeClefAtMiddleOfMeasure() async throws {
        try verifyAndChangeClef(to: .baritoneF, in: 3, atNote: 2)
    }

    @Test func changeClefTwiceInOneMeasure() async throws {
        let newClef1: Clef = .bass
        let newClef2: Clef = .alto

        try staff.changeClef(newClef1, in: 1, atNote: 1)
        try staff.changeClef(newClef2, in: 1, atNote: 2)

        try verifyClefsUnchanged(before: 1)
        try verifyClefsChanged(to: newClef2, after: 1)
    }

    @Test func changeClefTwiceAcross2Measures() async throws {
        let newClef1: Clef = .tenor
        let newClef2: Clef = .bass

        try staff.changeClef(newClef1, in: 2, atNote: 0)
        try staff.changeClef(newClef2, in: 4, atNote: 0)

        try verifyClefsUnchanged(before: 2)
        try verifyClefsChanged(to: newClef1, after: 2, until: 4)
        try verifyClefsChanged(to: newClef2, after: 4)
    }

    @Test func changeClefTwiceAcross2NoteSetsIn1Measure() async throws {
        let sixteenth = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
        let quarter = Note(.quarter, pitch: SpelledPitch(.c, .octave1))
        staff.appendMeasure(
            Measure(timeSignature: TimeSignature(numerator: 4, denominator: 4, tempo: 120),
                    notes: [
                        [sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth, sixteenth],
                        [quarter, quarter, quarter, quarter]
                    ])
        )

        let newLastMeasureIndex = 17
        let newClef1: Clef = .bass
        let newClef2 = Clef(
            pitch: SpelledPitch(.c, accidental: .sharp, .octave3),
            location: StaffLocation(.space, 3)
        )
        try staff.changeClef(newClef1, in: newLastMeasureIndex, atNote: 1, inSet: 0)
        try staff.changeClef(newClef2, in: newLastMeasureIndex, atNote: 2, inSet: 1)
        let measure = Measure(try staff.measure(at: newLastMeasureIndex))
        try verifyClefsUnchanged(before: newLastMeasureIndex)
        #expect(measure.lastClef != nil)
        #expect(measure.lastClef == newClef2)
        let firstChangeTicks = try measure.cumulativeTicks(at: 1, inSet: 0)
        let secondChangeTicks = try measure.cumulativeTicks(at: 2, inSet: 1)
        #expect(measure.clefs == [firstChangeTicks: newClef1, secondChangeTicks: newClef2])
    }

    @Test func changeClefAtBeginningOfFirstMeasureWithinRepeat() async throws {
        let newClef: Clef = .bass
        try staff.changeClef(newClef, in: 5, atNote: 0, inSet: 0)
        try verifyClefsUnchanged(before: 5)
        try verifyClefsChanged(to: newClef, after: 6)
        let immutableMeasure1 = try staff.measure(at: 5)
        let immutableMeasure2 = try staff.measure(at: 6)
        #expect(immutableMeasure1.lastClef == .bass)
        #expect(immutableMeasure2.lastClef == .bass)
        #expect(immutableMeasure1.clefs == [0: .bass])
        #expect(immutableMeasure2.clefs == [0: .bass])
    }

    @Test func changeClefInMeasureRepeatWith1Measure() async throws {
        let newClef: Clef = .bass
        try staff.changeClef(newClef, in: 5, atNote: 1, inSet: 0)
        try verifyClefsUnchanged(before: 5)
        try verifyClefsChanged(to: newClef, after: 6)
        let immutableMeasure1 = try staff.measure(at: 5)
        let immutableMeasure2 = try staff.measure(at: 6)
        let ticks = try Measure(immutableMeasure1).cumulativeTicks(at: 1)
        #expect(immutableMeasure1.lastClef == newClef)
        #expect(immutableMeasure2.lastClef == newClef)
        #expect(immutableMeasure1.clefs == [ticks: newClef])
        #expect(immutableMeasure2.clefs == [ticks: newClef])
    }

    @Test func changeClefInEachMeasureInRepeat() async throws {
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
            #expect($0.lastClef == newClef1)
            #expect($0.clefs == [0: newClef1])
        }
        secondChangeMeasures.forEach {
            #expect($0.lastClef == newClef2)
            #expect($0.clefs == [secondChangeTicks: newClef2])
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
                    #expect(measure.lastClef == Constant.standardClef)
                    #expect(measure.originalClef == Constant.standardClef)
                case let measureRepeat as MeasureRepeat:
                    measureRepeat.expand().forEach {
                        #expect($0.lastClef == Constant.standardClef)
                        #expect($0.originalClef == Constant.standardClef)
                    }
                default:
                    Issue.record("Invalid type. Should be Measure or MeasureRepeat")
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
                    #expect(measure.lastClef == newClef)
                    #expect(measure.originalClef == newClef)
                case let measureRepeat as MeasureRepeat:
                    measureRepeat.expand().forEach {
                        #expect($0.lastClef == newClef)
                        #expect($0.originalClef == newClef)
                    }
                default:
                    Issue.record("Invalid type. Should be Measure or MeasureRepeat")
                }
            }
        }
    }

    // MARK: - Collection Conformance

    @Test func map() async throws {
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
                #expect(actual == expected)
            case let (actual as MeasureRepeat, expected as MeasureRepeat):
                #expect(actual == expected)
            default:
                Issue.record("NotesHolders not equal")
            }
            count += 1
        }
        #expect(count == expectedNotesHolders.count)
    }

    @Test func reversed() async throws {
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
                #expect(actual == expected)
            case let (actual as MeasureRepeat, expected as MeasureRepeat):
                #expect(actual == expected)
            default:
                Issue.record("NotesHolders not equal")
            }
            count += 1
        }
        #expect(count == expectedNotesHolders.count)
    }

    @Test func iterator() async throws {
        var iterator = staff.makeIterator()
        if let actual = iterator.next() as? Measure {
            #expect(actual == changedClef(of: measure1))
        } else {
            Issue.record("Iterator didn't return correct value for next()")
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
