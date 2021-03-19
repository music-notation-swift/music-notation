//
//  ImmutableMeasure.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 3/6/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public protocol ImmutableMeasure: NotesHolder {
	var timeSignature: TimeSignature { get }
	var key: Key? { get }
	var notes: [[NoteCollection]] { get }
	var noteCount: [Int] { get }

	/// Stores all clef changes that took place in this measure
	var clefs: [Double: Clef] { get }

	/// Stores the last clef used in the measure
	var lastClef: Clef? { get }

	/// Stores the clef used when the measure was created or inserted into the Staff
	var originalClef: Clef? { get }

	// Collection Conformance
	var startIndex: Int { get }
	var endIndex: Int { get }
	func index(after i: Int) -> Int
	func index(before i: Int) -> Int

	init(timeSignature: TimeSignature, key: Key?)
	init(timeSignature: TimeSignature, key: Key?, notes: [[NoteCollection]])
}

public func == <T: ImmutableMeasure>(lhs: T, rhs: T) -> Bool {
	guard lhs.timeSignature == rhs.timeSignature,
		lhs.key == rhs.key,
		lhs.notes.count == rhs.notes.count,
		lhs.clefs == rhs.clefs,
		lhs.lastClef == rhs.lastClef else {
		return false
	}
	for i in 0 ..< lhs.notes.count {
		guard lhs.notes[i].count == rhs.notes[i].count else {
			return false
		}
		for j in 0 ..< lhs.notes[i].count {
			if lhs.notes[i][j] == rhs.notes[i][j] {
				continue
			} else {
				return false
			}
		}
	}
	return true
}

// MARK: - Collection Conformance Helpers

/// One slice of `NoteCollection` from a note set at a particular time
public struct MeasureSlice: Equatable {
	public let noteSetIndex: Int
	public let noteCollection: NoteCollection
	public static func == (lhs: MeasureSlice, rhs: MeasureSlice) -> Bool {
		lhs.noteSetIndex == rhs.noteSetIndex &&
			lhs.noteCollection == rhs.noteCollection
	}
}

extension ImmutableMeasure {
	public var startIndex: Int { 0 }
	public var endIndex: Int { notes.map { $0.endIndex }.max() ?? 0	}
	public func index(after i: Int) -> Int { notes.index(after: i) }

	public func index(before i: Int) -> Int { notes.index(before: i) }

	internal static func measureSlices(at position: Int, in notes: [[NoteCollection]]) -> [MeasureSlice]? {
		notes.enumerated().compactMap { noteSetIndex, noteCollections in
			guard let noteCollection = noteCollections[safe: position] else {
				return nil
			}
			return MeasureSlice(noteSetIndex: noteSetIndex, noteCollection: noteCollection)
		}
	}
}

public struct MeasureIterator: IteratorProtocol {
	var currentIndex: Int = 0
	let notes: [[NoteCollection]]
	let endIndex: Int

	init<T: ImmutableMeasure>(_ measure: T) {
		notes = measure.notes
		endIndex = measure.endIndex
	}

	public mutating func next() -> [MeasureSlice]? {
		defer { currentIndex += 1 }
		if currentIndex >= endIndex {
			return nil
		}
		return Measure.measureSlices(at: currentIndex, in: notes)
	}
}
