import Foundation
import XCTest

@testable import CF_Apps

class StringTests: XCTestCase {
    func testBumpLastChar() {
        XCTAssertEqual("a".bumpLastChar(), "b")
        XCTAssertEqual("aa".bumpLastChar(), "ab")
        XCTAssertEqual("-".bumpLastChar(), ".")
        XCTAssertEqual(" ".bumpLastChar(), " ")
    }
}