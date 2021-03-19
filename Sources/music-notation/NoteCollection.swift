//
//  NoteCollection.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

///
/// This is a protocol that represents anything that represents one or more notes.
/// i.e. `Note` and `Tuplet` both conform to this.
///
public protocol NoteCollection {
	/// The count of actual notes in this `NoteCollection`
	var noteCount: Int { get }
	///
	/// The duration of the note that in combination with `noteTimingCount`
	/// will give you the amount of time this `NoteCollection` occupies.
	///
	var noteDuration: NoteDuration { get }
	///
	/// The number of notes to indicate the amount of time occupied by this
	/// `NoteCollection`. Combine this with `noteDuration`.
	///
	var noteTimingCount: Int { get }

	/// The grouping order defined for this `NoteCollection`
	var groupingOrder: Int { get }

	var first: Note? { get }
	var last: Note? { get }

	var ticks: Double { get }

	/// - returns: The note at the given index.
	func note(at index: Int) throws -> Note
}

extension NoteCollection {
	public var ticks: Double { Double(noteTimingCount) * noteDuration.ticks }
}

public func == (lhs: NoteCollection, rhs: NoteCollection) -> Bool {
	if let left = lhs as? Note,
		let right = rhs as? Note,
		left == right {
		return true
	} else if let left = lhs as? Tuplet,
		let right = rhs as? Tuplet,
		left == right {
		return true
	} else {
		return false
	}
}

public func != (lhs: NoteCollection, rhs: NoteCollection) -> Bool {
	!(lhs == rhs)
}
