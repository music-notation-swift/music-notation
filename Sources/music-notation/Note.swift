//
//  Note.swift
//  MusicNotation
//
//  Created by Kyle Sherman on 6/12/15.
//  Copyright (c) 2015 Kyle Sherman. All rights reserved.
//

public struct Note: NoteCollection {
	// NoteCollection
	public let noteCount = 1
	public let noteDuration: NoteDuration
	public let noteTimingCount = 1
	public let groupingOrder = 1
	public var first: Note? { self }
	public var last: Note? { self }

	public let pitches: [SpelledPitch]

	public let isRest: Bool

	public var accent: Accent?
	public var isStaccato: Bool = false
	public var dynamics: Dynamics?
	public var striking: Striking?

	internal var tie: Tie?

	/// Initialize a rest.
	public init(restDuration: NoteDuration) {
		noteDuration = restDuration
		pitches = []
		isRest = true
	}

	/// Initialize a note with a single pitch.
	public init(noteDuration: NoteDuration, pitch: SpelledPitch) {
		self.noteDuration = noteDuration
		pitches = [pitch]
		isRest = false
	}

	/// Initialize a note with multiple pitches (chord).
	public init(noteDuration: NoteDuration, pitches: [SpelledPitch]) {
		isRest = false
		self.noteDuration = noteDuration
		self.pitches = pitches
	}

	// MARK: - Methods

	// MARK: Public

	public func note(at index: Int) throws -> Note {
		guard index == 0 else {
			throw NoteError.invalidNoteIndex
		}
		return self
	}

	internal mutating func modifyTie(_ request: Tie) throws {
		// Nothing to do if it's the same value
		guard tie != request else { return }
		switch (tie, request) {
		case (.begin?, .end), (.end?, .begin):
			tie = .beginAndEnd
		case (nil, let value):
			tie = value
		default:
			throw NoteError.invalidRequestedTieState
		}
	}

	///
	/// Remove the tie from the note.
	///
	/// - parameter currentTie: What part of the tie on the note the caller wants to remove. This is important if the
	/// note is both the beginning and end of a tie
	/// - throws:
	/// - `NoteError.invalidRequestedTieState`
	///
	internal mutating func removeTie(_ currentTie: Tie) throws {
		switch (currentTie, tie) {
		case (.beginAndEnd, _):
			throw NoteError.invalidRequestedTieState
		case (_, nil):
			return
		case let (request, current?) where request == current:
			tie = nil
		case (.begin, .beginAndEnd?):
			tie = .end
		case (.end, .beginAndEnd?):
			tie = .begin
		default:
			throw NoteError.invalidRequestedTieState
		}
	}
}

extension Note: Equatable {
	public static func == (lhs: Note, rhs: Note) -> Bool {
		if lhs.noteDuration == rhs.noteDuration,
			lhs.pitches == rhs.pitches,
			lhs.isRest == rhs.isRest,
			lhs.accent == rhs.accent,
			lhs.isStaccato == rhs.isStaccato,
			lhs.dynamics == rhs.dynamics,
			lhs.striking == rhs.striking,
			lhs.tie == rhs.tie {
			return true
		} else {
			return false
		}
	}
}

extension Note: CustomDebugStringConvertible {
	public var debugDescription: String {
		let pitchesString: String
		if pitches.count > 1 {
			pitchesString = "\(pitches)"
		} else {
			if let pitch = pitches.first {
				pitchesString = "\(pitch)"
			} else {
				pitchesString = ""
			}
		}
		return "\(tie == .end || tie == .beginAndEnd ? "_" : "")\(noteDuration)\(pitchesString)\(isRest ? "R" : "")\(tie == .begin || tie == .beginAndEnd ? "_" : "")"
	}
}

public enum NoteError: Error {
	case invalidRequestedTieState
	case invalidNoteIndex
}
