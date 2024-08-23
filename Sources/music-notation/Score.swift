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
/// A `score` will also be the container for stylesheets, as well as overall data for the
/// entire score.
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
		notices: String = ""
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
	}

	/// Adds a new `part` element at the end of the `parts` array.
	///
	/// Use this method to append a single element to the end of a mutable array.
	///
	public mutating func appendPart(_ newPart: Part) {
		parts.append(newPart)
	}

	/// Adds the elements of a sequence to the end of the `parts` array.
	///
	/// Use this method to append the elements of a `Part` sequence to the end of the
	/// `parts` array.
	///
	/// - Parameter newParts: The `parts` to append to the `parts` array.
	///
	public mutating func append(contentsOf newParts: [Part]) {
		parts.append(contentsOf: newParts)
	}

	/// Inserts a `part` at the given index.
	///
	/// - parameter part: The part to be inserted.
	/// - parameter index: The index where the part should be inserted.
	/// - throws:
	///	   - `ScoreError.partIndexOutOfRange`
	///	   - `ScoreError.internalError`
	///
	public mutating func insertPart(_ part: Part, at index: Int) throws {
		parts.insert(part, at: index)
	}

	/// Removes and returns the `Part` at the specified position.
	///
	/// All the elements following the specified position are moved up to
	/// close the gap.
	///
	/// - Parameter index: The position of the `part` element to remove. `index` must
	///   be a valid index of the array.
	/// - Returns: The `part` element at the specified index.
	///
	@discardableResult
	public mutating func remove(at index: Int) -> Part {
		parts.remove(at: index)
	}
}

extension Score: CustomDebugStringConvertible {
	public var debugDescription: String {
		let partsDescription = parts.map { $0.debugDescription }.joined(separator: ", ")

		return "parts(\(partsDescription))"
	}
}
