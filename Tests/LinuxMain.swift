import XCTest
@testable import MusicNotationTests

#if os(linux)
XCTMain([
     testCase(MusicNotationTests.allTests)
])
#endif

