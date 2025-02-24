//
//	Part.swift
//	music-notation
//
//	Created by Steven Woolgar on 2021-01-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

public struct Part {
	// MARK: - Main Properties

	public let instrument: Instrument?
	internal private(set) var staves: [Staff] = []

	public init(
		instrument: Instrument? = nil,
		staves: [Staff] = []
	) {
		self.instrument = instrument
		self.staves = staves
	}
}

// MARK: - Collection Conformance

extension Part: RandomAccessCollection {
	public typealias Index = Int
	public var startIndex: Int								{ staves.startIndex }
	public var endIndex: Int								{ staves.endIndex }

	public func index(after index: Int) -> Index			{ staves.index(after: index) }
	public typealias Iterator = IndexingIterator<[Staff]>
	public func makeIterator() -> Iterator 					{ staves.makeIterator() }
}

// MARK: - BidirectionalCollection Conformance

extension Part: BidirectionalCollection {
	public func index(before index: Int) -> Index 			{ staves.index(before: index) }
}

// MARK: - RangeReplaceableCollection Conformance

extension Part: RangeReplaceableCollection {
	public init() {
		self.init(instrument: nil)
	}

	mutating public func replaceSubrange<C>(
		_ subrange: Range<Self.Index>,
		with newElements: C) where C : Collection, Self.Element == C.Element {
			staves.replaceSubrange(subrange.relative(to: staves), with: newElements)
	}
}

// MARK: - MutableCollection Conformance

extension Part: MutableCollection {
	public subscript(position: Int) -> Iterator.Element {
		get { staves[position] }
		set(newValue) { staves[position] = newValue }
	}
}

extension Part: CustomDebugStringConvertible {
	public var debugDescription: String {
		let stavesDescription = staves.map { $0.debugDescription }.joined(separator: "\n")
		let instrumentName = if let name = instrument?.name {
			"instrument `\(name)`"
		} else {
			""
		}

		return "Part(\(instrumentName)), staves(\(stavesDescription))"
	}
}

public enum PartError: Error {
	case removeOutOfRange
	case staffIndexOutOfRange
	case badInstrument
}
