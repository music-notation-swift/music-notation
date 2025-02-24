//
//	Jump.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2024-08-27.
//	Copyright © 2024 Steven Woolgar. All rights reserved.
//

public enum MarkerType: CaseIterable {
	case segno
	case varSegno
	case coda
	case varCoda
	case codetta
	case fine
	case toCoda
	case toCodaSymbol
	case daCoda
	case dalDoppioSegnoAlCoda
	case daDoppiaCoda
	case userMarker

	static func marker(from string: String) throws -> MarkerType {
		switch string {
		case "segno":
			return .segno
		case "varsegno":
			return .varSegno
		case "coda":
			return .coda
		case "Var Coda":
			return .varCoda
		case "Codetta":
			return .codetta
		case "Fine":
			return .fine
		case "To Coda":
			return .toCoda
		case "To Coda Symbol":
			return .toCodaSymbol
		case "Da Coda":
			return .daCoda
		case "Dal Doppio Segno Al Coda":
			return .dalDoppioSegnoAlCoda
		case "Da Doppia Coda":
			return .daDoppiaCoda
		case "userMarker":
			return .userMarker
		default:
			throw MarkerTypeError.MarkerTypeStringConversionError
		}
	}
}

public enum MarkerTypeError: Error {
	case MarkerTypeStringConversionError
}
