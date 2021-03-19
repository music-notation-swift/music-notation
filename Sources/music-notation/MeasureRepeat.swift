//
//  MeasureRepeat.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

/// This represents a set of one or more measures that is repeated `repeatCount` times.
public struct MeasureRepeat {
	public var repeatCount: Int {
		didSet {
			recalculateMeasureCount()
		}
	}

	public var measures: [Measure] {
		didSet {
			recalculateMeasureCount()
		}
	}

	/// The number of measures, including repeated measures
	public private(set) var measureCount: Int

	public init(measures: [Measure], repeatCount: Int = 1) throws {
		guard measures.count > 0 else { throw MeasureRepeatError.noMeasures }
		guard repeatCount > 0 else { throw MeasureRepeatError.invalidRepeatCount }
		self.measures = measures
		self.repeatCount = repeatCount
		measureCount = MeasureRepeat.measureCount(forMeasures: measures, repeatCount: repeatCount)
	}

	///
	/// Inserts a measure into the repeat. The index can only be within the count of original measures or
	/// equal to the count. If it is equal to the count, the measure will be added to the end of the
	/// measures to be repeated.
	///
	/// - parameter measure: The measure to be inserted.
	/// - parameter index: The index at which to insert the measure within the measures to be repeated.
	/// - throws:
	///    - `MeasureRepeatError.indexOutOfRange`
	///    - `MeasureRepeatError.cannotModifyRepeatedMeasures`
	///
	public mutating func insertMeasure(_ measure: Measure, at index: Int) throws {
		guard index >= 0 else { throw MeasureRepeatError.indexOutOfRange }
		guard index <= measures.count else { throw MeasureRepeatError.cannotModifyRepeatedMeasures }
		measures.insert(measure, at: index)
	}

	internal func expand() -> [ImmutableMeasure] {
		let repeatedMeasuresHolders = measures.map {
			RepeatedMeasure(immutableMeasure: $0) as ImmutableMeasure
		}
		let measuresHolders = measures.map { $0 as ImmutableMeasure }
		var allMeasures: [ImmutableMeasure] = measuresHolders
		for _ in 0 ..< repeatCount {
			allMeasures += repeatedMeasuresHolders
		}
		return allMeasures
	}

	private mutating func recalculateMeasureCount() {
		measureCount = MeasureRepeat.measureCount(forMeasures: measures, repeatCount: repeatCount)
	}

	private static func measureCount(forMeasures measures: [Measure], repeatCount: Int) -> Int {
		measures.count + repeatCount * measures.count
	}
}

extension MeasureRepeat: CustomDebugStringConvertible {
	public var debugDescription: String {
		let measuresDescription = measures.map { $0.debugDescription }.joined(separator: ", ")

		return "[ \(measuresDescription) ] × \(repeatCount + 1)"
	}
}

extension MeasureRepeat: NotesHolder {}

extension MeasureRepeat: Equatable {
	public static func == (lhs: MeasureRepeat, rhs: MeasureRepeat) -> Bool {
		guard lhs.repeatCount == rhs.repeatCount else {
			return false
		}
		guard lhs.measures == rhs.measures else {
			return false
		}
		return true
	}
}

public enum MeasureRepeatError: Error {
	case noMeasures
	case invalidRepeatCount
	case cannotModifyRepeatedMeasures
	case indexOutOfRange
}
