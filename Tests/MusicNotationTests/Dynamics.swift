//
//	DynamicsTests.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2024-10-17.
//	Copyright © 2024 Steven Woolgar. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class DynamicsTests {
	@Test func equalityFalse() async throws {
		let ppp = Dynamics.ppp
		let pp = Dynamics.pp
		#expect(ppp != pp)
	}

	@Test func equalityTrue() async throws {
		let ppp1 = Dynamics.ppp
		let ppp2 = Dynamics.ppp
		#expect(ppp1 == ppp2)
	}

	@Test func name() async throws {
		let ppp = Dynamics.ppp
		let pppString = ppp.name()
		#expect(pppString == "pianississimo")

		let pp = Dynamics.pp
		let ppString = pp.name()
		#expect(ppString == "pianissimo")

		let p = Dynamics.p
		let pString = p.name()
		#expect(pString == "piano")

		let mp = Dynamics.mp
		let mpString = mp.name()
		#expect(mpString == "mezzo-piano")

		let mf = Dynamics.mf
		let mfString = mf.name()
		#expect(mfString == "mezzo-forte")

		let f = Dynamics.f
		let fString = f.name()
		#expect(fString == "forte")

		let ff = Dynamics.ff
		let ffString = ff.name()
		#expect(ffString == "fortissimo")

		let fff = Dynamics.fff
		let fffString = fff.name()
		#expect(fffString == "fortississimo")

		#expect(Dynamics.allCases.count == 8)
	}

	@Test func level() async throws {
		let ppp = Dynamics.ppp
		let pppString = ppp.level()
		#expect(pppString == "very very quiet")

		let pp = Dynamics.pp
		let ppString = pp.level()
		#expect(ppString == "very quiet")

		let p = Dynamics.p
		let pString = p.level()
		#expect(pString == "quiet")

		let mp = Dynamics.mp
		let mpString = mp.level()
		#expect(mpString == "moderately quiet")

		let mf = Dynamics.mf
		let mfString = mf.level()
		#expect(mfString == "moderately loud")

		let f = Dynamics.f
		let fString = f.level()
		#expect(fString == "loud")

		let ff = Dynamics.ff
		let ffString = ff.level()
		#expect(ffString == "very loud")

		let fff = Dynamics.fff
		let fffString = fff.level()
		#expect(fffString == "very very loud")
	}
}
