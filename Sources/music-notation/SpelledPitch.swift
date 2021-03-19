//
//  SpelledPitch.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

///
/// A pitch indicates the note letter (a-g), octave, and accidental.
/// Since certain pitches are the same, but can be shown differently (like a sharp and b flat),
/// the "spelling" of the pitch is important.
/// This struct represents a pitch that is already in the desired spelling.
/// So, this assumes the user of this struct knows which spelling to pick.
///
public struct SpelledPitch {
	public let noteLetter: NoteLetter
	public let accidental: Accidental
	public let octave: Octave

	public init(noteLetter: NoteLetter, accidental: Accidental = .natural, octave: Octave) {
		self.noteLetter = noteLetter
		self.accidental = accidental
		self.octave = octave
	}
}

extension SpelledPitch: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch accidental {
		case .natural:
			return "\(noteLetter)\(octave.rawValue)"
		default:
			return "\(noteLetter)\(accidental)\(octave.rawValue)"
		}
	}
}

extension SpelledPitch: Equatable {
	public static func == (lhs: SpelledPitch, rhs: SpelledPitch) -> Bool {
		if lhs.accidental == rhs.accidental,
			lhs.noteLetter == rhs.noteLetter,
			lhs.octave == rhs.octave {
			return true
		} else {
			return false
		}
	}
}

extension SpelledPitch {
	public var midiNoteNumber: Int {
		var result = (octave.rawValue + 1) * 12

		switch noteLetter {
		case .c: break
		case .d: result += 2
		case .e: result += 4
		case .f: result += 5
		case .g: result += 7
		case .a: result += 9
		case .b: result += 11
		}

		switch accidental {
		case .natural:
			break
		case .flat:
			result -= 1
		case .sharp:
			result += 1
		case .doubleFlat:
			result -= 2
		case .doubleSharp:
			result += 2
		}

		return result
	}
}

extension SpelledPitch: Enharmonic {
	public func isEnharmonic(with other: SpelledPitch) -> Bool {
		midiNoteNumber == other.midiNoteNumber
	}
}
