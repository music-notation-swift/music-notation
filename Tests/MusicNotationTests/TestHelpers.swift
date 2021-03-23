//
//  TestHelpers.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 7/12/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

import XCTest

extension XCTestCase {
	func assertThrowsError<T: Error>(_ expectedError: T,
									 inFile file: String = #file, atLine line: UInt = #line,
									 expression: () throws -> Void) where T: Equatable {
		let location = XCTSourceCodeLocation(filePath: file, lineNumber: Int(line))
		let context = XCTSourceCodeContext(location: location)

		do {
			try expression()

			let issue = XCTIssue(type: .assertionFailure,
								 compactDescription: "Expected error \(expectedError), but got no error.",
								 detailedDescription: nil,
								 sourceCodeContext: context,
								 associatedError: nil,
								 attachments: [])
			record(issue)
		} catch {
			if error as? T != expectedError {
				let issue = XCTIssue(type: .assertionFailure,
									 compactDescription: "Expected error \(expectedError), but got: \(error).",
									 detailedDescription: nil,
									 sourceCodeContext: context,
									 associatedError: nil,
									 attachments: [])
				record(issue)
			}
		}
	}

	func assertNoErrorThrown(inFile file: String = #file, atLine line: UInt = #line, expression: () throws -> Void) {
		do {
			try expression()
		} catch {
			let location = XCTSourceCodeLocation(filePath: file, lineNumber: Int(line))
			let context = XCTSourceCodeContext(location: location)
			let issue = XCTIssue(type: .assertionFailure,
								 compactDescription: "Expected no error, but got: \(error)",
								 detailedDescription: nil,
								 sourceCodeContext: context,
								 associatedError: nil,
								 attachments: [])
			record(issue)
		}
	}
}
