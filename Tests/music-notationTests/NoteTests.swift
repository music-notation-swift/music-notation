//
//  NoteTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

@testable import MusicNotationCoreMac
import XCTest

class NoteTests: XCTestCase {
	var note: Note!

	override func setUp() {
		super.setUp()
		note = Note(noteDuration: .eighth, pitch: SpelledPitch(noteLetter: .c, octave: .octave1))
	}

	// MARK: - modifyTie(_:)

	// MARK: Failures

	func testModifyTieBeginAndEndTryBegin() {
		note.tie = .beginAndEnd
		assertThrowsError(NoteError.invalidRequestedTieState) {
			try note.modifyTie(.begin)
		}
	}

	func testModifyTieBeginAndEndTryEnd() {
		note.tie = .beginAndEnd
		assertThrowsError(NoteError.invalidRequestedTieState) {
			try note.modifyTie(.end)
		}
	}

	// MARK: Successes

	func testModifyTieNilTryBegin() {
		note.tie = nil
		assertNoErrorThrown { try note.modifyTie(.begin) }
		XCTAssert(note.tie == .begin)
	}

	func testModifyTieNilTryEnd() {
		note.tie = nil
		assertNoErrorThrown { try note.modifyTie(.end) }
		XCTAssert(note.tie == .end)
	}

	func testModifyTieNilTryBeginAndEnd() {
		note.tie = nil
		assertNoErrorThrown { try note.modifyTie(.beginAndEnd) }
		XCTAssert(note.tie == .beginAndEnd)
	}

	func testModifyTieBeginTryEnd() {
		note.tie = .begin
		assertNoErrorThrown { try note.modifyTie(.end) }
		XCTAssert(note.tie == .beginAndEnd)
	}

	func testModifyTieEndTryBegin() {
		note.tie = .end
		assertNoErrorThrown { try note.modifyTie(.begin) }
		XCTAssert(note.tie == .beginAndEnd)
	}

	func testModifyTieBeginTryBegin() {
		note.tie = .begin
		assertNoErrorThrown { try note.modifyTie(.begin) }
		XCTAssert(note.tie == .begin)
	}

	func testModifyTieBeginAndEndTryBeginAndEnd() {
		note.tie = .end
		assertNoErrorThrown { try note.modifyTie(.end) }
		XCTAssert(note.tie == .end)
	}

	func testModifyTieEndTryEnd() {
		note.tie = .beginAndEnd
		assertNoErrorThrown { try note.modifyTie(.beginAndEnd) }
		XCTAssert(note.tie == .beginAndEnd)
	}

	// MARK: - removeTie()

	// MARK: Failures

	func testRemoveTieNilTryBeginAndEnd() {
		note.tie = nil

		assertThrowsError(NoteError.invalidRequestedTieState) {
			try note.removeTie(.beginAndEnd)
		}
	}

	func testRemoveTieEndTryBegin() {
		// Requested state doesn't match
		note.tie = .end
		assertThrowsError(NoteError.invalidRequestedTieState) {
			try note.removeTie(.begin)
		}
	}

	func testRemoveTieBeginTryEnd() {
		// Requested state doesn't match
		note.tie = .begin
		assertThrowsError(NoteError.invalidRequestedTieState) {
			try note.removeTie(.end)
		}
	}

	// MARK: Successes

	func testRemoveTieBegin() {
		note.tie = .begin
		assertNoErrorThrown { try note.removeTie(.begin) }
		XCTAssertNil(note.tie)
	}

	func testRemoveTieEnd() {
		note.tie = .end
		assertNoErrorThrown { try note.removeTie(.end) }
		XCTAssertNil(note.tie)
	}

	func testRemoveTieBeginAndEndTryBegin() {
		note.tie = .beginAndEnd
		assertNoErrorThrown { try note.removeTie(.begin) }
		XCTAssert(note.tie == .end)
	}

	func testRemoveTieBeginAndEndTryEnd() {
		note.tie = .beginAndEnd
		assertNoErrorThrown { try note.removeTie(.end) }
		XCTAssert(note.tie == .begin)
	}

	func testRemoveTieNilTryBegin() {
		note.tie = nil
		assertNoErrorThrown { try note.removeTie(.begin) }
		XCTAssertNil(note.tie)
	}

	func testRemoveTieNilTryEnd() {
		note.tie = nil
		assertNoErrorThrown { try note.removeTie(.end) }
		XCTAssertNil(note.tie)
	}
}
