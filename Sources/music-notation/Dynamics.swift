//
//	Dynamics.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2021-04-06.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

public enum Dynamics: Sendable {
	case ppp
	case pp
	case p
	case mp
	case mf
	case f
	case ff
	case fff
}

extension Dynamics {
	func name() -> String {
		switch self {
		case .ppp:	return "pianississimo"
		case .pp:	return "pianissimo"
		case .p:	return "piano"
		case .mp:	return "mezzo-piano"
		case .mf:	return "mezzo-forte"
		case .f:	return "forte"
		case .ff:	return "fortissimo"
		case .fff:	return "fortississimo"
		}
	}

	// LOC!
	func level() -> String {
		switch self {
		case .ppp:	return "very very quiet"
		case .pp:	return "very quiet"
		case .p:	return "quiet"
		case .mp:	return "moderately quiet"
		case .mf:	return "moderately loud"
		case .f:	return "loud"
		case .ff:	return "very loud"
		case .fff:	return "very very loud"
		}
	}
}
