//
//	Collection+HelpersTests.swift
//	MusicNotation
//
//	Created by Kyle Sherman on 2016-10-30.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class CollectionHelpersTests {
	var emptyArray: [Int]!
	var singleElementArray: [Int]!
	var multipleElementArray: [Int]!

	init() {
		emptyArray = []
		singleElementArray = [1]
		multipleElementArray = [1, 2, 3, 4, 5]
	}

	deinit {
		emptyArray = nil
		singleElementArray = nil
		multipleElementArray = nil
	}

	// MARK: - Collection

	// MARK: lastIndex

    @Test func lastIndex1Item() async throws {
        #expect(singleElementArray.lastIndex == 0)
	}

    @Test func lastIndexEmpty() async throws {
        #expect(emptyArray.lastIndex == 0)
	}

    @Test func lastIndexManyItems() async throws {
        #expect(multipleElementArray.lastIndex == 4)
	}

	// MARK: isValidIndex()

    @Test func isValidIndexInvalid() async throws {
        #expect(!emptyArray.isValidIndex(0))
        #expect(!emptyArray.isValidIndex(1))
        #expect(!singleElementArray.isValidIndex(1))
        #expect(!singleElementArray.isValidIndex(-1))
        #expect(!multipleElementArray.isValidIndex(7))
	}

    @Test func isValidIndexValid() async throws {
        #expect(singleElementArray.isValidIndex(0))
        #expect(multipleElementArray.isValidIndex(0))
        #expect(multipleElementArray.isValidIndex(1))
        #expect(multipleElementArray.isValidIndex(2))
        #expect(multipleElementArray.isValidIndex(3))
        #expect(multipleElementArray.isValidIndex(4))
	}

	// MARK: isValidIndexRange()

    @Test func isValidIndexClosedValid() async throws {
        #expect(singleElementArray.isValidIndexRange(Range(0 ... 0)))
        #expect(multipleElementArray.isValidIndexRange(Range(0 ... 4)))
	}

    @Test func isValidIndexClosedInvalid() async throws {
        #expect(!emptyArray.isValidIndexRange(Range(0 ... 0)))
        #expect(!singleElementArray.isValidIndexRange(Range(0 ... 1)))
        #expect(!multipleElementArray.isValidIndexRange(Range(0 ... 5)))
        #expect(!multipleElementArray.isValidIndexRange(Range(-1 ... 4)))
	}

    @Test func isValidIndexNotClosedValid() async throws {
        #expect(singleElementArray.isValidIndexRange(0 ..< 1))
        #expect(multipleElementArray.isValidIndexRange(0 ..< 5))
	}

    @Test func isValidIndexNotClosedInvalid() async throws {
        #expect(!emptyArray.isValidIndexRange(0 ..< 1))
        #expect(!singleElementArray.isValidIndexRange(0 ..< 2))
        #expect(!multipleElementArray.isValidIndexRange(0 ..< 6))
        #expect(!multipleElementArray.isValidIndexRange(-1 ..< 5))
	}

	// MARK: subscript(safe:)

    @Test func subscriptInvalidIndex() async throws {
        #expect(emptyArray[safe: 0] == nil)
        #expect(singleElementArray[safe: 1] == nil)
        #expect(multipleElementArray[safe: 5] == nil)
        #expect(multipleElementArray[safe: -1] == nil)
	}

    @Test func subscriptValidIndex() async throws {
        #expect(singleElementArray[safe: 0] == .some(1))
        #expect(multipleElementArray[safe: 0] == .some(1))
        #expect(multipleElementArray[safe: 1] == .some(2))
        #expect(multipleElementArray[safe: 2] == .some(3))
        #expect(multipleElementArray[safe: 3] == .some(4))
        #expect(multipleElementArray[safe: 4] == .some(5))
	}
}
