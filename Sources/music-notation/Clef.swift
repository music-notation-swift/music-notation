//
//	Clef.swift
//	music-notation
//
//	Created by Kyle Sherman on 2016-10-16.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

import Foundation

/// A clef (from French: clef **'key'**) is a musical symbol used to indicate which notes are represented
/// by the lines and spaces on a musical staff. Placing a clef on a staff assigns a particular pitch
/// to one of the five lines or four spaces, which defines the pitches on the remaining lines and spaces.
///
/// The three clef symbols used in modern music notation are the **G-clef**, **F-clef**, and **C-clef**.
/// Placing these clefs on a line fixes a reference note to that line—an F-clef fixes the F below
/// middle C, a C-clef fixes middle C, and a G-clef fixes the G above middle C.
///
/// In modern music notation, the G-clef is most frequently seen as treble clef (placing G4 on the
/// second line of the staff), and the F-clef as bass clef (placing F3 on the fourth line).
///
/// The C-clef is mostly encountered as alto clef (placing middle C on the third line) or tenor
/// clef (middle C on the fourth line).
/// A clef may be placed on a space instead of a line, but this is rare.
///
/// The use of different clefs makes it possible to write music for all instruments and voices,
/// regardless of differences in range. Using different clefs for different instruments and
/// voices allows each part to be written comfortably on a staff with a minimum of ledger lines.
/// To this end, the G-clef is used for high parts, the C-clef for middle parts, and the F-clef for
/// low parts. Transposing instruments can be an exception to this—the same clef is generally used
/// for all instruments in a family, regardless of their sounding pitch. For example, even the low
/// saxophones read in treble clef.
///
/// - note: Please see the description as seen in the README.md file. You can see the graphic representations
/// of each of the clefs.
///
public struct Clef: Sendable {
	/// The pitch that defines the clef. This pitch is specified to be at a
	/// certain `StaffLocation` using the `staffLocation` property.
	///
	public let pitch: SpelledPitch?

	/// The location on the staff at which the pitch for the clef is located.
	public let staffLocation: StaffLocation

	/// You can create a custom clef by providing a pitch and line number.
	///
	/// - parameter pitch: The pitch that the clef represents. Pitch is optional to support un-pitched (i.e. drums)
	/// - parameter location: The location on the staff
	///
	public init(pitch: SpelledPitch?, location: StaffLocation) {
		self.pitch = pitch
		staffLocation = location
	}

	/// Calculates the pitch for the given staff location for this Clef.
	///
	/// - parameter location: The location on the staff for which you would like to know the pitch.
	/// - returns: The pitch at the given staff location or nil if the `Clef` is un-pitched.
	/// - throws:
	///	  - `ClefError.internal`: Logic error with math
	///	  - `ClefError.octaveOutOfRange`
	///
	internal func pitch(at location: StaffLocation) throws -> SpelledPitch? {
		guard let pitch = pitch else { return nil }

		let largestNoteLetter = NoteLetter.b.rawValue
		let delta = location.halfSteps - staffLocation.halfSteps
		guard delta != 0 else { return pitch }

		let clefPitchRawValue = pitch.noteLetter.rawValue

		// Add the delta to the clef raw value
		let newPitchRawWithDelta = clefPitchRawValue + delta

		/// If requested location is increase (delta > 0), you are adding onto 0.
		/// If it's a decrease, you are subtracting from the largestNoteLetter.
		///
		let startingPitchValue = newPitchRawWithDelta > 0 ? 0 : largestNoteLetter

		// Perform modulus to find out which `NoteLetter` it is.
		let newPitchRawValue = newPitchRawWithDelta % largestNoteLetter

		// If modulus is 0, it was the last letter. Otherwise, take the new raw value and add it to the starting value
		guard let newNoteLetter = NoteLetter(rawValue: newPitchRawValue == 0 ? largestNoteLetter : startingPitchValue + newPitchRawValue) else {
			assertionFailure("modulus failed, because logic is flawed")
			throw ClefError.internalError
		}

		// Figure out the delta by looking at how many times the new pitch has multipled the base noteLetter
		let octaveDeltaRaw = Double(newPitchRawWithDelta) / Double(largestNoteLetter)
		let octaveDelta: Int = {
			// TODO: Use `.rounded(_:)` instead of floor here and below.
			// https://github.com/drumnkyle/music-notation-core/issues/146
			if octaveDeltaRaw == floor(octaveDeltaRaw) {
				/// If the value is an exact multiple, it has not crossed the octave border yet.
				/// Therefore, subtract one from the value for the octave delta.
				return Int(octaveDeltaRaw - 1)
			}

			/// In any other case, just floor the value and that is the delta for the octave.
			return Int(floor(octaveDeltaRaw))
		}()
		let newOctaveValue = pitch.octave.rawValue + octaveDelta
		guard let newOctave = Octave(rawValue: newOctaveValue) else { throw ClefError.octaveOutOfRange }
		return SpelledPitch(newNoteLetter, newOctave)
	}
}

// MARK: - Common clefs
extension Clef {
	// Common clef convenience constructors
	public static let treble = Clef(pitch: SpelledPitch(.g, .octave4), location: StaffLocation(.line, 1))
	public static let bass = Clef(pitch: SpelledPitch(.f, .octave3), location: StaffLocation(.line, 3))
	public static let tenor = Clef(pitch: SpelledPitch(.c, .octave4), location: StaffLocation(.line, 3))
	public static let alto = Clef(pitch: SpelledPitch(.c, .octave4), location: StaffLocation(.line, 2))

	/// Un-pitched (drums, percussion, etc.)
	public static let neutral = Clef(pitch: nil, location: StaffLocation(.line, 2))

	/// For tablature (guitar, etc.)
	public static let tab = Clef(pitch: nil, location: StaffLocation(.line, 2))

	// Less common
	public static let frenchViolin = Clef(pitch: SpelledPitch(.g, .octave4), location: StaffLocation(.line, 0))
	public static let soprano = Clef(pitch: SpelledPitch(.c, .octave4), location: StaffLocation(.line, 0))
	public static let mezzoSoprano = Clef(pitch: SpelledPitch(.c, .octave4), location: StaffLocation(.line, 1))
	public static let baritoneF = Clef(pitch: SpelledPitch(.f, .octave3), location: StaffLocation(.line, 2))
	public static let baritoneC = Clef(pitch: SpelledPitch(.c, .octave4), location: StaffLocation(.line, 4))
	public static let subBase = Clef(pitch: SpelledPitch(.f, .octave3), location: StaffLocation(.line, 5))

	// TODO: Is this one correct?
	/// Starting in the 18th century, music for some instruments (such as guitar) and for the tenor voice
	/// have used treble clef, although they sound an octave lower. To avoid ambiguity, modified clefs
	/// are sometimes used, especially in choral writing. Using a C-clef on the third space places the
	/// notes identically, but this notation is much less common[9][10] as it is easily confused with the
	/// alto and tenor clefs.
	public static let suboctaveTreble = Clef(pitch: SpelledPitch(.g, .octave3), location: StaffLocation(.line, 1))

}

// MARK: - Errors

public enum ClefError: Error {
	case octaveOutOfRange
	case internalError
}

// MARK: - Equality

extension Clef: Equatable {
	public static func == (lhs: Clef, rhs: Clef) -> Bool {
		lhs.pitch == rhs.pitch && lhs.staffLocation.halfSteps == rhs.staffLocation.halfSteps
	}
}

// MARK: - Debug

extension Clef: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case Clef.treble: return "treble"
		case Clef.bass: return "bass"
		case Clef.tenor: return "tenor"
		case Clef.alto: return "alto"
		case Clef.neutral: return "neutral"
		case Clef.frenchViolin: return "frenchViolin"
		case Clef.soprano: return "soprano"
		case Clef.mezzoSoprano: return "mezzoSoprano"
		case Clef.baritoneF: return "baritoneF"
		case Clef.baritoneC: return "baritoneC"
		case Clef.suboctaveTreble: return "suboctaveTreble"
		case let clef where clef.pitch == nil: return "neutral"
		default:
			return "\(pitch!)@\(staffLocation.locationType)\(staffLocation.number)"
		}
	}
}
