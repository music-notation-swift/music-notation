import XCTest
@testable import music_notation

final class music_notationTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(music_notation().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
