//
//	Version.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2025-01-04.
//	Copyright © 2025 Steven Woolgar. All rights reserved.
//

/// A definition of the version of music notation version that created the Score
/// (the score has a version).
public struct Version: Sendable {
	let major: Int
	let minor: Int
	let revision: Int
}
