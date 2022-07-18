import XCTest
@testable import SwiftTwitchIRC

final class SwiftTwitchIRCTests: XCTestCase {
    func testExample() throws {
        let expectation = XCTestExpectation(description: "aha")
        let irc = SwiftTwitchIRC(username: "qurrie", token: "3184l994nsn2lgpq8gaup3oe3xifty")

        wait(for: [expectation], timeout: 3000.0)
    }
}
