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
	let testName = "testName"
	let testShortName = "testShortName"

	var staff1: Staff!
	var staff2: Staff!
	var part: Part!

	init() {
		staff1 = Staff(clef: .treble)
		staff2 = Staff(clef: .bass)
		part = Part(instrument: Instrument(name: testName, shortName: testShortName), staves: [staff1, staff2])
	}

	deinit {
		part = nil
	}

	@Test func debugDescription() async throws {
		#expect(part!.debugDescription == "Part(instrument `testName`), staves(staff(treble )\nstaff(bass ))")
	}

	@Test func partNames() async throws {
		#expect(part!.instrument?.name == testName)
		#expect(part!.instrument?.shortName == testShortName)
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
		part.append(Staff(clef: .soprano))
		#expect(part.staves.count == 3)
	}

	@Test func remove() async throws {
		part.remove(at: 0)
		#expect(part.staves.count == 1)
	}
}
