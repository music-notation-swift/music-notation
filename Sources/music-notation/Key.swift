//
//	Key.swift
//	music-notation
//
//	Created by Kyle Sherman on 2016-07-11.
//	Copyright © 2015 Kyle Sherman. All rights reserved.
//

public enum KeyType: Sendable {
	case major
	case minor
}

public struct Key: Sendable {
	fileprivate let type: KeyType
	fileprivate let noteLetter: NoteLetter
	fileprivate let accidental: Accidental

	public init(noteLetter: NoteLetter, accidental: Accidental = .natural, type: KeyType = .major) {
		self.noteLetter = noteLetter
		self.accidental = accidental
		self.type = type
	}
}

extension Key: CustomDebugStringConvertible {
	public var debugDescription: String {
		"\(noteLetter)\(accidental.debugDescription) \(type)"
	}
}

extension Key: Equatable {
	public static func == (lhs: Key, rhs: Key) -> Bool {
		if lhs.type == rhs.type,
		   lhs.noteLetter == rhs.noteLetter,
		   lhs.accidental == rhs.accidental {
			return true
		}
		return false
	}
}
