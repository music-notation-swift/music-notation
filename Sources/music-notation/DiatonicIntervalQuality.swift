//
//	DiatonicIntervalQuality.swift
//	music-notation
//
//	Created by Steven Woolgar on 2025-01-19.
//	Copyright © 2025 Steven Woolgar. All rights reserved.
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
