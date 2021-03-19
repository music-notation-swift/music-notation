//
//  RepeatedMeasure.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 3/9/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

///
/// This represents a measure that is part of a repeat. This is not one of the original measures that
/// will be repeated. This represents a measure that is a repeat of one of the original measures to
/// be repeated.
///
/// i.e. If we want to repeat measure A 2 times, you would have
///
///    | A, repeated A, repeated A |
///
/// This structure represents those repeated measures "repeated A", so that they can be differentiated from the
/// original measure "A".
///
/// - Note: Look at `MeasureRepeat.expand()` to see how this is used.
///
public struct RepeatedMeasure: ImmutableMeasure, Equatable, RandomAccessCollection {
	// MARK: - Collection Conformance

	public typealias Index = Int
	public subscript(position: Index) -> Iterator.Element {
		Measure.measureSlices(at: position, in: notes)!
	}

	public typealias Iterator = MeasureIterator
	public func makeIterator() -> Iterator {
		MeasureIterator(self)
	}

	// MARK: - Main Properties

	public let timeSignature: TimeSignature
	public let key: Key?
	public let notes: [[NoteCollection]]
	public let measureCount: Int = 1
	public let noteCount: [Int]
	public let clefs: [Double: Clef]
	public let lastClef: Clef?
	public let originalClef: Clef?

	public init(timeSignature: TimeSignature,
				key: Key? = nil,
				notes: [[NoteCollection]] = [],
				lastClef: Clef? = nil,
				originalClef: Clef? = nil,
				clefs: [Double: Clef] = [:]) {
		self.lastClef = lastClef
		self.originalClef = originalClef
		self.clefs = clefs
		self.timeSignature = timeSignature
		self.key = key
		self.notes = notes
		noteCount = notes.map {
			$0.reduce(0) { prev, noteCollection in
				prev + noteCollection.noteCount
			}
		}
	}

	public init(timeSignature: TimeSignature, key: Key? = nil) {
		self.init(timeSignature: timeSignature, key: key, notes: [[]])
	}

	public init(timeSignature: TimeSignature, key: Key? = nil, notes: [[NoteCollection]]) {
		self.timeSignature = timeSignature
		self.key = key
		self.notes = notes
		clefs = [:]
		noteCount = notes.map {
			$0.reduce(0) { prev, noteCollection in
				prev + noteCollection.noteCount
			}
		}
		lastClef = nil
		originalClef = nil
	}

	internal init(immutableMeasure: ImmutableMeasure) {
		timeSignature = immutableMeasure.timeSignature
		key = immutableMeasure.key
		notes = immutableMeasure.notes
		lastClef = immutableMeasure.lastClef
		originalClef = immutableMeasure.originalClef
		clefs = immutableMeasure.clefs
		noteCount = immutableMeasure.noteCount
	}
}

extension RepeatedMeasure: CustomDebugStringConvertible {
	public var debugDescription: String {
		let notesString = notes.map { "\($0)" }.joined(separator: ",")

		return "|\(timeSignature): \(notesString)|"
	}
}
