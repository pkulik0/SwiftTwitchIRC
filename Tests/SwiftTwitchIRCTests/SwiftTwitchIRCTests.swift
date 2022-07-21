import XCTest
@testable import SwiftTwitchIRC

final class SwiftTwitchIRCTests: XCTestCase {
    func testExample() throws {
        let expectation = XCTestExpectation(description: "aha")
        let irc = SwiftTwitchIRC(username: "qurrie", token: "3184l994nsn2lgpq8gaup3oe3xifty",
                                 onMessageReceived: printMsg,
                                 onWhisperReceived: printMsg,
                                 onNoticeReceived: printMsg,
                                 onUserEvent: printMsg,
                                 onUserStateChanged: printMsg,
                                 onRoomStateChanged: printMsg,
                                 onClearChat: printMsg,
                                 onClearMessage: printMsg,
                                 onHostStarted: printMsg)
        irc.joinChannel(channel: "hasanabi")

        wait(for: [expectation], timeout: 360000.0)
    }
    
    func printMsg<T>(msg: T) {
        print(msg)
    }
}
