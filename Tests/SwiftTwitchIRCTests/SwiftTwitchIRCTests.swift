import XCTest
@testable import SwiftTwitchIRC

final class SwiftTwitchIRCTests: XCTestCase {
    func testExample() throws {
        let expectation = XCTestExpectation(description: "aha")
        let irc = SwiftTwitchIRC(username: "qurrie", token: "3184l994nsn2lgpq8gaup3oe3xifty", onMessageReceived: printMsg)
        irc.sendMessage(message: "123", channel: "qurrie")
        irc.sendWhisper(message: "hi", to: "qurrierurie")

        wait(for: [expectation], timeout: 360000.0)
    }
    
    func printMsg(msg: SwiftTwitchIRC.ChatMessage) {
        print(msg)
    }
}
