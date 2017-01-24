import Foundation
import XCTest

@testable import CF_Apps

class StringTests: XCTestCase {
    func testBumpLastChar() {
        assertBumpedChar("a", after: "b")
        assertBumpedChar("aa", after: "ab")
        assertBumpedChar("-", after: ".")
        assertBumpedChar(" ", after: " ")
    }
    
    func assertBumpedChar(before: String, after: String) {
        XCTAssertEqual(before.bumpLastChar(), after)
    }
    
    func testIsValidURL() {
        assertURLValididty("invalid", isValid: false)
        assertURLValididty("https://", isValid: false)
        assertURLValididty("https://test", isValid: false)
        assertURLValididty("https://test.io", isValid: true)
        assertURLValididty("https://test.test.io", isValid: true)
    }
    
    func assertURLValididty(url: String, isValid: Bool) {
        XCTAssertEqual(url.isValidURL(), isValid, "'\(url)' url valididty should not be \(isValid).")
    }
}