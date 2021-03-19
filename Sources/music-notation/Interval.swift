//
//  Interval.swift
//  MusicNotationCore
//
//  Created by Rob Hudson on 8/1/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public enum IntervalQuality: String {
	case perfect
	case minor
	case major
	case diminished
	case augmented
	case doublyDiminished = "doubly diminished"
	case doublyAugmented = "doubly augmented"

	public var abbreviation: String {
		switch self {
		case .perfect:
			return "P"
		case .minor:
			return "m"
		case .major:
			return "M"
		case .diminished:
			return "d"
		case .augmented:
			return "A"
		case .doublyDiminished:
			return "dd"
		case .doublyAugmented:
			return "AA"
		}
	}
}

public struct Interval {
	public let quality: IntervalQuality
	public let number: Int

	public init(quality: IntervalQuality, number: Int) throws {
		guard number > 0 else {
			throw IntervalError.numberNotPositive
		}

		let simpleInterval = ((number - 1) % 7) + 1

		switch simpleInterval {
		case 1, 4, 5:
			guard quality != .major, quality != .minor else {
				throw IntervalError.invalidQuality
			}
		default:
			guard quality != .perfect else {
				throw IntervalError.invalidQuality
			}
		}

		self.quality = quality
		self.number = number
	}
}

extension Interval: CustomDebugStringConvertible {
	public var debugDescription: String {
		var description = "\(quality.rawValue) "
		switch number {
		case 1:
			description += "unison"
		case 8:
			description += "octave"
		default:
			description += ordinal(forNumber: number)
		}

		return description
	}

	private func ordinal(forNumber: Int) -> String {
		let tens = (number / 10) % 10
		let ones = number % 10

		let suffix: String

		switch (tens, ones) {
		case (1, _):
			suffix = "th"
		case (_, 1):
			suffix = "st"
		case (_, 2):
			suffix = "nd"
		case (_, 3):
			suffix = "rd"
		default:
			suffix = "th"
		}

		return "\(number)\(suffix)"
	}

	public var abbreviation: String {
		"\(quality.abbreviation)\(number)"
	}
}

public enum IntervalError: Error {
	case invalidQuality
	case numberNotPositive
}
