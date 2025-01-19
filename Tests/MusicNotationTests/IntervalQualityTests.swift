//
//	IntervalQualityTests.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2025-01-19.
//	Copyright © 2025 Steven Woolgar. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class IntervalQualityTests {
	@Test func fourthQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .fourth, semitones: 4))
		#expect(quality == .diminishedFourth)
	}

	@Test func perfectFifthQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .fifth, semitones: 7))
		#expect(quality == .perfectFifth)
	}

	@Test func augmentedFifthQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .fifth, semitones: 8))
		#expect(quality == .augmentedFifth)
	}

	@Test func diminishedSixthQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .sixth, semitones: 7))
		#expect(quality == .diminishedSixth)
	}

	@Test func minorSixthQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .sixth, semitones: 8))
		#expect(quality == .minorSixth)
	}

	@Test func majorSixthQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .sixth, semitones: 9))
		#expect(quality == .majorSixth)
	}

	@Test func augmentedSixthQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .sixth, semitones: 10))
		#expect(quality == .augmentedSixth)
	}

	@Test func diminishedSeventhQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .seventh, semitones: 9))
		#expect(quality == .diminishedSeventh)
	}

	@Test func minorSeventhQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .seventh, semitones: 10))
		#expect(quality == .minorSeventh)
	}

	@Test func majorSeventhQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .seventh, semitones: 11))
		#expect(quality == .majorSeventh)
	}

	@Test func augmentedSeventhQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .seventh, semitones: 12))
		#expect(quality == .augmentedSeventh)
	}

	@Test func diminishedOctaveQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .octave, semitones: 11))
		#expect(quality == .diminishedOctave)
	}

	@Test func perfectOctaveQuality() async throws {
		let quality = try IntervalQuality(with: try! Interval(diatonicIntervalQuality: .octave, semitones: 12))
		#expect(quality == .perfectOctave)
	}
}
