//
//	Instrument.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2021-03-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

public struct Instrument {
	public let name: String

	public let lineCount: Int

	/// Number of steps that this instrument is transposed.
	public let chromaticTransposition: Int
	public let octaveTransposition: Int
}
