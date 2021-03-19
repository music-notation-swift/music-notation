//
//  NotesHolder.swift
//  MusicNotationCore
//
//  Created by Kyle Sherman on 6/15/15.
//  Copyright © 2015 Kyle Sherman. All rights reserved.
//

///
/// This is a protocol that represents anything that can directly hold multiple notes.
/// i.e. `Measure` and `MeasureRepeat` both conform to this.
///
public protocol NotesHolder: CustomDebugStringConvertible {
	var measureCount: Int { get }
}
