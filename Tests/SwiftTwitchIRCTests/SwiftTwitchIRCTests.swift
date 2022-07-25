import XCTest
@testable import SwiftTwitchIRC

final class SwiftTwitchIRCTests: XCTestCase {
    let username = ""
    let token = ""
    
    func debugPrint<T>(msg: T) {
//        print(msg)
    }
    
    func printUserNotice(msg: SwiftTwitchIRC.UserNotice) {
//        print("\n\n\(msg.type) \nsysMsg: \(msg.systemMessage) \ncontent: \(msg.text)")
    }
    
    func printChatMsg(msg: SwiftTwitchIRC.ChatMessage) {
        print(".", terminator: "")
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
                                 onUserNoticeReceived: printUserNotice,
                                 onUserStateChanged: debugPrint,
                                 onRoomStateChanged: debugPrint,
                                 onClearChat: debugPrint,
                                 onClearMessage: debugPrint)
        sleep(3600 * 24)
    }
}
