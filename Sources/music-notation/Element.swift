//
//	Element.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2024-08-30.
//	Copyright © 2024 Steven Woolgar. All rights reserved.
//

public protocol Element: Equatable {
	var type: any Element.Type { get };

	var parent: (any Element)? { get set };
	var next: (any Element)? { get set };
	var prev: (any Element)? { get set };
}
