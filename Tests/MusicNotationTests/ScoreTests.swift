//
//	ScoreTests.swift
//	MusicNotation
//
//	Created by Steven Woolgar on 2024-08-23.
//	Copyright © 2024 Steven Woolgar. All rights reserved.
//

@testable import MusicNotation
import Testing

@Suite final class ScoreTests {
	enum Constant {
		static let standardClef: Clef = .treble
	}

	var score: Score!
	var staff: Staff!

	var measure1: Measure!
	var measure2: Measure!
	var measure3: Measure!
	var measure4: Measure!
	var measure5: Measure!
	var measure6: Measure!
	var measure7: Measure!
	var measure8: Measure!
	var repeat1: MeasureRepeat!
	var repeat2: MeasureRepeat!

	init() {
		staff = Staff(clef: Constant.standardClef)
		let timeSignature = TimeSignature(numerator: 4, denominator: 4, tempo: 120)
		let key = Key(noteLetter: .c)
		let note = Note(.sixteenth, pitch: SpelledPitch(.c, .octave1))
		let note2 = Note(.sixteenth, pitch: SpelledPitch(.a, .octave1))
		let tuplet = try! Tuplet(3, .sixteenth, notes: [note, note, note])
		let tuplet2 = try! Tuplet(3, .sixteenth, notes: [note2, note, note])

		measure1 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[note, note, note, note, tuplet]]
		)
		measure2 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[tuplet, note, note]]
		)
		measure3 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[note, note, note, note, tuplet]]
		)
		measure4 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[note, note, note, note]]
		)
		measure5 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[tuplet, note, note, note, note]]
		)
		measure6 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[tuplet, tuplet, note, note]]
		)
		measure7 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[note2, tuplet, tuplet, note]]
		)
		measure8 = Measure(
			timeSignature: timeSignature,
			key: key,
			notes: [[tuplet2, note, note]]
		)
		repeat1 = try! MeasureRepeat(measures: [measure4])
		repeat2 = try! MeasureRepeat(measures: [measure4, measure4], repeatCount: 2)
		staff.appendMeasure(measure1)
		staff.appendMeasure(measure2)
		staff.appendMeasure(measure3)
		staff.appendMeasure(measure4)
		staff.appendMeasure(measure5)
		staff.appendRepeat(repeat1) // index = 5
		staff.appendRepeat(repeat2) // index = 7
		staff.appendMeasure(measure6) // index = 13
		staff.appendMeasure(measure3)
		staff.appendMeasure(measure7)
		staff.appendMeasure(measure8)

		let instrument1 = Instrument(name: "instrument 1")
		let instrument2 = Instrument(name: "instrument 2")
		let instrument3 = Instrument(name: "instrument 3")
		let instrument4 = Instrument(name: "instrument 4")

		let part1 = Part(instrument: instrument1, staves: [staff])
		let part2 = Part(instrument: instrument2)
		let part3 = Part(instrument: instrument3)
		let part4 = Part(instrument: instrument4)

		score = Score(parts: [part1, part2, part3, part4])
	}

	deinit {
		score = nil
		staff = nil
		measure1 = nil
		measure2 = nil
		measure3 = nil
		measure4 = nil
		measure5 = nil
		measure6 = nil
		measure7 = nil
		measure8 = nil
		repeat1 = nil
		repeat2 = nil
	}

	// swiftlint:disable line_length
	@Test func debugDescription() async throws {
		#expect(staff!.debugDescription == "staff(treble |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1, 1/16c1, 1/16c1]|, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 2, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 3, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16a1, 3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1]|, |4/4: [3[1/16a1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|)")
	}

	@Test func titleSetPostInit() async throws {
		score.title = "Xanadu"
		#expect(score.title == "Xanadu")
	}

	@Test func titleSetDuringInit() async throws {
		let titleScore = Score(title: "Xanadu")
		#expect(titleScore.title == "Xanadu")
	}

	@Test func subtitleSetPostInit() async throws {
		score.subtitle = "subtitle"
		#expect(score.subtitle == "subtitle")
	}

	@Test func subtitleSetDuringInit() async throws {
		let subtitleScore = Score(subtitle: "subtitle")
		#expect(subtitleScore.subtitle == "subtitle")
	}

	@Test func titlesSetPostInit() async throws {
		score.title = "Xanadu"
		score.subtitle = "subtitle"
		#expect(score.title == "Xanadu")
		#expect(score.subtitle == "subtitle")
	}

	@Test func titlesSetDuringInit() async throws {
		let subtitleScore = Score(title: "Xanadu", subtitle: "subtitle")
		#expect(subtitleScore.title == "Xanadu")
		#expect(subtitleScore.subtitle == "subtitle")
	}

	@Test func artistSetPostInit() async throws {
		score.artist = "Rush"
		#expect(score.artist == "Rush")
	}

	@Test func artistSetDuringInit() async throws {
		let artistScore = Score(artist: "Rush")
		#expect(artistScore.artist == "Rush")
	}

	@Test func albumSetPostInit() async throws {
		score.album = "Farewell To Kings"
		#expect(score.album == "Farewell To Kings")
	}

	@Test func albumSetDuringInit() async throws {
		let albumScore = Score(album: "Farewell To Kings")
		#expect(albumScore.album == "Farewell To Kings")
	}

	@Test func wordsSetPostInit() async throws {
		score.words = "Neil Peart"
		#expect(score.words == "Neil Peart")
	}

	@Test func wordsSetDuringInit() async throws {
		let wordsScore = Score(words: "Neil Peart")
		#expect(wordsScore.words == "Neil Peart")
	}

	@Test func musicSetPostInit() async throws {
		score.music = "Alex Lifeson, Geddy Lee"
		#expect(score.music == "Alex Lifeson, Geddy Lee")
	}

	@Test func musicSetDuringInit() async throws {
		let musicScore = Score(music: "Alex Lifeson, Geddy Lee")
		#expect(musicScore.music == "Alex Lifeson, Geddy Lee")
	}

	@Test func wordsAndMusicSetPostInit() async throws {
		score.wordsAndMusic = "wordsAndMusic"
		#expect(score.wordsAndMusic == "wordsAndMusic")
	}

	@Test func wordsAndMusicSetDuringInit() async throws {
		let wordsAndMusicScore = Score(wordsAndMusic: "wordsAndMusic")
		#expect(wordsAndMusicScore.wordsAndMusic == "wordsAndMusic")
	}

	@Test func transcriberSetPostInit() async throws {
		score.transcriber = "transcriber"
		#expect(score.transcriber == "transcriber")
	}

	@Test func transcriberSetDuringInit() async throws {
		let transcriberScore = Score(transcriber: "transcriber")
		#expect(transcriberScore.transcriber == "transcriber")
	}

	@Test func instructionsSetPostInit() async throws {
		score.instructions = "instructions"
		#expect(score.instructions == "instructions")
	}

	@Test func instructionsSetDuringInit() async throws {
		let instructionsScore = Score(instructions: "instructions")
		#expect(instructionsScore.instructions == "instructions")
	}

	@Test func noticesSetPostInit() async throws {
		score.notices = "notices"
		#expect(score.notices == "notices")
	}

	@Test func noticesSetDuringInit() async throws {
		let noticesScore = Score(notices: "notices")
		#expect(noticesScore.notices == "notices")
	}

	@Test func allTitlesSetDuringInit() async throws {
		let scoreAllTitles = Score(
			title: "title",
			subtitle: "subtitle",
			artist: "artist",
			album: "album",
			words: "words",
			music: "music",
			wordsAndMusic: "wordsAndMusic",
			transcriber: "transcriber",
			instructions: "instructions",
			notices: "notices"
		)
		#expect(scoreAllTitles.title == "title")
		#expect(scoreAllTitles.subtitle == "subtitle")
		#expect(scoreAllTitles.artist == "artist")
		#expect(scoreAllTitles.album == "album")
		#expect(scoreAllTitles.words == "words")
		#expect(scoreAllTitles.music == "music")
		#expect(scoreAllTitles.wordsAndMusic == "wordsAndMusic")
		#expect(scoreAllTitles.transcriber == "transcriber")
		#expect(scoreAllTitles.instructions == "instructions")
		#expect(scoreAllTitles.notices == "notices")
	}

	// MARK: -- RandomAccess Conformance

	@Test func randomAccessStartIndex() async throws {
		#expect(score.startIndex == score.parts.startIndex)
	}

	@Test func randomAccessEndIndex() async throws {
		#expect(score.endIndex == score.parts.endIndex)
	}

	@Test func randomAccessIndexAfter() async throws {
		#expect(score.index(after: 2) == score.parts.index(after: 2))
	}

	@Test func randomAccessIteration() async throws {
		var count = 0
		var names: Array<String> = []
		for part in score {
			count += 1
			let name = if let name = part.instrument?.name {
				name
			} else {
				""
			}
			names.append(name)
		}

		#expect(count == 4)
		#expect(names == ["instrument 1", "instrument 2", "instrument 3", "instrument 4"])
	}

	// MARK: -- BidirectionalCollection Conformance

	@Test func BidirectionalIndexBefore() async throws {
		#expect(score.index(before: 2) == score.parts.index(before: 2))
	}

	// MARK: -- BidirectionalCollection Conformance

	@Test func rangeReplaceableEmptyInit() async throws {
		let emptyScore = Score()
		#expect(emptyScore.parts.count == 0)
		#expect(emptyScore.title == "")
		#expect(emptyScore.subtitle == "")
		#expect(emptyScore.firstPageHeader == nil)
		#expect(emptyScore.masterPart == nil)
	}

	@Test func rangeReplaceableAppend() async throws {
		let part5 = Part(instrument: Instrument(name: "instrument 5"))
		score.append(part5)

		#expect(score[4].instrument?.name == "instrument 5")
	}

	@Test func rangeReplaceableInsert() async throws {
		let part0 = Part(instrument: Instrument(name: "instrument 0"))
		score.insert(contentsOf: [part0], at: 0)
		#expect(score[0].instrument?.name == "instrument 0")
	}

	@Test func rangeReplaceableRemoveLast() async throws {
		score.removeLast()
		#expect(score.count == 3)
	}

	// MARK: -- MutableCollection Conformance

	@Test func mutableCollectionReplace() async throws {
		#expect(score[1].instrument?.name == "instrument 2")
		let newpart1 = Part(instrument: Instrument(name: "replaced instrument 2"))
		score[1] = newpart1
		#expect(score[1].instrument?.name == "replaced instrument 2")
	}

	// MARK: -- CustomDebugStringConvertible Conformance

	@Test func debugString() async throws {
		let string = "Score version: 0.3.0, parts(Part(instrument `instrument 1`), staves(staff(treble |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1, 1/16c1, 1/16c1]|, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 2, [ |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1]| ] × 3, |4/4: [3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|, |4/4: [1/16c1, 1/16c1, 1/16c1, 1/16c1, 3[1/16c1, 1/16c1, 1/16c1]]|, |4/4: [1/16a1, 3[1/16c1, 1/16c1, 1/16c1], 3[1/16c1, 1/16c1, 1/16c1], 1/16c1]|, |4/4: [3[1/16a1, 1/16c1, 1/16c1], 1/16c1, 1/16c1]|)), Part(instrument `instrument 2`), staves(), Part(instrument `instrument 3`), staves(), Part(instrument `instrument 4`), staves())"
		#expect(score!.debugDescription == string)
	}
}
