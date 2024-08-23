//
//  PartTests.swift
//  MusicNotation
//
//  Created by Steven Woolgar on 2024-098-23.
//  Copyright © 2024 Steven Woolgar. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class PartTests {
    let testPartName = "testPartName"
    let testPartShortName = "testShortName"
    
    var part: Part!
    
    init() {
        let staff = Staff(clef: .treble, instrument: Instrument())
        part = Part(name: testPartName, shortName: testPartShortName, staves: [staff])
    }

    deinit {
        part = nil
    }

    @Test func debugDescription() async throws {
        #expect(part!.debugDescription == "staves(staff(treble Instrument(name: \"\", lineCount: 0, chromaticTransposition: 0, octaveTransposition: 0) ))")
    }
    
    func partNames() async throws {
        #expect(part!.name == testPartName)
        #expect(part!.shortName == testPartShortName)
    }

}
