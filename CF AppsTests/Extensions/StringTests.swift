import Foundation
import XCTest

@testable import CF_Apps

class StringTests: XCTestCase {
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
