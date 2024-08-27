//
//	TimeSignature.swift
//	MusicNotation
//
//	Created by Kyle Sherman on 2015-06-12.
//	Copyright © 2015 Kyle Sherman. All rights reserved.
//

public struct TimeSignature: Sendable {
	public let numerator: Int
	public let denominator: Int
	public let tempo: Int
	
	public init(numerator: Int, denominator: Int, tempo: Int) {
		// TODO: Check the validity of all these values
		self.numerator = numerator
		self.denominator = denominator
		self.tempo = tempo
	}
}

extension TimeSignature: CustomDebugStringConvertible {
	public var debugDescription: String {
		"\(numerator)/\(denominator)"
	}
}

extension TimeSignature: Equatable {
	public static func == (lhs: TimeSignature, rhs: TimeSignature) -> Bool {
		if lhs.numerator == rhs.numerator,
		   lhs.denominator == rhs.denominator,
		   lhs.tempo == rhs.tempo {
			return true
		} else {
			return false
		}
	}
}
