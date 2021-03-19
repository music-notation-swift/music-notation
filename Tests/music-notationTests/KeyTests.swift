//
//  KeyTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 11/27/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import MusicNotationCoreMac
import XCTest

class KeyTests: XCTestCase {
	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	// MARK: - debugDescription

	func testDebugDescription() {
		let naturalMajor = Key(noteLetter: .c)
		XCTAssertEqual(naturalMajor.debugDescription, "c♮ major")
		let naturalMinor = Key(noteLetter: .a, accidental: .natural, type: .minor)
		XCTAssertEqual(naturalMinor.debugDescription, "a♮ minor")
		let sharpMajor = Key(noteLetter: .b, accidental: .sharp, type: .major)
		XCTAssertEqual(sharpMajor.debugDescription, "b♯ major")
		let doubleFlatMinor = Key(noteLetter: .e, accidental: .doubleFlat, type: .minor)
		XCTAssertEqual(doubleFlatMinor.debugDescription, "e𝄫 minor")
	}

	// MARK: - ==

	func testEqualityTrue() {
		let sharpMinor = Key(noteLetter: .g, accidental: .sharp, type: .minor)
		let sharpMinor2 = Key(noteLetter: .g, accidental: .sharp, type: .minor)
		XCTAssertTrue(sharpMinor == sharpMinor2)
	}

	func testEqualityFalse() {
		let differentType = Key(noteLetter: .b, accidental: .natural, type: .major)
		let differentType2 = Key(noteLetter: .b, accidental: .natural, type: .minor)
		XCTAssertFalse(differentType == differentType2)

		let differentNoteLetter = Key(noteLetter: .a)
		let differentNoteLetter2 = Key(noteLetter: .f)
		XCTAssertFalse(differentNoteLetter == differentNoteLetter2)

		let differentAccidental = Key(noteLetter: .a, accidental: .sharp, type: .major)
		let differentAccidental2 = Key(noteLetter: .a, accidental: .doubleSharp, type: .major)
		XCTAssertFalse(differentAccidental == differentAccidental2)
	}
}
