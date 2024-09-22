//
//	Accidental.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2021-04-06.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

// MARK: -
public enum Accidental: Sendable, Element {
	case sharp
	case doubleSharp
	case flat
	case doubleFlat
	case natural
}

// MARK: -
extension Accidental: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch self {
		case .sharp: return "♯"
		case .doubleSharp: return "𝄪"
		case .flat: return "♭"
		case .doubleFlat: return "𝄫"
		case .natural: return "♮"
		}
	}
}
