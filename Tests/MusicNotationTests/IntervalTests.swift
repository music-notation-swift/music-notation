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

    @Test func minorSecond() async throws {
		let interval = try! Interval(diatonic: 1, semitones: 1)
		#expect(try interval.diatonicIntervalQuality() == .second)
		#expect(try interval.intervalQuality() == .minorSecond)
    }

    @Test func minorThird() async throws {
		let interval = try! Interval(diatonic: 2, semitones: 3)
		#expect(try interval.diatonicIntervalQuality() == .third)
		#expect(try interval.intervalQuality() == .minorThird)
    }

    @Test func augmentedFourth() async throws {
		let interval = try! Interval(diatonic: 3, semitones: 6)
		#expect(try interval.diatonicIntervalQuality() == .fourth)
		#expect(try interval.intervalQuality() == .augmentedFourth)
    }

    @Test func diminishedFifth() async throws {
		let interval = try! Interval(diatonic: 4, semitones: 6)
		#expect(try interval.diatonicIntervalQuality() == .fifth)
		#expect(try interval.intervalQuality() == .diminishedFifth)
    }

    @Test func octave() async throws {
		let interval = try! Interval(diatonic: 7, semitones: 12)
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
}
