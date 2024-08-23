//
//	PitchTests.swift
//	MusicNotation
//
//	Created by Rob Hudson on 2016-07-29.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class PitchTests {
    @Test func pitch1() async throws {
        let pitch = SpelledPitch(.c, .octave3)
        #expect(pitch.debugDescription == "c3")
    }

    @Test func pitch2() async throws {
        let pitch = SpelledPitch(.g, accidental: .sharp, .octave6)
        #expect(pitch.debugDescription == "g♯6")
    }

    @Test func pitch3() async throws {
        let pitch = SpelledPitch(.e, accidental: .flat, .octave2)
        #expect(pitch.debugDescription == "e♭2")
    }

    @Test func pitch4() async throws {
        let pitch = SpelledPitch(.a, accidental: .natural, .octave4)
        #expect(pitch.debugDescription == "a4")
    }

    @Test func pitch5() async throws {
        let pitch = SpelledPitch(.b, accidental: .doubleSharp, .octave5)
        #expect(pitch.debugDescription == "b𝄪5")
    }

    @Test func pitch6() async throws {
        let pitch = SpelledPitch(.f, accidental: .doubleFlat, .octave7)
        #expect(pitch.debugDescription == "f𝄫7")
    }

    // MARK: - ==

    // MARK: Failures

    @Test func notEqual() async throws {
        let pitch1 = SpelledPitch(.b, accidental: .flat, .octave5)
        let pitch2 = SpelledPitch(.b, accidental: .flat, .octave4)

        #expect(pitch1 != pitch2)
    }

    // MARK: Successes

    @Test func equal() async throws {
        let pitch1 = SpelledPitch(.d, accidental: .sharp, .octave1)
        let pitch2 = SpelledPitch(.d, accidental: .sharp, .octave1)

        #expect(pitch1 == pitch2)
    }

    // MARK: - MIDI numbers

    // MARK: Successes

    @Test func ridiculouslyLowNote() async throws {
        let pitch = SpelledPitch(.c, accidental: .natural, .octaveNegative1)

        #expect(pitch.midiNoteNumber == 0)
    }

    @Test func lowNote() async throws {
        let pitch = SpelledPitch(.f, accidental: .sharp, .octave1)

        #expect(pitch.midiNoteNumber == 30)
    }

    @Test func midRangeNote() async throws {
        let pitch = SpelledPitch(.d, .octave4)

        #expect(pitch.midiNoteNumber == 62)
    }

    @Test func highNote() async throws {
        let pitch = SpelledPitch(.c, accidental: .flat, .octave8)

        #expect(pitch.midiNoteNumber == 107)
    }

    // MARK: - isEnharmonic(with:)

    // MARK: Failures

    @Test func differentAccidentals() async throws {
        let pitch1 = SpelledPitch(.d, accidental: .flat, .octave1)
        let pitch2 = SpelledPitch(.d, accidental: .sharp, .octave1)

        #expect(pitch1 != pitch2)
        #expect(!pitch1.isEnharmonic(with: pitch2))
    }

    @Test func samePitchDifferentOctaves() async throws {
        let pitch1 = SpelledPitch(.e, accidental: .natural, .octave5)
        let pitch2 = SpelledPitch(.e, accidental: .natural, .octave6)

        #expect(pitch1 != pitch2)
        #expect(!pitch1.isEnharmonic(with: pitch2))
    }

    @Test func enharmonicPitchDifferentOctaves() async throws {
        let pitch1 = SpelledPitch(.f, accidental: .doubleSharp, .octave2)
        let pitch2 = SpelledPitch(.g, accidental: .natural, .octave5)

        #expect(pitch1 != pitch2)
        #expect(!pitch1.isEnharmonic(with: pitch2))
    }

    // MARK: Successes

    @Test func samePitchIsEnharmonic() async throws {
        let pitch1 = SpelledPitch(.g, accidental: .natural, .octave6)
        let pitch2 = SpelledPitch(.g, accidental: .natural, .octave6)

        #expect(pitch1 == pitch2)
        #expect(pitch1.isEnharmonic(with: pitch2))
        // Transitive property
        #expect(pitch2.isEnharmonic(with: pitch1))
    }

    @Test func enharmonicNotEquatable() async throws {
        let pitch1 = SpelledPitch(.a, accidental: .flat, .octave3)
        let pitch2 = SpelledPitch(.g, accidental: .sharp, .octave3)

        #expect(pitch1 != pitch2)
        #expect(pitch1.isEnharmonic(with: pitch2))
    }

    @Test func naturalAndFlat() async throws {
        let pitch1 = SpelledPitch(.e, accidental: .natural, .octave4)
        let pitch2 = SpelledPitch(.f, accidental: .flat, .octave4)

        #expect(pitch1 != pitch2)
        #expect(pitch1.isEnharmonic(with: pitch2))
    }

    @Test func doubleFlat() async throws {
        let pitch1 = SpelledPitch(.b, accidental: .doubleFlat, .octave2)
        let pitch2 = SpelledPitch(.a, .octave2)

        #expect(pitch1 != pitch2)
        #expect(pitch1.isEnharmonic(with: pitch2))
    }

    @Test func differentOctaveNumbers() async throws {
        let pitch1 = SpelledPitch(.b, accidental: .sharp, .octave6)
        let pitch2 = SpelledPitch(.c, accidental: .natural, .octave7)

        #expect(pitch1 != pitch2)
        #expect(pitch1.isEnharmonic(with: pitch2))
    }
}
