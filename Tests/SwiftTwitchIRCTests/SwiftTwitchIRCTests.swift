import XCTest
@testable import SwiftTwitchIRC

final class SwiftTwitchIRCTests: XCTestCase {
    let username = ""
    let token = ""
    
    func debugPrint<T>(msg: T) {
        print(msg)
    }
    
    func printChatMsg(msg: SwiftTwitchIRC.ChatMessage) {
        print("(\(msg.chatroom)) \(msg.displayableName): \(msg.text)")
    }
    
    override func setUpWithError() throws {
        self.continueAfterFailure = false
        XCTAssertFalse(username.isEmpty)
        XCTAssertFalse(token.isEmpty)
    }
    
    func testBasic() throws {
        let irc = SwiftTwitchIRC(username: username, token: token,
                                 onMessageReceived: printChatMsg,
                                 onWhisperReceived: debugPrint,
                                 onNoticeReceived: debugPrint,
                                 onUserEvent: debugPrint,
                                 onUserStateChanged: debugPrint,
                                 onRoomStateChanged: debugPrint,
                                 onClearChat: debugPrint,
                                 onClearMessage: debugPrint)
        irc.joinChatroom("hasanabi")
        sleep(1000)
    }
}
