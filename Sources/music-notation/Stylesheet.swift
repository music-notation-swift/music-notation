//
//	Stylesheet.swift
//	music-notation
//
//	Created by Steven Woolgar on 2021-01-30.
//	Copyright © 2021 Steven Woolgar. All rights reserved.
//

public enum MeasurementSystem {
	case metric
	case imperial
}

public enum PageFormats {
	case b5
	case legal
	case a3
	case a4
	case semiLetter
	case b4
	case fifteen
	case executive
	case folio
	case letter
	case c5
	case tabloid
	case userDefined(width: Double, height: Double, measurementSystem: MeasurementSystem)
}

public enum PageOrientation {
	case portrait
	case landscape
}

public enum TuningPosition {
	case onTopOfScore
	case beforeTablature
}

public enum ColumnsLayout {
	case twoColumns
	case horizontally
}

/// Placeholder for eventual staff layout description of a page header.
public struct Stylesheet {
	///	Page & Score format
	/// 	Page related settings
	public var pageFormat: PageFormats
	public var orientation: PageOrientation
	public var topMargin: Int
	public var rightMargin: Int
	public var bottomMargin: Int
	public var leftMargin: Int

	/// 	Size settings
	public var globalScoreProportions: Double	// In millimeters
	public var affectsFontsAndChordSizes: Bool
	public var rhythmProportions: Double

	/// 	Tuning settings
	public var displayTunings: Bool
	public var tuningPosition: TuningPosition
	public var columns: ColumnsLayout

	///	Systems & Staves
	public var firstSystemIndented: Bool
	public var firstSystemIndentedValue: Int	// In millimeters

	///	Header & Footer

	///	Texts & Styles

	///	Notation
	public var hideRhythmInTrblatureWhenUsingStandardNotation: Bool
}
