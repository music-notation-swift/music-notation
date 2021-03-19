//
//  Score.swift
//  MusicNotationCore
//
//  Created by Steven Woolgar on 2021-01-30.
//  Copyright © 2021 Steven Woolgar. All rights reserved.
//

/// A `score` can contain 0 or more staves. Each staff can have a name, color, and position within the score.
/// A `score` will also be the container for stylesheets.
public struct Score: RandomAccessCollection {
	// MARK: - Collection Conformance

	public typealias Index = Int
	public var startIndex: Int								{ stavesHolders.startIndex }
	public var endIndex: Int								{ stavesHolders.endIndex }
	public subscript(position: Index) -> Iterator.Element	{ stavesHolders[position] }
	public func index(after i: Int) -> Int					{ stavesHolders.index(after: i) }
	public func index(before i: Int) -> Int 				{ stavesHolders.index(before: i) }
	public typealias Iterator = IndexingIterator<[StavesHolder]>
	public func makeIterator() -> Iterator 					{ stavesHolders.makeIterator() }

	// MARK: - Main Properties

	internal private(set) var stavesHolders: [StavesHolder] = []
}

extension Score: CustomDebugStringConvertible {
	public var debugDescription: String {
		let stavesDescription = stavesHolders.map { $0.debugDescription }.joined(separator: ", ")

		return "staves(\(stavesDescription))"
	}
}
