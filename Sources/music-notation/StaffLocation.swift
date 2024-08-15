//
//	StaffLocation.swift
//	music-notation
//
//	Created by Kyle Sherman on 2016-10-30.
//	Copyright © 2016 Kyle Sherman. All rights reserved.
//

/// Represents a 0-based location on the staff where 0 is the first line/space from the bottom.
/// Negative numbers represents ledger lines/spaces below the first line/space of the staff.
///
public struct StaffLocation: Sendable {
    public enum LocationType: Sendable {
		case line
		case space
	}

	public let locationType: LocationType

    /// 0-based location on the staff where 0 is the first line/space from the bottom.
	/// Negative numbers represent ledger lines/spaces below the first one.
	///
	public let number: Int

    /// Starts from 0 on the first line (from the bottom). Ledger lines below that are negative.
	/// Each increase by 1 moves a half step. i.e. 1 is the first space on the staff.
	///
	internal var halfSteps: Int {
		switch locationType {
		case .space:
			return number * 2 + 1
		case .line:
			return number * 2
		}
	}

	public init(_ type: LocationType, _ number: Int) {
		locationType = type
		self.number = number
	}
}
