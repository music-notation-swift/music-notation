//
//	ClefTests.swift
//	MusicNotationCore
//
//	Created by Kyle Sherman on 2016-10-16.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class ClefTests {
    @Test func initForCustomOnLine() async throws {
        let clef = Clef(pitch: SpelledPitch(.c, .octave4),
                        location: StaffLocation(.line, 0))
        #expect(clef.staffLocation.halfSteps == 0)
    }

    @Test func initForCustomOnSpace() async throws {
        let clef = Clef(pitch: SpelledPitch(.g, .octave4),
                        location: StaffLocation(.space, 1))
        #expect(clef.staffLocation.halfSteps == 3)
    }

    @Test func initForCustomNegativeLedger() async throws {
        let clef = Clef(pitch: SpelledPitch(.g, .octave3),
                        location: StaffLocation(.line, -2))
        #expect(clef.staffLocation.halfSteps == -4)
    }

    @Test func initForCustomPositiveLedger() async throws {
        let clef = Clef(pitch: SpelledPitch(.a, .octave4),
                        location: StaffLocation(.line, 7))
        #expect(clef.staffLocation.halfSteps == 14)
    }

    @Test func pitchAtOctaveOutOfRange() async throws {
        #expect(throws: ClefError.octaveOutOfRange) {
            try Clef.treble.pitch(at: StaffLocation(.space, 300))
        }

        #expect(throws: ClefError.octaveOutOfRange) {
            try Clef.treble.pitch(at: StaffLocation(.line, 300))
        }

        #expect(throws: ClefError.octaveOutOfRange) {
            try Clef.treble.pitch(at: StaffLocation(.space, -300))
        }

        #expect(throws: ClefError.octaveOutOfRange) {
            try Clef.treble.pitch(at: StaffLocation(.line, -300))
        }
    }

    @Test func pitchAtUnpitched() async throws {
        var neutral: SpelledPitch?
        #expect(throws: Never.self) { neutral = try Clef.neutral.pitch(at: StaffLocation(.space, 1)) }
        #expect(neutral == nil)

        var tab: SpelledPitch?
        #expect(throws: Never.self) {
            tab = try Clef.tab.pitch(at: StaffLocation(.space, 1))
        }
        #expect(tab == nil)
    }

    @Test func pitchAtLocationWithinStaffIncrease() async throws {
        #expect(try Clef.treble.pitch(at: StaffLocation(.space, 2)) == SpelledPitch(.c, .octave5))
        #expect(try Clef.treble.pitch(at: StaffLocation(.line, 2)) == SpelledPitch(.b, .octave4))
        #expect(try Clef.bass.pitch(at: StaffLocation(.space, 3)) == SpelledPitch(.g, .octave3))
        #expect(try Clef.alto.pitch(at: StaffLocation(.line, 4)) == SpelledPitch(.g, .octave4))
        #expect(try Clef.soprano.pitch(at: StaffLocation(.space, 3)) == SpelledPitch(.c, .octave5))

        let customBClef = Clef(
            pitch: SpelledPitch(.b, .octave3),
            location: StaffLocation(.line, 2)
        )
        #expect(try customBClef.pitch(at: StaffLocation(.space, 2)) == SpelledPitch(.c, .octave4))
    }

    @Test func pitchAtLocationDecrease() async throws {
        #expect(try Clef.treble.pitch(at: StaffLocation(.line, 0)) == SpelledPitch(.e, .octave4))
        #expect(try Clef.treble.pitch(at: StaffLocation(.space, -1)) == SpelledPitch(.d, .octave4))
        #expect(try Clef.alto.pitch(at: StaffLocation(.line, -3)) == SpelledPitch(.g, .octave2))
        #expect(try Clef.alto.pitch(at: StaffLocation(.line, -2)) == SpelledPitch(.b, .octave2))
        #expect(try Clef.alto.pitch(at: StaffLocation(.space, 1)) == SpelledPitch(.b, .octave3))
        #expect(try Clef.bass.pitch(at: StaffLocation(.line, 1)) == SpelledPitch(.b, .octave2))
    }

    @Test func pitchAtSamePitchAsClef() async throws {
        #expect(try Clef.treble.pitch(at: StaffLocation(.line, 1)) ==
                SpelledPitch(.g, .octave4))
        #expect(try Clef.soprano.pitch(at: StaffLocation(.line, 0)) ==
                SpelledPitch(.c, .octave4))
    }

    @Test func pitchAtNegativeClefDecrease() async throws {
        let negativeClef = Clef(pitch: SpelledPitch(.d, .octave3), location: StaffLocation(.line, -1))
        #expect(try negativeClef.pitch(at: StaffLocation(.line, -2)) == SpelledPitch(.b, .octave2))
    }

    @Test func equalityFailStandard() async throws {
        #expect(Clef.treble != Clef.bass)
    }

    @Test func equalityFailDifferentPitch() async throws {
        let custom1 = Clef(
            pitch: SpelledPitch(.a, .octave3),
            location: StaffLocation(.line, 1)
        )
        let custom2 = Clef(
            pitch: SpelledPitch(.a, .octave2),
            location: StaffLocation(.line, 1)
        )
        #expect(custom1 != custom2)
    }

    @Test func equalityFailDifferentLineNumber() async throws {
        let custom1 = Clef(
            pitch: SpelledPitch(.a, .octave2),
            location: StaffLocation(.space, 1)
        )
        let custom2 = Clef(
            pitch: SpelledPitch(.a, .octave2),
            location: StaffLocation(.space, 2)
        )
        #expect(custom1 != custom2)
    }

    @Test func equalityStandard() async throws {
        #expect(Clef.treble == Clef.treble)
    }

    @Test func equalityCustom() async throws {
        let custom1 = Clef(
            pitch: SpelledPitch(.a, .octave2),
            location: StaffLocation(.line, 1)
        )
        let custom2 = Clef(
            pitch: SpelledPitch(.a, .octave2),
            location: StaffLocation(.line, 1)
        )
        #expect(custom1 == custom2)
    }

    @Test func equalityCustomWithStandard() async throws {
        let treble = Clef(
            pitch: SpelledPitch(.g, .octave4),
            location: StaffLocation(.line, 1)
        )
        #expect(treble == Clef.treble)
    }

    @Test func descriptionStandard() async throws {
        #expect(Clef.treble.debugDescription == "treble")
        #expect(Clef.bass.debugDescription == "bass")
        #expect(Clef.tenor.debugDescription == "tenor")
        #expect(Clef.alto.debugDescription == "alto")
        #expect(Clef.neutral.debugDescription == "neutral")
        #expect(Clef.tab.debugDescription == "neutral")
        #expect(Clef.frenchViolin.debugDescription == "frenchViolin")
        #expect(Clef.soprano.debugDescription == "soprano")
        #expect(Clef.mezzoSoprano.debugDescription == "mezzoSoprano")
        #expect(Clef.baritone.debugDescription == "baritone")
        #expect(Clef.suboctaveTreble.debugDescription == "suboctaveTreble")
    }

    @Test func descriptionCustom() async throws {
        let custom = Clef(
            pitch: SpelledPitch(.a, .octave3),
            location: StaffLocation(.line, 1)
        )
        #expect(custom.debugDescription == "a3@line1")

        let customNeutral = Clef(
            pitch: nil,
            location: StaffLocation(.space, 3)
        )
        #expect(customNeutral.debugDescription == "neutral")
    }
}
