//
//	Part.swift
//	music-notation
//
//	Created by Steven Woolgar on 2021-01-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

public struct Part {
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
	
	public let instrument: Instrument?

	internal private(set) var staves: [Staff] = []
	
	public init(
		instrument: Instrument? = nil,
		staves: [Staff] = []
	) {
		self.instrument = instrument
		self.staves = staves
	}
	
	/// Adds a new `staff` element at the end of the `staves` array.
	///
	/// Use this method to append a single element to the end of a mutable array.
	///
	public mutating func appendStaff(_ newStaff: Staff) {
		staves.append(newStaff)
	}
	
	/// Adds the elements of a sequence to the end of the `newStaves` array.
	///
	/// Use this method to append the elements of a `Staff` sequence to the end of the
	/// `newStaves` array.
	///
	/// - Parameter contentsOf: The `newStaves` to append to the `newStaves` array.
	///
	public mutating func append(contentsOf newStaves: [Staff]) {
		staves.append(contentsOf: newStaves)
	}
	
	/// Inserts a `Staff` at the given index.
	///
	/// - parameter staff: The `Staff` to be inserted.
	/// - parameter index: The index where the `Staff` should be inserted.
	/// - throws:
	///	   - `PartError.StaffIndexOutOfRange`
	///	   - `PartError.internalError`
	///
	public mutating func insertStaff(_ staff: Staff, at index: Int) throws {
		guard index >= 0, index < staves.count else { throw PartError.staffIndexOutOfRange }
		staves.insert(staff, at: index)
	}
	
	/// Removes and returns the `Staff` at the specified position.
	///
	/// All the elements following the specified position are moved up to
	/// close the gap.
	///
	/// - Parameter index: The position of the `Staff` element to remove. `index` must
	///   be a valid index of the array.
	/// - Returns: The `Staff` element at the specified index.
	///
	@discardableResult
	public mutating func remove(at index: Int) throws -> Staff {
		guard staves.count != 0 else { throw PartError.removeOutOfRange }
		return staves.remove(at: index)
	}
}

extension Part: CustomDebugStringConvertible {
	public var debugDescription: String {
		let stavesDescription = staves.map { $0.debugDescription }.joined(separator: ", ")
		
		return "staves(\(stavesDescription))"
	}
}

public enum PartError: Error {
	case removeOutOfRange
	case staffIndexOutOfRange
	case badInstrument
}
