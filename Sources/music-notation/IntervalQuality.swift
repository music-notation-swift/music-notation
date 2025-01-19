//
//	IntervalQuality.swift
//	music-notation
//
//	Created by Steven Woolgar on 2025-01-19.
//	Copyright © 2025 Steven Woolgar. All rights reserved.
//

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
