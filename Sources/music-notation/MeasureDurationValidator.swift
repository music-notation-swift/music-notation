//
//  MeasureDurationValidator.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 8/6/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

#if os(iOS) || os(watchOS) || os(tvOS) || os(OSX)
import Foundation
#else
import Darwin.C
#endif

///
/// This is a collection of static functions that will give information about the completeness of the duration of a
/// `Measure`. A measure must have a certain number of notes according to its `TimeSignature` in order to be valid.
/// `MeasureDurationValidator` provides information as to the validitiy of the measure and any information that can be used
/// in order to be able to modify the measure so that it can be made valid.
///
public enum MeasureDurationValidator {
	///
	/// This represents the state of a measure's duration. It represents whether the `Measure` is full, notFull,
	/// overfilled, or somehow invalid. The fullness is dictated by the time signature and how many notes are in the
	/// measure when it is checked.
	///
	/// - notFull: The measure doesn't have all the notes needed to be full. The `availableNotes` associated value will give a
	///    dictionary of notes that will fit. It gives the smallest number of notes possible to fill.
	/// - full: The measure is complete and cannot hold any more or less notes.
	/// - overfilled: The measure has too many notes to be complete. The `overflowingNotes` associated value will give the range
	/// of notes that would need to be removed for the measure to not be full anymore. Note that if the range of notes
	/// is removed, it could be `full` or `notFull` depending on how large the last note removed was.
	///
	public enum CompletionState: Equatable {
		case notFull(availableNotes: [NoteDuration: Int])
		case full
		case overfilled(overflowingNotes: CountableRange<Int>)
		case invalid

		public static func == (lhs: CompletionState, rhs: CompletionState) -> Bool {
			switch (lhs, rhs) {
			case (.full, .full):
				return true
			case let (.notFull(lhsValue), .notFull(rhsValue)) where lhsValue == rhsValue:
				return true
			case let (.overfilled(lhsValue), .overfilled(rhsValue)) where lhsValue == rhsValue:
				return true
			case (.invalid, .invalid):
				return true
			default:
				return false
			}
		}
	}

	///
	/// For the given measure, returns an array of `CompletionState` for each set in the measure in order.
	///
	/// - parameter measure: The measure for which the `CompletionState` should be calculated.
	/// - returns: The `CompletionState` for each set of notes in the measure in order.
	///
	public static func completionState(of measure: ImmutableMeasure) -> [CompletionState] {
		let baseDuration: NoteDuration
		do {
			baseDuration = try baseNoteDuration(from: measure)
		} catch {
			return [.invalid]
		}
		let fullMeasureTicksBudget = Double(measure.timeSignature.topNumber) * baseDuration.ticks

		// Validate each set separately
		return measure.notes.enumerated().map { setIndex, noteCollection in
			var overFilledStartIndex: Int?
			let filledTicks = noteCollection.enumerated().reduce(0.0) { prev, indexAndCollection in
				let (index, currentCollection) = indexAndCollection
				let newTicks = prev + currentCollection.ticks
				if newTicks > fullMeasureTicksBudget, overFilledStartIndex == nil {
					overFilledStartIndex = index
				}
				return newTicks
			}
			if filledTicks == fullMeasureTicksBudget {
				return .full
			} else if let overFilledStartIndex = overFilledStartIndex {
				return .overfilled(overflowingNotes: CountableRange(uncheckedBounds: (overFilledStartIndex,
																					  measure.noteCount[setIndex])))
			} else if filledTicks < fullMeasureTicksBudget {
				return .notFull(availableNotes: availableNotes(within: fullMeasureTicksBudget - filledTicks))
			} else {
				return .invalid
			}
		}
	}

	///
	/// Returns the number of a certain `NoteDuration` that will fit in a measure in the specified note set.
	///
	/// - parameter noteDuration: The note duration to check
	/// - parameter measure: The measure to check
	/// - parameter setIndex: The index of the note set to check. Default is 0.
	/// - returns: The number of the specified duration that will fit in the measure within the specificed note set.
	///
	public static func number(of noteDuration: NoteDuration, fittingIn measure: ImmutableMeasure, inSet setIndex: Int = 0) -> Int {
		let baseDuration: NoteDuration
		do {
			baseDuration = try baseNoteDuration(from: measure)
		} catch {
			// TODO: Write TimeSignature validation, so this isn't possible
			return 0
		}
		let fullMeasureTicksBudget = Double(measure.timeSignature.topNumber) * baseDuration.ticks
		let alreadyFilledTicks = measure.notes[setIndex].reduce(0.0) { prev, currentCollection in
			prev + currentCollection.ticks
		}
		let availableTicks = fullMeasureTicksBudget - alreadyFilledTicks
		guard availableTicks > 0 else {
			return 0
		}
		return Int(availableTicks / noteDuration.ticks)
	}

	///
	/// Calculates the `NoteDuration` that is associated with the bottom number of a `TimeSignature`.
	/// This handles irrational time signatures.
	///
	/// - parameter measure: The measure for which the base duration should be derived.
	/// - returns: The duration that is equivalent to the bottom number of the time signature associated with the specified
	///    measure.
	/// - throws:
	///    - MeasureDurationValidatorError.invalidBottomNumber
	///
	internal static func baseNoteDuration(from measure: ImmutableMeasure) throws -> NoteDuration {
		let bottomNumber = measure.timeSignature.bottomNumber

		// TODO: Replace `pow`, `floor`, and `log`
		// https://github.com/drumnkyle/music-notation-core/issues/146
		let rationalizedBottomNumber = Int(pow(2, floor(log(Double(bottomNumber)) / log(2))))

		// TODO: (Kyle) We should validate in TimeSignature to make sure the number
		// isn't too large. Then I guess we can make this a force unwrap, because the math above
		// means it will always be a power of 2 and NoteDuration is always power of 2.
		if let timeSignatureValue = NoteDuration.TimeSignatureValue(rawValue: rationalizedBottomNumber) {
			return NoteDuration(timeSignatureValue: timeSignatureValue)
		} else {
			throw MeasureDurationValidatorError.invalidBottomNumber
		}
	}

	private static func availableNotes(within ticks: Double) -> [NoteDuration: Int] {
		var ticksLeft = ticks
		var availableNotes: [NoteDuration: Int] = [:]
		while ticksLeft != 0 {
			let duration = findLargestDuration(lessThan: ticksLeft)
			let noteCount = Int(ticksLeft / duration.ticks)
			availableNotes[duration] = noteCount
			ticksLeft -= Double(noteCount) * duration.ticks
		}
		return availableNotes
	}

	// TODO: Refactor - move allDurations and function findLargest(start:, end:) -> NoteDuration out of this function
	// https://github.com/drumnkyle/music-notation-core/issues/141
	private static func findLargestDuration(lessThan ticks: Double) -> NoteDuration {
		let allDurations: [NoteDuration] = [.large, .long, .doubleWhole, .whole, .half, .quarter, .eighth, .sixteenth,
											.thirtySecond, .sixtyFourth, .oneTwentyEighth, .twoFiftySixth]
		let allTicks = allDurations.map { $0.ticks }
		func findLargest(start: Int, end: Int) -> NoteDuration {
			guard end - start > 1 else { return allDurations[end] }

			let mid = (start + end) / 2
			if allTicks[mid] < ticks {
				return findLargest(start: start, end: mid)
			} else if allTicks[mid] > ticks {
				return findLargest(start: mid, end: end)
			} else {
				return allDurations[mid]
			}
		}
		return findLargest(start: 0, end: allTicks.count - 1)
	}
}

public enum MeasureDurationValidatorError: Error {
	case invalidBottomNumber
	case internalError
}
