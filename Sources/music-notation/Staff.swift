//
//  Staff.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct Staff: RandomAccessCollection {
	// MARK: - Collection Conformance

	public typealias Index = Int
	public var startIndex: Int {
		notesHolders.startIndex
	}

	public var endIndex: Int {
		notesHolders.endIndex
	}

	public subscript(position: Index) -> Iterator.Element {
		notesHolders[position]
	}

	public func index(after i: Int) -> Int {
		notesHolders.index(after: i)
	}

	public func index(before i: Int) -> Int {
		notesHolders.index(before: i)
	}

	public typealias Iterator = IndexingIterator<[NotesHolder]>
	public func makeIterator() -> Iterator {
		notesHolders.makeIterator()
	}

	// MARK: - Main Properties

	public let clef: Clef
	public let instrument: Instrument
	public private(set) var measureCount: Int = 0

	internal private(set) var notesHolders: [NotesHolder] = [] {
		didSet {
			recomputeMeasureIndexes()
		}
	}

	private var measureIndexes: [(notesHolderIndex: Int, repeatMeasureIndex: Int?)] = []

	public init(clef: Clef, instrument: Instrument) {
		self.clef = clef
		self.instrument = instrument
	}

	public mutating func appendMeasure(_ measure: Measure) {
		let measureBefore = try? self.measure(at: lastIndex)
		let clefChange = measureBefore?.lastClef ?? clef
		var measure = measure
		_ = measure.changeFirstClefIfNeeded(to: clefChange)
		notesHolders.append(measure)
		measureCount += measure.measureCount
	}

	public mutating func appendRepeat(_ measureRepeat: MeasureRepeat) {
		var measureRepeat = measureRepeat
		let measureBefore = try? measure(at: lastIndex)
		for index in measureRepeat.measures.indices {
			_ = measureRepeat.measures[index].changeFirstClefIfNeeded(to: measureBefore?.lastClef ?? clef)
		}
		notesHolders.append(measureRepeat)
		measureCount += measureRepeat.measureCount
	}

	///
	/// Changes the Clef at the given location.
	///
	/// - parameter clef: The new `Clef` to change to
	/// - parameter measureIndex: The index of the measure to change the clef
	/// - parameter noteIndex: The index of the note at which you want the clef to change
	/// - parameter setIndex: The index of the note set in which the note resides where you want to change the clef
	/// - throws:
	///    - `StaffError.measureIndexOutOfRange`
	///    - `StaffError.repeatedMeasureCannotBeModified` if the measure is a repeated measure.
	///    - `StaffError.internalError` if the function has an internal implementation error.
	///
	public mutating func changeClef(_ clef: Clef,
									in measureIndex: Int,
									atNote noteIndex: Int,
									inSet setIndex: Int = 0) throws {
		guard var measure = try measure(at: measureIndex) as? Measure else { throw StaffError.repeatedMeasureCannotBeModified }
		try measure.changeClef(clef, at: noteIndex, inSet: setIndex)
		try replaceMeasure(at: measureIndex, with: measure)

		// If there is already another clef specified after the new clef, then
		// there is no need to propagate to the following measures.
		guard !measure.hasClefAfterNote(at: noteIndex, inSet: setIndex) else { return }
		try propagateClefChange(clef, fromMeasureIndex: measureIndex)
	}

	///
	/// Inserts a measure at the given index.
	///
	/// If the given index falls on a `MeasureRepeat`, there are 3 things that can happen:
	///
	/// 1. If the index is the beginning of a repeat, see the `beforeRepeat` parameter.
	/// 2. If the index is within the original measure(s) to be repeated, the `newMeasure`
	/// will be inserted into the repeat. The new measure is therefore repeated
	/// `MeasureRepeat.repeatCount` times.
	/// 3. If the index is within the repeated portion, the insert will fail, because
	/// the repeated measures are immutable. See `MeasureRepeat`.
	///
	/// - parameter measure: The measure to be inserted.
	/// - parameter index: The index where the measure should be inserted.
	/// - parameter beforeRepeat: Default value is true. This parameter is only used if the given index is
	/// the beginning of a repeat. True if you want the measure to be inserted before the repeat. False
	/// when you want the measure to be inserted into the repeat at the given index.
	/// - throws:
	///     - `StaffError.measureIndexOutOfRange`
	///     - `StaffError.noRepeatToInsertInto`
	///     - `StaffError.hasToInsertIntoRepeatIfIndexIsNotFirstMeasureOfRepeat`
	///     - `StaffError.internalError`
	///     - `MeasureRepeatError.indexOutOfRange`
	///     - `MeasureRepeatError.cannotModifyRepeatedMeasures`
	///
	public mutating func insertMeasure(_ measure: Measure, at index: Int, beforeRepeat: Bool = true) throws {
		var measure = measure
		let measureBefore = try? self.measure(at: index - 1)
		let clefChange = measureBefore?.lastClef ?? clef
		let didChangeClef = measure.changeFirstClefIfNeeded(to: clefChange)
		// Need to propagate lastClef if there are clef changes already in the measure
		if let newClef = measure.lastClef, !didChangeClef {
			try propagateClefChange(newClef, fromMeasureIndex: index)
		}
		let notesHolderIndex = try notesHolderIndexFromMeasureIndex(index)
		// Not a repeat, just insert
		if notesHolderIndex.repeatMeasureIndex == nil {
			notesHolders.insert(measure, at: notesHolderIndex.notesHolderIndex)
			measureCount += measure.measureCount
		} else {
			if beforeRepeat, notesHolderIndex.repeatMeasureIndex == 0 {
				notesHolders.insert(measure, at: notesHolderIndex.notesHolderIndex)
				measureCount += measure.measureCount
				return
			}
			// Is a repeat, so insert if it is one of the measures to be repeated
			guard var measureRepeat = notesHolders[notesHolderIndex.notesHolderIndex] as? MeasureRepeat,
				let repeatMeasureIndex = notesHolderIndex.repeatMeasureIndex else {
				assertionFailure("Index translation showed should be a repeat, but it's not")
				throw StaffError.internalError
			}
			try measureRepeat.insertMeasure(measure, at: repeatMeasureIndex)
			notesHolders[notesHolderIndex.notesHolderIndex] = measureRepeat
		}
	}

	///
	/// Inserts a `MeasureRepeat` at the given index. If there is already a repeat at the given index,
	/// this will fail.
	///
	/// - parameter measureRepeat: The repeat to insert.
	/// - parameter index: The index where the repeat should be inserted.
	/// - throws:
	///     - `StaffError.measureIndexOutOfRange`
	///     - `StaffError.cannotInsertRepeatWhereOneAlreadyExists`
	///
	public mutating func insertRepeat(_ measureRepeat: MeasureRepeat, at index: Int) throws {
		var measureRepeat = measureRepeat
		let measureBefore = try? measure(at: index - 1)
		var didChangeClef: Bool = true
		for index in measureRepeat.measures.indices {
			didChangeClef = measureRepeat.measures[index].changeFirstClefIfNeeded(to: measureBefore?.lastClef ?? clef)
		}
		if let newClef = measureRepeat.measures.last?.lastClef, !didChangeClef {
			try propagateClefChange(newClef, fromMeasureIndex: index + measureRepeat.measureCount)
		}
		let notesHolderIndex = try notesHolderIndexFromMeasureIndex(index)
		guard notesHolderIndex.repeatMeasureIndex == nil || notesHolderIndex.repeatMeasureIndex == 0 else {
			throw StaffError.cannotInsertRepeatWhereOneAlreadyExists
		}
		notesHolders.insert(measureRepeat, at: notesHolderIndex.notesHolderIndex)
		measureCount += measureRepeat.measureCount
	}

	///
	/// Replaces the measure at the given index with a new measure. The measure index takes into consideration
	/// repeats. Therefore, the index is the actual index of the measure as it were played.
	///
	/// - parameter measureIndex: The index of the measure to replace.
	/// - parameter newMeasure: The new measure to replace the old one.
	/// - throws:
	///     - `StaffError.repeatedMeasureCannotBeModified` if the measure is a repeated measure.
	///     - `StaffError.internalError` if index translation doesn't work properly.
	///
	public mutating func replaceMeasure(at measureIndex: Int, with newMeasure: Measure) throws {
		try replaceMeasure(at: measureIndex, with: newMeasure, shouldChangeClef: true)
	}

	///
	/// Ties a note to the next note.
	///
	/// - parameter noteIndex: The index of the note in the specified measure to begin the tie.
	/// - parameter measureIndex: The index of the measure that contains the note at which the tie should begin.
	/// - parameter setIndex: The index of the set of notes you want to modify. There can be multiple sets of notes
	/// that make up a full measure on their own. i.e. bass drum notes and hi-hat notes. See `Measure` for more info.
	/// - throws:
	///     - `StaffError.noteIndexoutOfRange`
	///     - `StaffError.noNextNoteToTie` if the note specified is the last note in the staff.
	///     - `StaffError.measureIndexOutOfRange`
	///     - `StaffError.repeatedMeasureCannotHaveTie` if the index for the measure specified refers to a measure that is
	///     a repeat of another measure.
	///     - `StaffError.internalError`, `MeasureError.internalError` if the function has an internal implementation error.
	///     - `MeasureError.noteIndexOutOfRange`
	///
	public mutating func startTieFromNote(at noteIndex: Int, inMeasureAt measureIndex: Int, inSet setIndex: Int = 0) throws {
		try modifyTieForNote(at: noteIndex, inMeasureAt: measureIndex, removeTie: false, inSet: setIndex)
	}

	///
	/// Removes the tie beginning at the note at the specified index.
	///
	/// - parameter noteIndex: The index of the note in the specified measure where the tie begins.
	/// - parameter measureIndex: The index of the measure that contains the note at which the tie begins.
	/// - parameter setIndex: The index of the set of notes you want to modify. There can be multiple sets of notes
	/// that make up a full measure on their own. i.e. bass drum notes and hi-hat notes. See `Measure` for more info.
	/// - throws:
	///     - `StaffError.noteIndexoutOfRange`
	///     - `StaffError.noNextNoteToTie` if the note specified is the last note in the staff.
	///     - `StaffError.measureIndexOutOfRange`
	///     - `StaffError.repeatedMeasureCannotHaveTie` if the index for the measure specified refers to a measure that is
	///     a repeat of another measure.
	///     - `MeasureError.noteIndexOutOfRange`
	///     - `StaffError.internalError`, `MeasureError.internalError` if the function has an internal implementation error.
	///
	public mutating func removeTieFromNote(at noteIndex: Int, inMeasureAt measureIndex: Int, inSet setIndex: Int = 0) throws {
		try modifyTieForNote(at: noteIndex, inMeasureAt: measureIndex, removeTie: true, inSet: setIndex)
	}

	///
	/// - parameter measureIndex: The index of the measure to return.
	/// - returns An `ImmutableMeasure` at the given index within the staff.
	/// - throws:
	///     - `StaffError.measureIndexOutOfRange`
	///     - `StaffError.internalError` if the function has an internal implementation error.
	///
	public func measure(at measureIndex: Int) throws -> ImmutableMeasure {
		let (notesHolderIndex, repeatMeasureIndex) = try notesHolderIndexFromMeasureIndex(measureIndex)
		if let measureRepeat = notesHolders[notesHolderIndex] as? MeasureRepeat,
			let repeatMeasureIndex = repeatMeasureIndex {
			return measureRepeat.expand()[repeatMeasureIndex]
		} else if let measure = notesHolders[notesHolderIndex] as? ImmutableMeasure {
			return measure
		}
		throw StaffError.internalError
	}

	///
	/// - parameters measureIndex: The index of a measure that is either repeated or is one of the repeated measures.
	/// - returns A `MeasureRepeat` that contains the measure(s) that are repeated as well as the repeat count. Returns nil
	/// if the measure at the specified index is not part of repeat.
	/// - throws:
	///     - `StaffError.measureIndexOutOfRange`
	///     - `StaffError.internalError` if the function has an internal implementation error.
	///
	public func measureRepeat(at measureIndex: Int) throws -> MeasureRepeat? {
		let (notesHolderIndex, _) = try notesHolderIndexFromMeasureIndex(measureIndex)
		return notesHolders[notesHolderIndex] as? MeasureRepeat
	}

	internal func notesHolderAtMeasureIndex(_ measureIndex: Int) throws -> NotesHolder {
		let (notesHolderIndex, _) = try notesHolderIndexFromMeasureIndex(measureIndex)
		return notesHolders[notesHolderIndex]
	}

	private mutating func modifyTieForNote(at noteIndex: Int, inMeasureAt measureIndex: Int, removeTie: Bool, inSet setIndex: Int) throws {
		let notesHolderIndex = try notesHolderIndexFromMeasureIndex(measureIndex)

		// Ensure first measure information provided is valid for tie
		var firstMeasure = try mutableMeasureFromNotesHolderIndex(notesHolderIndex.notesHolderIndex, repeatMeasureIndex: notesHolderIndex.repeatMeasureIndex)
		guard noteIndex < firstMeasure.noteCount[setIndex] else {
			throw StaffError.noteIndexOutOfRange
		}

		if noteIndex == firstMeasure.noteCount[setIndex] - 1 {
			let secondNotesHolderIndex: (notesHolderIndex: Int, repeatMeasureIndex: Int?)
			do {
				secondNotesHolderIndex = try notesHolderIndexFromMeasureIndex(measureIndex + 1)
			} catch {
				throw StaffError.noNextNoteToTie
			}
			var secondMeasure = try mutableMeasureFromNotesHolderIndex(
				secondNotesHolderIndex.notesHolderIndex,
				repeatMeasureIndex: secondNotesHolderIndex.repeatMeasureIndex
			)
			guard secondMeasure.noteCount[setIndex] > 0 else {
				throw StaffError.noNextNoteToTie
			}

			if !removeTie {
				let firstNote = try firstMeasure.note(at: noteIndex, inSet: setIndex)
				let secondNote = try secondMeasure.note(at: 0, inSet: setIndex)
				if firstNote.pitches != secondNote.pitches {
					throw StaffError.notesMustHaveSamePitchesToTie
				}
			}

			// Modify tie and update second Measure. The first Measure update is done later.
			try firstMeasure.modifyTie(at: noteIndex, requestedTieState: removeTie ? nil : .begin, inSet: setIndex)
			try secondMeasure.modifyTie(at: 0, requestedTieState: removeTie ? nil : .end, inSet: setIndex)
			try replaceMeasure(at: measureIndex + 1, with: secondMeasure)
		} else {
			if removeTie {
				try firstMeasure.removeTie(at: noteIndex, inSet: setIndex)
			} else {
				try firstMeasure.startTie(at: noteIndex, inSet: setIndex)
			}
		}

		try replaceMeasure(at: measureIndex, with: firstMeasure)
	}

	internal func notesHolderIndexFromMeasureIndex(_ index: Int) throws -> (notesHolderIndex: Int, repeatMeasureIndex: Int?) {
		guard index >= 0, index < measureCount else { throw StaffError.measureIndexOutOfRange }
		return measureIndexes[index]
	}

	internal mutating func replaceMeasure(at measureIndex: Index, with newMeasure: Measure, shouldChangeClef: Bool) throws {
		var newMeasure = newMeasure
		let oldMeasure = try? measure(at: measureIndex)
		if shouldChangeClef {
			let didChangeClef = newMeasure.changeFirstClefIfNeeded(to: oldMeasure?.originalClef ?? clef)
			if let newClef = newMeasure.lastClef, !didChangeClef {
				try propagateClefChange(newClef, fromMeasureIndex: measureIndex)
			}
		}
		let (notesHolderIndex, repeatMeasureIndex) = try notesHolderIndexFromMeasureIndex(measureIndex)
		let newNotesHolder: NotesHolder
		if let repeatMeasureIndex = repeatMeasureIndex {
			guard (try? mutableMeasureFromNotesHolderIndex(notesHolderIndex, repeatMeasureIndex: repeatMeasureIndex)) != nil else {
				throw StaffError.repeatedMeasureCannotBeModified
			}
			guard var measureRepeat = notesHolders[notesHolderIndex] as? MeasureRepeat else {
				assertionFailure("Index translation showed should be a repeat, but it's not")
				throw StaffError.internalError
			}
			measureRepeat.measures[repeatMeasureIndex] = newMeasure
			newNotesHolder = measureRepeat
		} else {
			newNotesHolder = newMeasure
		}
		notesHolders[notesHolderIndex] = newNotesHolder
	}

	private mutating func recomputeMeasureIndexes() {
		measureIndexes = []
		for (i, notesHolder) in notesHolders.enumerated() {
			switch notesHolder {
			case is Measure:
				measureIndexes.append((notesHolderIndex: i, repeatMeasureIndex: nil))
			case let measureRepeat as MeasureRepeat:
				for j in 0 ..< measureRepeat.measureCount {
					measureIndexes.append((notesHolderIndex: i, repeatMeasureIndex: j))
				}
			default:
				assertionFailure("NotesHolders should only be Measure or MeasureRepeat")
				continue
			}
		}
	}

	private func mutableMeasureFromNotesHolderIndex(_ notesHolderIndex: Int, repeatMeasureIndex: Int?) throws -> Measure {
		let notesHolder = notesHolders[notesHolderIndex]
		// Ensure first measure information provided is valid for tie
		if let repeatMeasureIndex = repeatMeasureIndex {
			// If repeatMeasureIndex is not nil, check if measure is not a repeated one
			// If it's not, check if noteIndex is less than count of measure
			guard let measureRepeat = notesHolder as? MeasureRepeat else {
				assertionFailure("Index translation showed should be a repeat, but it's not")
				throw StaffError.internalError
			}
			guard let mutableMeasure = measureRepeat.expand()[repeatMeasureIndex] as? Measure else {
				throw StaffError.repeatedMeasureCannotHaveTie
			}
			return mutableMeasure
		} else {
			// If repeatMeasureIndex is nil, check if the noteIndex is less than note count of measure
			assert(notesHolder.measureCount == 1, "Index translation showed should be a single measure, but it's not")
			guard let immutableMeasure = notesHolder as? ImmutableMeasure else {
				throw StaffError.internalError
			}
			if let mutableMeasure = immutableMeasure as? Measure {
				return mutableMeasure
			} else {
				assertionFailure("If not a repeated measure, should be a mutable measure")
				throw StaffError.internalError
			}
		}
	}

	private mutating func propagateClefChange(_ clef: Clef, fromMeasureIndex measureIndex: Int) throws {
		// Modify every `originalClef` and `lastClef` that follows the measure until not needed
		for index in (measureIndex + 1) ..< measureCount {
			do {
				guard var measure = try self.measure(at: index) as? Measure else {
					continue
				}
				let didChangeClef = measure.changeFirstClefIfNeeded(to: clef)
				if !didChangeClef {
					break
				}
				try replaceMeasure(at: index, with: measure, shouldChangeClef: false)
			} catch {
				continue
			}
		}
	}
}

public enum StaffError: Error {
	case noteIndexOutOfRange
	case measureIndexOutOfRange
	case noNextNoteToTie
	case noNextNote
	case notBeginningOfTie
	case repeatedMeasureCannotHaveTie
	case notesMustHaveSamePitchesToTie
	case measureNotPartOfRepeat
	case repeatedMeasureCannotBeModified
	case cannotInsertRepeatWhereOneAlreadyExists
	case noRepeatToInsertInto
	case hasToInsertIntoRepeatIfIndexIsNotFirstMeasureOfRepeat
	case internalError
}

extension Staff: CustomDebugStringConvertible {
	public var debugDescription: String {
		let notesDescription = notesHolders.map { $0.debugDescription }.joined(separator: ", ")

		return "staff(\(clef) \(instrument) \(notesDescription))"
	}
}
