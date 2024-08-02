//
//	Bend.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2024-07-30.
//	Copyright © 2024 Steven Woolgar. All rights reserved.
//

public struct Bend: Sendable {
	let interval: Int
	let duration: Int
}

public enum BendType: Sendable {
	case bend(bendValue: Bend)
	case release(releaseValue: Bend)
	case bendAndRelease(bendValue: Bend, holdDuration: Int, releaseValue: Bend)
	case hold
	case prebend(interval: Int)
	case prebendAndBend(interval: Int, bendValue: Bend)
	case prebendAndRelease(interval: Int, releaseValue: Bend)
}
