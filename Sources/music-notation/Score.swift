//
//	Score.swift
//	music-notation
//
//	Created by Steven Woolgar on 2021-01-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

/// A `score` can contain 0 or more parts. Each part can have a name, color, and position
/// within the score.
///
/// `score` is also full collection of parts. See the extensions for the comformances.
///
/// A `score` will also be the container for stylesheets, as well as overall data for the
/// entire score.
public struct Score {
	// MARK: - Main Properties

	// This should be part of the io portion of the library.
	// Note: This should be tied to the swift package, but I don't know of a way to push this into here.
	public var version = Version(major: 0, minor: 3, revision: 0)

	internal private(set) var parts: [Part] = []

	public var title: String = ""
	public var subtitle: String = ""
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

	// Holds information global to all parts of the score (for instance the sections)
	public var masterPart: Part?

	public init(
		parts: [Part] = [],
		title: String = "",
		subtitle: String = "",
		artist: String = "",
		album: String = "",
		words: String = "",
		music: String = "",
		wordsAndMusic: String = "",
		transcriber: String = "",
		instructions: String = "",
		notices: String = "",
		firstPageHeader: PageHeader? = nil,
		pageHeader: PageHeader? = nil,
		pageFooter: PageFooter? = nil,
		masterPart: Part? = nil
	) {
		self.parts = parts
		self.title = title
		self.subtitle = subtitle
		self.artist = artist
		self.album = album
		self.words = words
		self.music = music
		self.wordsAndMusic = wordsAndMusic
		self.transcriber = transcriber
		self.instructions = instructions
		self.notices = notices
		self.firstPageHeader = firstPageHeader
		self.pageHeader = pageHeader
		self.pageFooter = pageFooter
		self.masterPart = masterPart
	}
}

// MARK: - RandomAccessCollection Conformance

extension Score: RandomAccessCollection {
	public typealias Index = Int
	public var startIndex: Int								{ parts.startIndex }
	public var endIndex: Int								{ parts.endIndex }
	public func index(after index: Int) -> Int				{ parts.index(after: index) }
	public typealias Iterator = IndexingIterator<[Part]>
	public func makeIterator() -> Iterator 					{ parts.makeIterator() }
}

// MARK: - BidirectionalCollection Conformance

extension Score: BidirectionalCollection {
	public func index(before index: Int) -> Int 			{ parts.index(before: index) }
}

// MARK: - RangeReplaceableCollection Conformance

extension Score: RangeReplaceableCollection {
	public init() {
		self.init(parts: [])
	}

	mutating public func replaceSubrange<C>(
		_ subrange: Range<Self.Index>,
		with newElements: C) where C : Collection, Self.Element == C.Element {
			parts.replaceSubrange(subrange.relative(to: parts), with: newElements)
	}
}

// MARK: - MutableCollection Conformance

extension Score: MutableCollection {
	public subscript(position: Int) -> Part {
		get { parts[position] }
		set(newValue) { parts[position] = newValue }
	}
}

// MARK: - CustomDebugStringConvertible Conformance

extension Score: CustomDebugStringConvertible {
	public var debugDescription: String {
		"Score version: \(version.major).\(version.minor).\(version.revision), parts(\(parts.map { $0.debugDescription }.joined(separator: ", ")))"
	}
}
