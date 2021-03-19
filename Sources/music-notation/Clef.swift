//
//  Clef.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 10/16/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

#if os(iOS) || os(watchOS) || os(tvOS) || os(OSX)
import Foundation
#else
import Darwin.C
#endif

public struct Clef {
	///
	/// The pitch that defines the clef. This pitch is specified to be at a
	/// certain `StaffLocation` using the `staffLocation` property.
	///
	public let pitch: SpelledPitch?

	/// The location on the staff at which the pitch for the clef is located.
	public let staffLocation: StaffLocation

	///
	/// You can create a custom clef by providing a pitch and line number.
	///
	/// - parameter pitch: The pitch that the clef represents. Pitch is optional to support un-pitched (i.e. drums)
	/// - parameter location: The location on the staff
	///
	public init(pitch: SpelledPitch?, location: StaffLocation) {
		self.pitch = pitch
		staffLocation = location
	}

	public static let treble = Clef(pitch: SpelledPitch(noteLetter: .g, octave: .octave4), location: StaffLocation(type: .line, number: 1))
	public static let bass = Clef(pitch: SpelledPitch(noteLetter: .f, octave: .octave3), location: StaffLocation(type: .line, number: 3))
	public static let tenor = Clef(pitch: SpelledPitch(noteLetter: .c, octave: .octave4), location: StaffLocation(type: .line, number: 3))
	public static let alto = Clef(pitch: SpelledPitch(noteLetter: .c, octave: .octave4), location: StaffLocation(type: .line, number: 2))

	/// Un-pitched (drums, percussion, etc.)
	public static let neutral = Clef(pitch: nil, location: StaffLocation(type: .line, number: 2))

	/// For tablature (guitar, etc.)
	public static let tab = Clef(pitch: nil, location: StaffLocation(type: .line, number: 2))

	// Less common
	public static let frenchViolin = Clef(pitch: SpelledPitch(noteLetter: .g, octave: .octave4), location: StaffLocation(type: .line, number: 0))
	public static let soprano = Clef(pitch: SpelledPitch(noteLetter: .c, octave: .octave4), location: StaffLocation(type: .line, number: 0))
	public static let mezzoSoprano = Clef(pitch: SpelledPitch(noteLetter: .c, octave: .octave4), location: StaffLocation(type: .line, number: 1))
	public static let baritone = Clef(pitch: SpelledPitch(noteLetter: .f, octave: .octave3), location: StaffLocation(type: .line, number: 4))

	// TODO: Is this one correct?
	public static let suboctaveTreble = Clef(pitch: SpelledPitch(noteLetter: .g, octave: .octave3), location: StaffLocation(type: .line, number: 1))

	///
	/// Calculates the pitch for the given staff location for this Clef.
	///
	/// - parameter location: The location on the staff for which you would like to know the pitch.
	/// - returns: The pitch at the given staff location or nil if the `Clef` is un-pitched.
	/// - throws:
	///    - `ClefError.internal`: Logic error with math
	///    - `ClefError.octaveOutOfRange`
	///
	internal func pitch(at location: StaffLocation) throws -> SpelledPitch? {
		guard let pitch = pitch else { return nil }

		let largestNoteLetter = NoteLetter.b.rawValue
		let delta = location.halfSteps - staffLocation.halfSteps
		guard delta != 0 else { return pitch }

		let clefPitchRawValue = pitch.noteLetter.rawValue

		// Add the delta to the clef raw value
		let newPitchRawWithDelta = clefPitchRawValue + delta
		///
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
				///
				/// If the value is an exact multiple, it has not crossed the octave border yet.
				/// Therefore, subtract one from the value for the octave delta.
				///
				return Int(octaveDeltaRaw - 1)
			}

			/// In any other case, just floor the value and that is the delta for the octave.
			return Int(floor(octaveDeltaRaw))
		}()
		let newOctaveValue = pitch.octave.rawValue + octaveDelta
		guard let newOctave = Octave(rawValue: newOctaveValue) else { throw ClefError.octaveOutOfRange }
		return SpelledPitch(noteLetter: newNoteLetter, octave: newOctave)
	}
}

public enum ClefError: Error {
	case octaveOutOfRange
	case internalError
}

extension Clef: Equatable {
	public static func == (lhs: Clef, rhs: Clef) -> Bool {
		lhs.pitch == rhs.pitch && lhs.staffLocation.halfSteps == rhs.staffLocation.halfSteps
	}
}

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
		case Clef.baritone: return "baritone"
		case Clef.suboctaveTreble: return "suboctaveTreble"
		case let clef where clef.pitch == nil: return "neutral"
		default:
			return "\(pitch!)@\(staffLocation.locationType)\(staffLocation.number)"
		}
	}
}
