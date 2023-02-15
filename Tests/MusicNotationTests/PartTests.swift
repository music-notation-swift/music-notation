//
//  PartTests.swift
//  MusicNotationCore
//
//  Created by Robert J. Sarvis Jr on 2/14/23.
//

@testable import MusicNotation
import XCTest

// swiftlint:disable force_try
// swiftlint:disable implicitly_unwrapped_optional
final class PartTests: XCTestCase {
    
    let testPartName = "testPartName"
    let testPartShortName = "testShortName"
    
    var part: Part!
    
    override func setUp() {
        super.setUp()
        let staff = Staff(clef: .treble, instrument: Instrument())
        part = Part(name: testPartName, shortName: testPartShortName, staves: [staff])
    }
    
    func testDescription() {
        XCTAssertEqual(part!.debugDescription, "staves(staff(treble Instrument(name: \"\", lineCount: 0, chromaticTransposition: 0, octaveTransposition: 0) ))")
    }
    
    func testPartNames() {
        XCTAssertEqual(part!.name, testPartName)
        XCTAssertEqual(part!.shortName, testPartShortName)
    }

}
