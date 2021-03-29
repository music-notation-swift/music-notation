//
//	Enharmonic.swift
//	MusicNotationCore
//
//	Created by Rob Hudson on 2016-09-16.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

public protocol Enharmonic: Equatable {
	func isEnharmonic(with other: Self) -> Bool
}
