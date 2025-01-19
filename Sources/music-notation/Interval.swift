//
//	Interval.swift
//	music-notation
//
//	Created by Rob Hudson on 2016-08-01.
//	Rewritten by Steven Woolgar on 2025-01-19.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

public enum DiatonicIntervalQuality {
	case unison
	case second
	case third
	case fourth
	case fifth
	case sixth
	case seventh
	case octave

	init(with interval: Interval) throws {
		switch (interval.diatonic, interval.semitones()) {
		case (0, 0), (0, 1):
			self = .unison

		case (1, 0), (1, 1), (1, 2), (1, 3):
			self = .second

		case (2, 2), (2, 3), (2, 4), (2, 5):
			self = .third

		case (3, 4), (3, 5), (3, 6):
			self = .fourth

		case (4, 6), (4, 7), (4, 8):
			self = .fifth

		case (5, 7), (5, 8), (5, 9), (5, 10):
			self = .sixth

		case (6, 9), (6, 10), (6, 11), (6, 12):
			self = .seventh

		case (7, 11), (7, 12):
			self = .octave

		default:
			throw IntervalError.intervalOutOfBounds
		}
	}
}

public enum IntervalQuality {
	// Unisons
	case perfectUnison
	case augmentedUnison

	// Seconds
	case diminishedSecond
	case minorSecond
	case majorSecond
	case augmentedSecond

	// Thirds
	case diminishedThird
	case minorThird
	case majorThird
	case augmentedThird

	// Fourths
	case diminishedFourth
	case perfectFourth
	case augmentedFourth

	// Fifths
	case diminishedFifth
	case perfectFifth
	case augmentedFifth

	// Sixths
	case diminishedSixth
	case minorSixth
	case majorSixth
	case augmentedSixth

	// Sevenths
	case diminishedSeventh
	case minorSeventh
	case majorSeventh
	case augmentedSeventh

	// Octaves
	case diminishedOctave
	case perfectOctave

	init(with interval: Interval) throws {
		switch (interval.diatonic, interval.semitones()) {
		case (0, 0):
			self = .perfectUnison
		case (0, 1):
			self = .augmentedUnison

		case (1, 0):
			self = .diminishedSecond
		case (1, 1):
			self = .minorSecond
		case (1, 2):
			self = .majorSecond
		case (1, 3):
			self = .augmentedSecond

		case (2, 2):
			self = .diminishedThird
		case (2, 3):
			self = .minorThird
		case (2, 4):
			self = .majorThird
		case (2, 5):
			self = .augmentedThird

		case (3, 4):
			self = .diminishedFourth
		case (3, 5):
			self = .perfectFourth
		case (3, 6):
			self = .augmentedFourth

		case (4, 6):
			self = .diminishedFifth
		case (4, 7):
			self = .perfectFifth
		case (4, 8):
			self = .augmentedFifth

		case (5, 7):
			self = .diminishedSixth
		case (5, 8):
			self = .minorSixth
		case (5, 9):
			self = .majorSixth
		case (5, 10):
			self = .augmentedSixth

		case (6, 9):
			self = .diminishedSeventh
		case (6, 10):
			self = .minorSeventh
		case (6, 11):
			self = .majorSeventh
		case (6, 12):
			self = .augmentedSeventh

		case (7, 11):
			self = .diminishedOctave
		case (7, 12):
			self = .perfectOctave

		default:
			throw IntervalError.intervalOutOfBounds
		}
	}
}

public struct Interval {
	enum Constants {
		static let semitonesPerOctave = 12
		static let diatonicQualitiesPerOctave = 7
	}

	public let diatonic: Int
	private let _semitones: Int

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
