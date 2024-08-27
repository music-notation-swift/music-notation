//
//	Instrument.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2021-03-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

public struct Instrument: Sendable {
	public let name: String
	
	public let lineCount: Int
	
	/// Number of steps that this instrument is transposed.
	public let chromaticTransposition: Int
	public let octaveTransposition: Int
	
	public init(
		name: String = "",
		lineCount: Int = 0,
		chromaticTransposition: Int = 0,
		octaveTransposition: Int = 0
	) {
		self.name = name
		self.lineCount = lineCount
		self.chromaticTransposition = chromaticTransposition
		self.octaveTransposition = octaveTransposition
	}
}
