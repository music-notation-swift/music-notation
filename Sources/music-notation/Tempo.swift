//
//  Tempo.swift
//  MusicNotation
//
//  Created by Steven Woolgar on 07/18/2024.
//  Copyright © 2024 Steven Woolgar. All rights reserved.
//

/// Represents the tempo of the section at the point of attachment.
///
/// In musical terminology, tempo (Italian for 'time'; plural 'tempos', or tempi from the Italian plural),
/// also known as beats per minute, is the speed or pace of a given composition. In classical music,
/// tempo is typically indicated with an instruction at the start of a piece (often using conventional
/// Italian terms) and is usually measured in beats per minute (BPM). In modern classical compositions,
/// a "metronome mark" in beats per minute may supplement or replace the normal tempo marking, while in
/// modern genres like electronic dance music, tempo will typically simply be stated in BPM.
///
public struct Tempo: Sendable {
	public enum TempoType: Sendable {
		case undefined
		case pause
		case linear
		case ramp
	}
	
	public enum NoteUnit: Int, Sendable {
		case eight = 1
		case quarter
		case dottedQuarter
		case half
		case dottedHalf
	}
	
	public let type: TempoType
	public let position: Double
	public let value: Int
	public let unit: NoteUnit
	public let text: String?
	
	public init(
		type: TempoType,
		position: Double,
		value: Int,
		unit: NoteUnit,
		text: String? = nil
	) {
		self.type = type
		self.position = position
		self.value = value
		self.unit = unit
		self.text = text
	}
}

extension Tempo: Equatable {
	public static func == (lhs: Tempo, rhs: Tempo) -> Bool {
		guard lhs.type == rhs.type,
			  lhs.position == rhs.position,
			  lhs.value == rhs.value,
			  lhs.unit == rhs.unit,
			  lhs.text == rhs.text else { return false }
		return true
	}
}
// Mark: - Debug

extension Tempo: CustomDebugStringConvertible {
	public var debugDescription: String {
		if let text {
			return "type: \(type), position: \(position), value: \(value), unit: \(unit), text: \(text)"
		} else {
			return "type: \(type), position: \(position), value: \(value), unit: \(unit)"
		}
	}
}

public enum TempoError: Error {
	case invalidTempoIndex
}
