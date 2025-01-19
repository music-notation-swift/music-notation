//
//	Instrument.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2021-03-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

public struct Instrument: Sendable {
	/// Number of steps that this instrument is transposed. `chromatic` is measured in semitones.
	public let chromaticTransposition: Int
	public let diatonicTransposition: Int

	public init(
		chromaticTransposition: Int = 0,
		diatonicTransposition: Int = 0
	) {
		self.chromaticTransposition = chromaticTransposition
		self.diatonicTransposition = diatonicTransposition
	}
}
