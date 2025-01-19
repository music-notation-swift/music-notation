//
//	IntervalTests.swift
//	MusicNotation
//
//	Created by Rob Hudson on 2016-08-01.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class IntervalTests {
	@Test func unison() async throws {
		let interval = try! Interval(diatonic: 0, semitones: 0)
		#expect(try interval.diatonicIntervalQuality() == .unison)
		#expect(try interval.intervalQuality() == .perfectUnison)
	}

	@Test func unisonQuality() async throws {
		let interval = try! Interval(diatonicIntervalQuality: .unison, semitones: 0)
		#expect(try interval.diatonicIntervalQuality() == .unison)
		#expect(try interval.intervalQuality() == .perfectUnison)
	}

	@Test func minorSecond() async throws {
		let interval = try! Interval(diatonic: 1, semitones: 1)
		#expect(try interval.diatonicIntervalQuality() == .second)
		#expect(try interval.intervalQuality() == .minorSecond)
	}

	@Test func minorSecondDiatonicQuality() async throws {
		let interval = try! Interval(diatonicIntervalQuality: .second, semitones: 1)
		#expect(try interval.diatonicIntervalQuality() == .second)
		#expect(try interval.intervalQuality() == .minorSecond)
	}

	@Test func minorThird() async throws {
		let interval = try! Interval(diatonic: 2, semitones: 3)
		#expect(try interval.diatonicIntervalQuality() == .third)
		#expect(try interval.intervalQuality() == .minorThird)
	}

	@Test func minorThirdDiatonicQuality() async throws {
		let interval = try! Interval(diatonicIntervalQuality: .third, semitones: 3)
		#expect(try interval.diatonicIntervalQuality() == .third)
		#expect(try interval.intervalQuality() == .minorThird)
	}

	@Test func augmentedFourth() async throws {
		let interval = try! Interval(diatonic: 3, semitones: 6)
		#expect(try interval.diatonicIntervalQuality() == .fourth)
		#expect(try interval.intervalQuality() == .augmentedFourth)
	}

	@Test func augmentedFourthDiatonicQuality() async throws {
		let interval = try! Interval(diatonicIntervalQuality: .fourth, semitones: 6)
		#expect(try interval.diatonicIntervalQuality() == .fourth)
		#expect(try interval.intervalQuality() == .augmentedFourth)
	}

	@Test func diminishedFifth() async throws {
		let interval = try! Interval(diatonic: 4, semitones: 6)
		#expect(try interval.diatonicIntervalQuality() == .fifth)
		#expect(try interval.intervalQuality() == .diminishedFifth)
	}

	@Test func diminishedFifthDiatonicQuality() async throws {
		let interval = try! Interval(diatonicIntervalQuality: .fifth, semitones: 6)
		#expect(try interval.diatonicIntervalQuality() == .fifth)
		#expect(try interval.intervalQuality() == .diminishedFifth)
	}

	@Test func diminishedFifthDiatonicQualityOctave() async throws {
		let interval = try! Interval(
			diatonicIntervalQuality: .fifth,
			semitones: 6 + Interval.Constants.semitonesPerOctave
		)
		#expect(try interval.diatonicIntervalQuality() == .fifth)
		#expect(try interval.intervalQuality() == .diminishedFifth)
	}

	@Test func octave() async throws {
		let interval = try! Interval(diatonic: 7, semitones: 12)
		#expect(try interval.diatonicIntervalQuality() == .octave)
		#expect(try interval.intervalQuality() == .perfectOctave)
	}

	@Test func octaveQuality() async throws {
		let interval = try! Interval(diatonicIntervalQuality: .octave, semitones: 12)
		#expect(try interval.diatonicIntervalQuality() == .octave)
		#expect(try interval.intervalQuality() == .perfectOctave)
	}

	@Test func largeInterval() async throws {
		let interval = try! Interval(diatonic: 5, semitones: 33)
		#expect(try interval.diatonicIntervalQuality() == .sixth)
		#expect(try interval.intervalQuality() == .majorSixth)
	}

	@Test func majorOctaveInvalid() async throws {
		#expect(throws: IntervalError.intervalOutOfBounds) {
			_ = try Interval(diatonic: 2, semitones: 8)
		}
	}

	@Test func perfectNinthInvalid() async throws {
		#expect(throws: IntervalError.intervalOutOfBounds) {
			_ = try Interval(diatonicIntervalQuality: .fifth, semitones: 9)
		}
	}

	@Test func nagativeSemitoneInvalid() async throws {
		#expect(throws: IntervalError.semitoneNumberNotPositive) {
			_ = try Interval(diatonicIntervalQuality: .octave, semitones: -1)
		}
	}

	@Test func nagativeDiatonicInvalid() async throws {
		#expect(throws: IntervalError.diatonicNumberNotPositive) {
			_ = try Interval(diatonic: -1, semitones: 0)
		}
	}

	// MARK: - IntervalQuality init

	@Test func perfectUnisonQuality() async throws {
		let interval = try! Interval(intervalQuality: .perfectUnison)
		#expect(interval.diatonic == 0)
		#expect(interval._semitones == 0)
	}

	@Test func augmentedUnisonQuality() async throws {
		let interval = try! Interval(intervalQuality: .augmentedUnison)
		#expect(interval.diatonic == 0)
		#expect(interval._semitones == 1)
	}

	@Test func diminishedSecondQuality() async throws {
		let interval = try! Interval(intervalQuality: .diminishedSecond)
		#expect(interval.diatonic == 1)
		#expect(interval._semitones == 0)
	}

	@Test func minorSecondQuality() async throws {
		let interval = try! Interval(intervalQuality: .minorSecond)
		#expect(interval.diatonic == 1)
		#expect(interval._semitones == 1)
	}

	@Test func majorSecondQuality() async throws {
		let interval = try! Interval(intervalQuality: .majorSecond)
		#expect(interval.diatonic == 1)
		#expect(interval._semitones == 2)
	}

	@Test func augmentedSecondQuality() async throws {
		let interval = try! Interval(intervalQuality: .augmentedSecond)
		#expect(interval.diatonic == 1)
		#expect(interval._semitones == 3)
	}

	@Test func diminishedThirdQuality() async throws {
		let interval = try! Interval(intervalQuality: .diminishedThird)
		#expect(interval.diatonic == 2)
		#expect(interval._semitones == 2)
	}

	@Test func minorThirdQuality() async throws {
		let interval = try! Interval(intervalQuality: .minorThird)
		#expect(interval.diatonic == 2)
		#expect(interval._semitones == 3)
	}

	@Test func majorThirdQuality() async throws {
		let interval = try! Interval(intervalQuality: .majorThird)
		#expect(interval.diatonic == 2)
		#expect(interval._semitones == 4)
	}

	@Test func augmentedThirdQuality() async throws {
		let interval = try! Interval(intervalQuality: .augmentedThird)
		#expect(interval.diatonic == 2)
		#expect(interval._semitones == 5)
	}

	@Test func diminishedFourthQuality() async throws {
		let interval = try! Interval(intervalQuality: .diminishedFourth)
		#expect(interval.diatonic == 3)
		#expect(interval._semitones == 4)
	}

	@Test func perfectFourthQuality() async throws {
		let interval = try! Interval(intervalQuality: .perfectFourth)
		#expect(interval.diatonic == 3)
		#expect(interval._semitones == 5)
	}

	@Test func augmentedFourthQuality() async throws {
		let interval = try! Interval(intervalQuality: .augmentedFourth)
		#expect(interval.diatonic == 3)
		#expect(interval._semitones == 6)
	}
}
