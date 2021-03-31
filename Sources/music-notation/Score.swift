//
//	Score.swift
//	music-notation
//
//	Created by Steven Woolgar on 2021-01-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

/// A `score` can contain 0 or more parts. Each part can have a name, color, and position within the score.
/// A `score` will also be the container for stylesheets, as well as overall data for the entire score.
public struct Score: RandomAccessCollection {
	// MARK: - Collection Conformance

	public typealias Index = Int
	public var startIndex: Int								{ parts.startIndex }
	public var endIndex: Int								{ parts.endIndex }
	public subscript(position: Index) -> Iterator.Element	{ parts[position] }
	public func index(after index: Int) -> Int				{ parts.index(after: index) }
	public func index(before index: Int) -> Int 			{ parts.index(before: index) }
	public typealias Iterator = IndexingIterator<[Part]>
	public func makeIterator() -> Iterator 					{ parts.makeIterator() }

	// MARK: - Main Properties

	internal private(set) var parts: [Part] = []
	public var title: String = ""
	public var subTitle: String = ""
	public var artist: String = ""
	public var album: String = ""
	public var words: String = ""
	public var music: String = ""
	public var wordsAndMusic: String = ""
	public var transcriber: String = ""
	public var instructions: String = ""
	public var notices: String = ""

	public var firstPageHeader: PageHeader?
	public var pageHeader: PageHeader?
	public var pageFooter: PageFooter?

	public init(parts: [Part]) {
		self.parts = parts
	}
}

extension Score: CustomDebugStringConvertible {
	public var debugDescription: String {
		let partsDescription = parts.map { $0.debugDescription }.joined(separator: ", ")

		return "parts(\(partsDescription))"
	}
}
