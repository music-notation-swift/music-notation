//
//  SwiftHelpersTests.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 10/30/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import MusicNotationCoreMac
import XCTest

class SwiftHelpersTests: XCTestCase {
	var emptyArray: [Int]!
	var singleElementArray: [Int]!
	var multipleElementArray: [Int]!

	override func setUp() {
		super.setUp()
		emptyArray = []
		singleElementArray = [1]
		multipleElementArray = [1, 2, 3, 4, 5]
	}

	override func tearDown() {
		super.tearDown()
		emptyArray = nil
		singleElementArray = nil
		multipleElementArray = nil
	}

	// MARK: - Collection

	// MARK: lastIndex

	func testLastIndex1Item() {
		XCTAssertEqual(singleElementArray.lastIndex, 0)
	}

	func testLastIndexEmpty() {
		XCTAssertEqual(emptyArray.lastIndex, 0)
	}

	func testLastIndexManyItems() {
		XCTAssertEqual(multipleElementArray.lastIndex, 4)
	}

	// MARK: isValidIndex()

	func testIsValidIndexInvalid() {
		XCTAssertFalse(emptyArray.isValidIndex(0))
		XCTAssertFalse(emptyArray.isValidIndex(1))
		XCTAssertFalse(singleElementArray.isValidIndex(1))
		XCTAssertFalse(singleElementArray.isValidIndex(-1))
		XCTAssertFalse(multipleElementArray.isValidIndex(7))
	}

	func testIsValidIndexValid() {
		XCTAssertTrue(singleElementArray.isValidIndex(0))
		XCTAssertTrue(multipleElementArray.isValidIndex(0))
		XCTAssertTrue(multipleElementArray.isValidIndex(1))
		XCTAssertTrue(multipleElementArray.isValidIndex(2))
		XCTAssertTrue(multipleElementArray.isValidIndex(3))
		XCTAssertTrue(multipleElementArray.isValidIndex(4))
	}

	// MARK: isValidIndexRange()

	func testIsValidIndexClosedValid() {
		XCTAssertTrue(singleElementArray.isValidIndexRange(Range(0 ... 0)))
		XCTAssertTrue(multipleElementArray.isValidIndexRange(Range(0 ... 4)))
	}

	func testIsValidIndexClosedInvalid() {
		XCTAssertFalse(emptyArray.isValidIndexRange(Range(0 ... 0)))
		XCTAssertFalse(singleElementArray.isValidIndexRange(Range(0 ... 1)))
		XCTAssertFalse(multipleElementArray.isValidIndexRange(Range(0 ... 5)))
		XCTAssertFalse(multipleElementArray.isValidIndexRange(Range(-1 ... 4)))
	}

	func testIsValidIndexNotClosedValid() {
		XCTAssertTrue(singleElementArray.isValidIndexRange(0 ..< 1))
		XCTAssertTrue(multipleElementArray.isValidIndexRange(0 ..< 5))
	}

	func testIsValidIndexNotClosedInvalid() {
		XCTAssertFalse(emptyArray.isValidIndexRange(0 ..< 1))
		XCTAssertFalse(singleElementArray.isValidIndexRange(0 ..< 2))
		XCTAssertFalse(multipleElementArray.isValidIndexRange(0 ..< 6))
		XCTAssertFalse(multipleElementArray.isValidIndexRange(-1 ..< 5))
	}

	// MARK: subscript(safe:)

	func testSubscriptInvalidIndex() {
		XCTAssertNil(emptyArray[safe: 0])
		XCTAssertNil(singleElementArray[safe: 1])
		XCTAssertNil(multipleElementArray[safe: 5])
		XCTAssertNil(multipleElementArray[safe: -1])
	}

	func testSubscriptValidIndex() {
		XCTAssertEqual(singleElementArray[safe: 0], .some(1))
		XCTAssertEqual(multipleElementArray[safe: 0], .some(1))
		XCTAssertEqual(multipleElementArray[safe: 1], .some(2))
		XCTAssertEqual(multipleElementArray[safe: 2], .some(3))
		XCTAssertEqual(multipleElementArray[safe: 3], .some(4))
		XCTAssertEqual(multipleElementArray[safe: 4], .some(5))
	}
}
