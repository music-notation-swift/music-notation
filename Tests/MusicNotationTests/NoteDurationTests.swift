//
//	NoteDurationTests.swift
//	MusicNotation
//
//	Created by Kyle Sherman on 2016-08-21.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class NoteDurationTests {
    let allValues: [NoteDuration.Value] = [
        .large,
        .long,
        .doubleWhole,
        .whole,
        .half,
        .quarter,
        .eighth,
        .sixteenth,
        .thirtySecond,
        .sixtyFourth,
        .oneTwentyEighth,
        .twoFiftySixth,
    ]

    // MARK: - init(value:dotCount:)

    // MARK: Failures

    @Test func initNegativeDotCount() async throws {
        #expect(throws: NoteDurationError.negativeDotCountInvalid) {
            _ = try NoteDuration(value: .quarter, dotCount: -1)
        }
    }

    // MARK: Successes

    @Test func initDotCountZero() async throws {
        let dotCount = 0

        try allValues.forEach {
            let duration = try NoteDuration(value: $0, dotCount: dotCount)
            #expect(duration.value == $0)
            #expect(duration.dotCount == dotCount)
        }
    }

    @Test func initDotCountNonZero() async throws {
        let dotCount = 2

        try allValues.forEach {
            let duration = try NoteDuration(value: $0, dotCount: dotCount)
            #expect(duration.value == $0)
            #expect(duration.dotCount == dotCount)
        }
    }

    @Test func initDotCountLargerThan4() async throws {
        let dotCount = 5

        try allValues.forEach {
            let duration = try NoteDuration(value: $0, dotCount: dotCount)
            #expect(duration.value == $0)
            #expect(duration.dotCount == dotCount)
        }
    }

    // MARK: - init(timeSignatureValue:)

    // Cannot fail

    func initTimeSignatureValue() async throws {
        #expect(
            NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .whole)!) ==
            .whole
        )
        #expect(
            NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .half)!) ==
            .half
        )
        #expect(
            NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .quarter)!) ==
            .quarter
        )
        #expect(
            NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .eighth)!) ==
            .eighth
        )
        #expect(
            NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .sixteenth)!) ==
            .sixteenth
        )
        #expect(
            NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .thirtySecond)!) ==
            .thirtySecond
        )
        #expect(
            NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .sixtyFourth)!) ==
            .sixtyFourth
        )
        #expect(
            NoteDuration(timeSignatureValue: NoteDuration.TimeSignatureValue(value: .oneTwentyEighth)!) ==
            .oneTwentyEighth
        )
    }

    // MARK: - number(of:equalTo:)

    // MARK: Successes

    func equalToForSameDuration() async throws {
        #expect(NoteDuration.number(of: .large, within: .large) == 1)
        #expect(NoteDuration.number(of: .long, within: .long) == 1)
        #expect(NoteDuration.number(of: .doubleWhole, within: .doubleWhole) == 1)
        #expect(NoteDuration.number(of: .whole, within: .whole) == 1)
        #expect(NoteDuration.number(of: .half, within: .half) == 1)
        #expect(NoteDuration.number(of: .quarter, within: .quarter) == 1)
        #expect(NoteDuration.number(of: .eighth, within: .eighth) == 1)
        #expect(NoteDuration.number(of: .sixteenth, within: .sixteenth) == 1)
        #expect(NoteDuration.number(of: .thirtySecond, within: .thirtySecond) == 1)
        #expect(NoteDuration.number(of: .sixtyFourth, within: .sixtyFourth) == 1)
        #expect(NoteDuration.number(of: .oneTwentyEighth, within: .oneTwentyEighth) == 1)
        #expect(NoteDuration.number(of: .twoFiftySixth, within: .twoFiftySixth) == 1)
    }

    @Test func equalToForSameDurationSingleDot() async throws {
        let noteDuration = try NoteDuration(value: .quarter, dotCount: 1)
        #expect(NoteDuration.number(of: try NoteDuration(value: .quarter, dotCount: 1), within: noteDuration) == 1)
    }

    @Test func equalToForSameDurationMultipleDot() async throws {
        let noteDuration = try NoteDuration(value: .quarter, dotCount: 3)
        #expect(NoteDuration.number(of: try NoteDuration(value: .quarter, dotCount: 3), within: noteDuration) == 1)
    }

    @Test func equalToForSmallerDuration() async throws {
        let noteDuration = NoteDuration.sixteenth
        #expect(NoteDuration.number(of: .sixtyFourth, within: noteDuration) == 4)
    }

    @Test func equalToForLargerDuration() async throws {
        let noteDuration = NoteDuration.quarter
        #expect(NoteDuration.number(of: .whole, within: noteDuration) == 0.25)
    }

    @Test func equalToForSmallerDurationSingleDotFromNoDot() async throws {
        let noteDuration = NoteDuration.quarter
        #expect(NoteDuration.number(of: try NoteDuration(value: .eighth, dotCount: 1), within: noteDuration) == Double(4) / 3)
    }

    @Test func equalToForSmallerDurationSingleDotFromSingleDot() async throws {
        let noteDuration = try NoteDuration(value: .quarter, dotCount: 1)
        #expect(NoteDuration.number(of: try NoteDuration(value: .sixteenth, dotCount: 1), within: noteDuration) == 4)
    }

    @Test func equalToForSmallerDurationDoubleDotFromDoubleDot() async throws {
        let noteDuration = try NoteDuration(value: .quarter, dotCount: 2)
        #expect(NoteDuration.number(of: try NoteDuration(value: .thirtySecond, dotCount: 2), within: noteDuration) == 8)
    }

    // MARK: - debugDescription

    @Test func debugDescriptionNoDot() async throws {
        #expect(NoteDuration.large.debugDescription == "8")
        #expect(NoteDuration.long.debugDescription == "4")
        #expect(NoteDuration.doubleWhole.debugDescription == "2")
        #expect(NoteDuration.whole.debugDescription == "1")
        #expect(NoteDuration.half.debugDescription == "1/2")
        #expect(NoteDuration.quarter.debugDescription == "1/4")
        #expect(NoteDuration.eighth.debugDescription == "1/8")
        #expect(NoteDuration.sixteenth.debugDescription == "1/16")
        #expect(NoteDuration.thirtySecond.debugDescription == "1/32")
        #expect(NoteDuration.sixtyFourth.debugDescription == "1/64")
        #expect(NoteDuration.oneTwentyEighth.debugDescription == "1/128")
        #expect(NoteDuration.twoFiftySixth.debugDescription == "1/256")
    }

    @Test func debugDescriptionSingleDot() async throws {
        #expect(try! NoteDuration(value: .quarter, dotCount: 1).debugDescription == "1/4.")
    }

    @Test func debugDescriptionMultipleDots() async throws {
        #expect(try! NoteDuration(value: .sixtyFourth, dotCount: 3).debugDescription == "1/64...")
    }

    // MARK: - timeSignatureValue

    @Test func timeSignatureValue() async throws {
        #expect(NoteDuration.large.timeSignatureValue == nil)
        #expect(NoteDuration.long.timeSignatureValue == nil)
        #expect(NoteDuration.doubleWhole.timeSignatureValue == nil)
        #expect(NoteDuration.whole.timeSignatureValue?.rawValue == 1)
        #expect(NoteDuration.half.timeSignatureValue?.rawValue == 2)
        #expect(NoteDuration.quarter.timeSignatureValue?.rawValue == 4)
        #expect(NoteDuration.eighth.timeSignatureValue?.rawValue == 8)
        #expect(NoteDuration.sixteenth.timeSignatureValue?.rawValue == 16)
        #expect(NoteDuration.thirtySecond.timeSignatureValue?.rawValue == 32)
        #expect(NoteDuration.sixtyFourth.timeSignatureValue?.rawValue == 64)
        #expect(NoteDuration.oneTwentyEighth.timeSignatureValue?.rawValue == 128)
        #expect(NoteDuration.twoFiftySixth.timeSignatureValue?.rawValue == nil)
    }
}
