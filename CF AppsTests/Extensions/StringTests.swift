import Foundation
import XCTest

@testable import CFoundry

class StringTests: XCTestCase {
    func testBumpLastChar() {
        assertBumpedChar(before: "a", after: "b")
        assertBumpedChar(before: "aa", after: "ab")
        assertBumpedChar(before: "-", after: ".")
        assertBumpedChar(before: " ", after: " ")
    }
    
    func assertBumpedChar(before: String, after: String) {
        XCTAssertEqual(before.bumpLastChar(), after)
    }
    
    func testIsValidURL() {
        assertURLValididty(url: "invalid", isValid: false)
        assertURLValididty(url: "https://", isValid: false)
        assertURLValididty(url: "https://test", isValid: false)
        assertURLValididty(url: "https://test.io", isValid: true)
        assertURLValididty(url: "https://test.test.io", isValid: true)
    }
    
    func assertURLValididty(url: String, isValid: Bool) {
        XCTAssertEqual(url.isValidURL(), isValid, "'\(url)' url valididty should not be \(isValid).")
    }
}
