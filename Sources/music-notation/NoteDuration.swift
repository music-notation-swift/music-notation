//
//  NoteDuration.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 8/20/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

public struct NoteDuration: Hashable {
	public enum Value: CustomDebugStringConvertible, Hashable {
		case large
		case long
		case doubleWhole
		case whole
		case half
		case quarter
		case eighth
		case sixteenth
		case thirtySecond
		case sixtyFourth
		case oneTwentyEighth
		case twoFiftySixth

		public var debugDescription: String {
			switch self {
			case .large: return "8"
			case .long: return "4"
			case .doubleWhole: return "2"
			case .whole: return "1"
			case .half: return "1/2"
			case .quarter: return "1/4"
			case .eighth: return "1/8"
			case .sixteenth: return "1/16"
			case .thirtySecond: return "1/32"
			case .sixtyFourth: return "1/64"
			case .oneTwentyEighth: return "1/128"
			case .twoFiftySixth: return "1/256"
			}
		}
	}

	///
	/// This holds the value for the bottom number of the time signature and relates the `NoteDuration.Value` to this
	/// number or nil if it cannot be used for the bottom number of a time signature.
	///
	public enum TimeSignatureValue: Int, Hashable {
		case whole = 1
		case half = 2
		case quarter = 4
		case eighth = 8
		case sixteenth = 16
		case thirtySecond = 32
		case sixtyFourth = 64
		case oneTwentyEighth = 128
		// As far as I can tell, 128th note is the largest allowed

		init?(value: Value) {
			switch value {
			case .whole: self = .whole
			case .half: self = .half
			case .quarter: self = .quarter
			case .eighth: self = .eighth
			case .sixteenth: self = .sixteenth
			case .thirtySecond: self = .thirtySecond
			case .sixtyFourth: self = .sixtyFourth
			case .oneTwentyEighth: self = .oneTwentyEighth
			default: return nil
			}
		}

		fileprivate var duration: NoteDuration {
			switch self {
			case .whole: return .whole
			case .half: return .half
			case .quarter: return .quarter
			case .eighth: return .eighth
			case .sixteenth: return .sixteenth
			case .thirtySecond: return .thirtySecond
			case .sixtyFourth: return .sixtyFourth
			case .oneTwentyEighth: return .oneTwentyEighth
			}
		}
	}

	/// The duration value of the `NoteDuration`. i.e. eighth, sixteenth, etc.
	public let value: Value
	/// The number of dots for this `NoteDuration`.
	public let dotCount: Int
	///
	/// The value for which the bottom number of time signature will be if this duration value is used.
	///
	public let timeSignatureValue: TimeSignatureValue?
	///
	/// This is the number of ticks for the duration with the `dotCount` taken into account. This is a mathematical
	/// representation of a `NoteDuration` that can be used for different calculations of equivalence.
	///
	internal var ticks: Double {
		var ticks: Double = 0
		let baseTicks: Double = {
			switch value {
			case .large: return 65536
			case .long: return 32768
			case .doubleWhole: return 16384
			case .whole: return 8192
			case .half: return 4096
			case .quarter: return 2048
			case .eighth: return 1024
			case .sixteenth: return 512
			case .thirtySecond: return 256
			case .sixtyFourth: return 128
			case .oneTwentyEighth: return 64
			case .twoFiftySixth: return 32
			}
		}()
		ticks += baseTicks
		var dotValue = baseTicks / 2
		for _ in 0 ..< dotCount {
			ticks += dotValue
			dotValue = dotValue / 2
		}
		return ticks
	}

	private init(value: Value) {
		self.value = value
		dotCount = 0
		timeSignatureValue = TimeSignatureValue(value: value)
	}

	///
	/// Use this initializer if you would like to create a `NoteDuration` with 1 or more dots.
	/// Otherwise, use the static properties if you do not need any dots.
	///
	/// - parameter value: The value of the duration. i.e. whole, quarter, eighth, etc.
	/// - parameter dotCount: The number of dots for this duration.
	/// - throws:
	///    - `NoteDurationError.negativeDotCountInvalid`
	///
	public init(value: Value, dotCount: Int) throws {
		guard dotCount >= 0 else {
			throw NoteDurationError.negativeDotCountInvalid
		}
		self.value = value
		self.dotCount = dotCount
		timeSignatureValue = TimeSignatureValue(value: value)
	}

	/// Initialize a `NoteDuration` from a `TimeSignatureValue` which encapsulates the bottom number of a `TimeSignature`.
	public init(timeSignatureValue: TimeSignatureValue) {
		self = timeSignatureValue.duration
	}

	public static let large = NoteDuration(value: .large)
	public static let long = NoteDuration(value: .long)
	public static let doubleWhole = NoteDuration(value: .doubleWhole)
	public static let whole = NoteDuration(value: .whole)
	public static let half = NoteDuration(value: .half)
	public static let quarter = NoteDuration(value: .quarter)
	public static let eighth = NoteDuration(value: .eighth)
	public static let sixteenth = NoteDuration(value: .sixteenth)
	public static let thirtySecond = NoteDuration(value: .thirtySecond)
	public static let sixtyFourth = NoteDuration(value: .sixtyFourth)
	public static let oneTwentyEighth = NoteDuration(value: .oneTwentyEighth)
	public static let twoFiftySixth = NoteDuration(value: .twoFiftySixth)

	///
	/// This can be used to find out how many of a certain duration fits within another a duration. This takes into account
	/// the `dotCount` as well.
	///
	/// For example: How many eighth notes fit within a quarter note?
	/// `NoteDuration.number(of: .eighth, within: .quarter)` = 2.0
	///
	/// - parameter noteDuration: the `NoteDuration` you would like to see how many would fit.
	/// - parameter baseNoteDuration: the `NoteDuration` that you would to see how many of the first duration will fit into.
	/// - returns: A `Double` representing how many of the first duration fit within the second. If the first duration is
	///    larger than the second, it will be a Double number less than 0.
	///
	public static func number(of noteDuration: NoteDuration, within baseNoteDuration: NoteDuration) -> Double {
		baseNoteDuration.ticks / noteDuration.ticks
	}
}

extension NoteDuration: Equatable {
	public static func == (lhs: NoteDuration, rhs: NoteDuration) -> Bool {
		lhs.value == rhs.value && lhs.dotCount == rhs.dotCount
	}
}

extension NoteDuration: CustomDebugStringConvertible {
	public var debugDescription: String {
		let dots = String(repeating: ".", count: dotCount)
		return "\(value.debugDescription)\(dots)"
	}
}

public enum NoteDurationError: Error {
	case negativeDotCountInvalid
}
