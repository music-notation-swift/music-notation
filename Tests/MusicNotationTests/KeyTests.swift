//
//	KeyTests.swift
//	MusicNotationCore
//
//	Created by Kyle Sherman on 2016-11-27.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class KeyTests {
    @Test func debugDescription() async throws {
        let naturalMajor = Key(noteLetter: .c)
        #expect(naturalMajor.debugDescription == "c♮ major")
        let naturalMinor = Key(noteLetter: .a, accidental: .natural, type: .minor)
        #expect(naturalMinor.debugDescription == "a♮ minor")
        let sharpMajor = Key(noteLetter: .b, accidental: .sharp, type: .major)
        #expect(sharpMajor.debugDescription == "b♯ major")
        let doubleFlatMinor = Key(noteLetter: .e, accidental: .doubleFlat, type: .minor)
        #expect(doubleFlatMinor.debugDescription == "e𝄫 minor")
    }

    @Test func equalityTrue() async throws {
        let sharpMinor = Key(noteLetter: .g, accidental: .sharp, type: .minor)
        let sharpMinor2 = Key(noteLetter: .g, accidental: .sharp, type: .minor)
        #expect(sharpMinor == sharpMinor2)
    }

    @Test func equalityFalse() async throws {
        let differentType = Key(noteLetter: .b, accidental: .natural, type: .major)
        let differentType2 = Key(noteLetter: .b, accidental: .natural, type: .minor)
        #expect(differentType != differentType2)

        let differentNoteLetter = Key(noteLetter: .a)
        let differentNoteLetter2 = Key(noteLetter: .f)
        #expect(differentNoteLetter != differentNoteLetter2)

        let differentAccidental = Key(noteLetter: .a, accidental: .sharp, type: .major)
        let differentAccidental2 = Key(noteLetter: .a, accidental: .doubleSharp, type: .major)
        #expect(differentAccidental != differentAccidental2)
    }
}
