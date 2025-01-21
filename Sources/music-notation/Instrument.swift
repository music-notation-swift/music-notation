//
//	Instrument.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2021-03-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

public struct Instrument: Sendable {
	/// Number of steps that this instrument is transposed. `chromatic` is measured in semitones.
	public let name: String
	public let shortName: String

	public let chromaticTransposition: Int
	public let diatonicTransposition: Int

	public init(
		name: String = "",
		shortName: String = "",
		chromaticTransposition: Int = 0,
		diatonicTransposition: Int = 0
	) {
		self.name = name
		self.shortName = shortName
		self.chromaticTransposition = chromaticTransposition
		self.diatonicTransposition = diatonicTransposition
	}
}
