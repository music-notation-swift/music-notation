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
        let interval = try! Interval(quality: .perfect, number: 1)
        #expect(interval.debugDescription == "perfect unison")
        #expect(interval.abbreviation == "P1")
    }

    @Test func minorSecond() async throws {
        let interval = try! Interval(quality: .minor, number: 2)
        #expect(interval.debugDescription == "minor 2nd")
        #expect(interval.abbreviation == "m2")
    }

    @Test func majorThird() async throws {
        let interval = try! Interval(quality: .major, number: 3)
        #expect(interval.debugDescription == "major 3rd")
        #expect(interval.abbreviation == "M3")
    }

    @Test func augmentedFourth() async throws {
        let interval = try! Interval(quality: .augmented, number: 4)
        #expect(interval.debugDescription == "augmented 4th")
        #expect(interval.abbreviation == "A4")
    }

    @Test func diminishedFifth() async throws {
        let interval = try! Interval(quality: .diminished, number: 5)
        #expect(interval.debugDescription == "diminished 5th")
        #expect(interval.abbreviation == "d5")
    }

    @Test func doublyAugmentedSixth() async throws {
        let interval = try! Interval(quality: .doublyAugmented, number: 6)
        #expect(interval.debugDescription == "doubly augmented 6th")
        #expect(interval.abbreviation == "AA6")
    }

    @Test func doubleDiminishedSeventh() async throws {
        let interval = try! Interval(quality: .doublyDiminished, number: 7)
        #expect(interval.debugDescription == "doubly diminished 7th")
        #expect(interval.abbreviation == "dd7")
    }

    @Test func octave() async throws {
        let interval = try! Interval(quality: .perfect, number: 8)
        #expect(interval.debugDescription == "perfect octave")
        #expect(interval.abbreviation == "P8")
    }

    @Test func largeInterval() async throws {
        let interval = try! Interval(quality: .perfect, number: 33)
        #expect(interval.debugDescription == "perfect 33rd")
        #expect(interval.abbreviation == "P33")
    }

    @Test func majorOctaveInvalid() async throws {
        #expect(throws: IntervalError.invalidQuality) {
            _ = try Interval(quality: .major, number: 8)
        }
    }

    @Test func perfectNinthInvalid() async throws {
        #expect(throws: IntervalError.invalidQuality) {
            _ = try Interval(quality: .perfect, number: 9)
        }
    }

    @Test func zeroInvalid() async throws {
        #expect(throws: IntervalError.numberNotPositive) {
            _ = try Interval(quality: .augmented, number: 0)
        }
    }

    @Test func negativeNumberInvalid() async throws {
        #expect(throws: IntervalError.numberNotPositive) {
            _ = try Interval(quality: .minor, number: -3)
        }
    }
}
