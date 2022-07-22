import XCTest
@testable import SwiftTwitchIRC

final class SwiftTwitchIRCTests: XCTestCase {
    func testExample() throws {
        let expectation = XCTestExpectation(description: "aha")
        let irc = SwiftTwitchIRC(username: "qurrie", token: "3184l994nsn2lgpq8gaup3oe3xifty",
                                 onMessageReceived: printChatMsg,
                                 onWhisperReceived: printMsg,
                                 onNoticeReceived: printMsg,
                                 onUserEvent: printMsg,
                                 onUserStateChanged: printMsg,
                                 onRoomStateChanged: printMsg,
                                 onClearChat: printMsg,
                                 onClearMessage: printMsg)
        irc.joinChannel(channel: "hasanabi")

        wait(for: [expectation], timeout: 360000.0)
    }
    
    func printMsg<T>(msg: T) {
//        print(msg)
    }
    func printChatMsg(msg: SwiftTwitchIRC.ChatMessage) {
//        print("(\(msg.chatroom)) \(msg.userName): \(msg.text)")
    }
}
