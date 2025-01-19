//
//	Interval.swift
//	music-notation
//
//	Created by Rob Hudson on 2016-08-01.
//	Rewritten by Steven Woolgar on 2025-01-19.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

public struct Interval {
	enum Constants {
		static let semitonesPerOctave = 12
		static let diatonicQualitiesPerOctave = 7
	}

	public let diatonic: Int
	internal let _semitones: Int

	public init(diatonic: Int, semitones: Int) throws {
		guard semitones >= 0 else { throw IntervalError.semitoneNumberNotPositive }
		guard diatonic >= 0 else { throw IntervalError.diatonicNumberNotPositive }

		self.diatonic = diatonic
		self._semitones = semitones

		// Check the validity of the interval by attempting to calculate these qualities.
		_ = try self.intervalQuality()
		_ = try self.diatonicIntervalQuality()
	}

	public init(diatonicIntervalQuality: DiatonicIntervalQuality, semitones: Int) throws {
		guard semitones >= 0 else { throw IntervalError.semitoneNumberNotPositive }

		let diatonic = switch diatonicIntervalQuality {
		case .unison:  0
		case .second:  1
		case .third:   2
		case .fourth:  3
		case .fifth:   4
		case .sixth:   5
		case .seventh: 6
		case .octave:  7
		}

		try self.init(diatonic: diatonic, semitones: semitones)
	}

	public init(intervalQuality: IntervalQuality) throws {
		switch intervalQuality {
		case .perfectUnison:
			try self .init(diatonic: 0, semitones: 0)

		case .augmentedUnison:
			try self .init(diatonic: 0, semitones: 1)

		// Seconds
		case .diminishedSecond:
			try self .init(diatonic: 1, semitones: 0)
		case .minorSecond:
			try self .init(diatonic: 1, semitones: 1)
		case .majorSecond:
			try self .init(diatonic: 1, semitones: 2)
		case .augmentedSecond:
			try self .init(diatonic: 1, semitones: 3)

		// Thirds
		case .diminishedThird:
			try self .init(diatonic: 2, semitones: 2)
		case .minorThird:
			try self .init(diatonic: 2, semitones: 3)
		case .majorThird:
			try self .init(diatonic: 2, semitones: 4)
		case .augmentedThird:
			try self .init(diatonic: 2, semitones: 5)

		// Fourths
		case .diminishedFourth:
			try self .init(diatonic: 3, semitones: 4)
		case .perfectFourth:
			try self .init(diatonic: 3, semitones: 5)
		case .augmentedFourth:
			try self .init(diatonic: 3, semitones: 6)

		// Fifths
		case .diminishedFifth:
			try self .init(diatonic: 4, semitones: 6)
		case .perfectFifth:
			try self .init(diatonic: 4, semitones: 7)
		case .augmentedFifth:
			try self .init(diatonic: 4, semitones: 8)

		// Sixths
		case .diminishedSixth:
			try self .init(diatonic: 5, semitones: 7)
		case .minorSixth:
			try self .init(diatonic: 5, semitones: 8)
		case .majorSixth:
			try self .init(diatonic: 5, semitones: 9)
		case .augmentedSixth:
			try self .init(diatonic: 5, semitones: 10)

		// Sevenths
		case .diminishedSeventh:
			try self .init(diatonic: 6, semitones: 9)
		case .minorSeventh:
			try self .init(diatonic: 6, semitones: 10)
		case .majorSeventh:
			try self .init(diatonic: 6, semitones: 11)
		case .augmentedSeventh:
			try self .init(diatonic: 6, semitones: 12)

		// Octaves
		case .diminishedOctave:
			try self .init(diatonic: 7, semitones: 11)
		case .perfectOctave:
			try self .init(diatonic: 7, semitones: 12)
		}
	}

	// Normalized number of semitones. This allows use to support multi-octal intervals and yet
	// still know what the intra-octave values are.
	func semitones() -> Int {
		((_semitones - 1) % Constants.semitonesPerOctave) + 1
	}

	func diatonicIntervalQuality() throws -> DiatonicIntervalQuality {
		try DiatonicIntervalQuality(with: self)
	}

	func intervalQuality() throws -> IntervalQuality {
		try IntervalQuality(with: self)
	}
}

public enum IntervalError: Error {
	case semitoneNumberNotPositive
	case diatonicNumberNotPositive
	case intervalOutOfBounds
}
