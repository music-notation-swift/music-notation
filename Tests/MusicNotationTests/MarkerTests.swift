//
//	MarkerTests.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2024-10-17.
//	Copyright © 2024 Steven Woolgar. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class MarkerTests {
	@Test func equalityFalse() async throws {
		let segno = MarkerType.segno
		let varSegno = MarkerType.varSegno
		#expect(segno != varSegno)
	}

	@Test func equalityTrue() async throws {
		let segno1 = MarkerType.segno
		let segno2 = MarkerType.segno
		#expect(segno1 == segno2)
	}

	@Test func convenienceInit() async throws {
		let segnoFromString = try MarkerType.marker(from: "segno")
		#expect(segnoFromString == .segno)

		let varSegnoFromString = try MarkerType.marker(from: "varsegno")
		#expect(varSegnoFromString == .varSegno)

		let codaFromString = try MarkerType.marker(from: "coda")
		#expect(codaFromString == .coda)

		let varCodaFromString = try MarkerType.marker(from: "Var Coda")
		#expect(varCodaFromString == .varCoda)

		let codettaFromString = try MarkerType.marker(from: "Codetta")
		#expect(codettaFromString == .codetta)

		let fineFromString = try MarkerType.marker(from: "Fine")
		#expect(fineFromString == .fine)

		let toCodaFromString = try MarkerType.marker(from: "To Coda")
		#expect(toCodaFromString == .toCoda)

		let toCodaSymbolFromString = try MarkerType.marker(from: "To Coda Symbol")
		#expect(toCodaSymbolFromString == .toCodaSymbol)

		let daCodaFromString = try MarkerType.marker(from: "Da Coda")
		#expect(daCodaFromString == .daCoda)

		let dalDoppiaDelSegnoFromString = try MarkerType.marker(from: "Dal Doppio Segno Al Coda")
		#expect(dalDoppiaDelSegnoFromString == .dalDoppioSegnoAlCoda)

		let daDoppiaFromString = try MarkerType.marker(from: "Da Doppia Coda")
		#expect(daDoppiaFromString == .daDoppiaCoda)

		let userMarkerFromString = try MarkerType.marker(from: "userMarker")
		#expect(userMarkerFromString == .userMarker)

		#expect(throws: MarkerTypeError.self) {
			_ = try MarkerType.marker(from: "badMarkerType")
		}

		#expect(MarkerType.allCases.count == 12)
	}
}
