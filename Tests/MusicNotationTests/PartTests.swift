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

	var staff1: Staff!
	var staff2: Staff!
	var part: Part!

	init() {
		staff1 = Staff(clef: .treble, instrument: Instrument())
		staff2 = Staff(clef: .bass, instrument: Instrument())
		part = Part(name: testPartName, shortName: testPartShortName, staves: [staff1, staff2])
	}

	deinit {
		part = nil
	}

	@Test func debugDescription() async throws {
		#expect(part!.debugDescription == "staves(staff(treble Instrument(lineCount: 0, chromaticTransposition: 0, octaveTransposition: 0) ), staff(bass Instrument(lineCount: 0, chromaticTransposition: 0, octaveTransposition: 0) ))")
	}

	@Test func partNames() async throws {
		#expect(part!.name == testPartName)
		#expect(part!.shortName == testPartShortName)
	}

	@Test func iterator() async throws {
		var iterator = part.makeIterator()
		if let actual = iterator.next() {
			#expect(actual.clef == .treble)
		} else {
			Issue.record("Iterator didn't return correct value for next()")
		}
	}

	@Test func appendStaff() async throws {
		part.appendStaff(Staff(clef: .soprano, instrument: Instrument()))
		#expect(part.staves.count == 3)
	}

	@Test func remove() async throws {
		try part.remove(at: 0)
		#expect(part.staves.count == 1)
	}

	@Test func removeThrowAtEmpty() async throws {
		try part.remove(at: 0)
		try part.remove(at: 0)
		#expect(throws: PartError.self) {
			try part.remove(at: 0)
		}
	}

	@Test func insertStaffInvalidIndex() async throws {
		let staff3 = Staff(clef: .soprano, instrument: Instrument())
		#expect(throws: PartError.staffIndexOutOfRange) {
			try part.insertStaff(staff3, at: 17)
		}
	}
}
