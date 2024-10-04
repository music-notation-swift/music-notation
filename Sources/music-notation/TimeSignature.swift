//
//	TimeSignature.swift
//	MusicNotation
//
//	Created by Kyle Sherman on 2015-06-12.
//	Copyright © 2015 Kyle Sherman. All rights reserved.
//

/// The time signature (also known as `meter signature`, `metre signature`, or `measure signature`) is a notational convention used
/// in Western musical notation to specify how many beats (pulses) are contained in each measure (bar), and which note value
/// is equivalent to a beat.
///
/// In a music score, the time signature appears at the beginning as a time symbol or stacked numerals, such as common time
/// or `3/4` (read common time and three-four time, respectively), immediately following the key signature (or immediately
/// following the clef symbol if the key signature is empty). A mid-score time signature, usually immediately following a
/// barline, indicates a change of meter.
///
/// There are various types of time signatures, depending on whether the music follows regular (or symmetrical) beat patterns,
/// including simple (e.g., `3/4` and `4/4`), and compound (e.g., `9/8` and `12/8`); or involves shifting beat patterns, including
/// complex (e.g., `5/4` or `7/8`), odd (e.g., `5/8` & `3/8` or `6/8` & `3/4`), additive (e.g., `3 + 2/8 + 3`),
/// fractional (e.g., ​`2½/4`), and complex meters (e.g., `3/10` or `5/24`).
///
/// - Note:
///		A regular (`.simple`, `.compound`) time signature is one which represents 2, 3 or 4 main beats per bar.
///		- **Duple** time means 2 main beats per bar
///		- **Triple** time means 3 main beats per bar
///		- **Quadruple** time means 4 main beats per bar
///
///		`.simple` time signatures have a main beat which divides into **two** 1st level sub-beats.
///		`.compound` time signatures have a main beat which divides into **three** 1st level sub-beats.
///		In both `.simple` and `.compound` time, 2nd level sub-beats always subdivide by two (never by three).
///
///
///	# Meter and time signatures #
///
///	Meter involves the way multiple pulse layers work together to organize music in time. Standard meters in Western
///	music can be classified into _simple meters_ and _compound meters_, as well as _duple_, _triple_, and _quadruple meters_.
///
///	Duple, triple, and quadruple classifications result from the relationship between the counting pulse and the pulses
///	that are slower than the counting pulse. In other words, it is a question of grouping: how many beats occur in each bar.
///	If counting-pulse beats group into twos, we have duple meter; groups of three, triple meter; groups of four,
///	quadruple meter. Conducting patterns are determined based on these classifications.
///
///	Simple and compound classifications result from the relationship between the counting pulse and the pulses that are
///	faster than the counting pulse. In other words, it is a question of division: does each beat divide into two equal
///	parts, or three equal parts. Meters that divide the beat into two equal parts are simple meters; meters that divide
///	the beat into three equal parts are compound meters.
///
///	Thus, there are six types of standard meter in Western music:
///
///	- simple duple (beats group into two, divide into two)
///	- simple triple (beats group into three, divide into two)
///	- simple quadruple (beats group into four, divide into two)
///	- compound duple (beats group into two, divide into three)
///	- compound triple (beats group into three, divide into three)
///	- compound quadruple (beats group into four, divide into three)
///
///	In a time signature, the top number (and the top number only!) describes the type of meter. Following are the top
///	numbers that always correspond to each type of meter:
///
///	- simple duple: 2
///	- simple triple: 3
///	- simple quadruple: 4
///	- compound duple: 6
///	- compound triple: 9
///	- compound quadruple: 12
///
///	## Notating meter ##
///
/// As far as I can tell, there can be little to infer about a meter from simply the time signature (especially it's odd'ness).
/// For example, 8/8 is an odd meter which is counted as **1**-2-3, **2**-2-3, **3**-2 and 4/4 would be **1** &, **2** &, **3** &, **4** &.
/// And yet 9/8 is an even meter (**1**-2-3, **2**-2-3, **3**-2-3)
///
///	In _simple meters_, the bottom number of the time signature corresponds to the type of note corresponding to a
///	single beat. If a simple meter is notated such that each quarter note corresponds to a beat, the bottom
///	number of the time signature is 4. If a simple meter is notated such that each half note corresponds
///	to a beat, the bottom number of the time signature is 2. If a simple meter is notated such that each eighth
///	note corresponds to a beat, the bottom number of the time signature is 8. And so on.
///
///	In _compound meters_, the bottom number of the time signature corresponds to the type of note corresponding to
///	a _single division of the beat_. If a compound meter is notated such that each dotted-quarter note corresponds to
///	a beat, the eighth note is the division of the beat, and thus the bottom number of the time signature is 8.
///	If a compound meter is notated such that each dotted-half note corresponds to a beat, the quarter note is the
///	division of the beat, and thus the bottom number of the time signature is 4. Note that because the beat is
///	divided into three in a compound meter, the beat is always three times as long as the division note, and
///	_the beat is always dotted_.
///	
public struct TimeSignature: Sendable {
	public let numerator: Int
	public let denominator: Int
	public let tempo: Int
	
	public init(numerator: Int, denominator: Int, tempo: Int) {
		// TODO: Check the validity of all these values
		self.numerator = numerator
		self.denominator = denominator
		self.tempo = tempo
	}
}

extension TimeSignature: CustomDebugStringConvertible {
	public var debugDescription: String {
		"\(numerator)/\(denominator)"
	}
}

extension TimeSignature: Equatable {
	public static func == (lhs: TimeSignature, rhs: TimeSignature) -> Bool {
		if lhs.numerator == rhs.numerator,
		   lhs.denominator == rhs.denominator,
		   lhs.tempo == rhs.tempo {
			return true
		} else {
			return false
		}
	}
}
