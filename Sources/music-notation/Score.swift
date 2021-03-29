//
//	Score.swift
//	MusicNotationCore
//
//	Created by Steven Woolgar on 2021-01-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

/// A `score` can contain 0 or more staves. Each staff can have a name, color, and position within the score.
/// A `score` will also be the container for stylesheets.
public struct Score: RandomAccessCollection {
	// MARK: - Collection Conformance

	public typealias Index = Int
	public var startIndex: Int								{ staves.startIndex }
	public var endIndex: Int								{ staves.endIndex }
	public subscript(position: Index) -> Iterator.Element	{ staves[position] }
	public func index(after index: Int) -> Int				{ staves.index(after: index) }
	public func index(before index: Int) -> Int 			{ staves.index(before: index) }
	public typealias Iterator = IndexingIterator<[Staff]>
	public func makeIterator() -> Iterator 					{ staves.makeIterator() }

	// MARK: - Main Properties

	internal private(set) var staves: [Staff] = []

	public init(staves: [Staff]) {
		self.staves = staves
	}
}

extension Score: CustomDebugStringConvertible {
	public var debugDescription: String {
		let stavesDescription = staves.map { $0.debugDescription }.joined(separator: ", ")

		return "staves(\(stavesDescription))"
	}
}
