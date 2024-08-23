//
//	NoteTests.swift
//	MusicNotation
//
//	Created by Kyle Sherman on 2015-06-15.
//	Copyright © 2015 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class NoteTests {
    var note: Note!

    init() {
        note = Note(.eighth, pitch: SpelledPitch(.c, .octave1))
    }

    // MARK: - modifyTie(_:)

    // MARK: Failures

    @Test func modifyTieBeginAndEndTryBegin() async throws {
        note.tie = .beginAndEnd
        #expect(throws: NoteError.invalidRequestedTieState) {
            try note.modifyTie(.begin)
        }
    }

    @Test func modifyTieBeginAndEndTryEnd() async throws {
        note.tie = .beginAndEnd
        #expect(throws: NoteError.invalidRequestedTieState) {
            try note.modifyTie(.end)
        }
    }

    // MARK: Successes

    @Test func modifyTieNilTryBegin() async throws {
        note.tie = nil
        try note.modifyTie(.begin)
        #expect(note.tie == .begin)
    }

    @Test func modifyTieNilTryEnd() async throws {
        note.tie = nil
        try note.modifyTie(.end)
        #expect(note.tie == .end)
    }

    @Test func modifyTieNilTryBeginAndEnd() async throws {
        note.tie = nil
        try note.modifyTie(.beginAndEnd)
        #expect(note.tie == .beginAndEnd)
    }

    @Test func modifyTieBeginTryEnd() async throws {
        note.tie = .begin
        try note.modifyTie(.end)
        #expect(note.tie == .beginAndEnd)
    }

    @Test func modifyTieEndTryBegin() async throws {
        note.tie = .end
        try note.modifyTie(.begin)
        #expect(note.tie == .beginAndEnd)
    }

    @Test func modifyTieBeginTryBegin() async throws {
        note.tie = .begin
        try note.modifyTie(.begin)
        #expect(note.tie == .begin)
    }

    @Test func modifyTieBeginAndEndTryBeginAndEnd() async throws {
        note.tie = .end
        try note.modifyTie(.end)
        #expect(note.tie == .end)
    }

    @Test func modifyTieEndTryEnd() async throws {
        note.tie = .beginAndEnd
        try note.modifyTie(.beginAndEnd)
        #expect(note.tie == .beginAndEnd)
    }

    // MARK: - removeTie()

    // MARK: Failures

    @Test func removeTieNilTryBeginAndEnd() async throws {
        note.tie = nil

        #expect(throws: NoteError.invalidRequestedTieState) {
            try note.removeTie(.beginAndEnd)
        }
    }

    @Test func removeTieEndTryBegin() async throws {
        // Requested state doesn't match
        note.tie = .end
        #expect(throws: NoteError.invalidRequestedTieState) {
            try note.removeTie(.begin)
        }
    }

    @Test func removeTieBeginTryEnd() async throws {
        // Requested state doesn't match
        note.tie = .begin
        #expect(throws: NoteError.invalidRequestedTieState) {
            try note.removeTie(.end)
        }
    }

    // MARK: Successes

    @Test func removeTieBegin() async throws {
        note.tie = .begin
        try note.removeTie(.begin)
        #expect(note.tie == nil)
    }

    @Test func removeTieEnd() async throws {
        note.tie = .end
        try note.removeTie(.end)
        #expect(note.tie == nil)
    }

    @Test func removeTieBeginAndEndTryBegin() async throws {
        note.tie = .beginAndEnd
        try note.removeTie(.begin)
        #expect(note.tie == .end)
    }

    @Test func removeTieBeginAndEndTryEnd() async throws {
        note.tie = .beginAndEnd
        try note.removeTie(.end)
        #expect(note.tie == .begin)
    }

    @Test func removeTieNilTryBegin() async throws {
        note.tie = nil
        try note.removeTie(.begin)
        #expect(note.tie == nil)
    }

    @Test func removeTieNilTryEnd() async throws {
        note.tie = nil
        try note.removeTie(.end)
        #expect(note.tie == nil)
    }
}
