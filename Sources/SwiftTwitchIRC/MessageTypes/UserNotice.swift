//
//  UserNotice.swift
//  
//
//  Created by pkulik0 on 25/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func handleUserNotice(chatroom: String, tags: [String: String], content: String) {
        guard let onUserNoticeReceived = onUserNoticeReceived,
              let id = tags["id"],
              let userName = tags["display-name"],
              let userLogin = tags["login"],
              let badgesString = tags["badges"],
              let type = tags["msg-id"],
              var systemMessage = tags["system-msg"],
              let color = tags["color"]
        else {
            return
        }
        
        systemMessage = systemMessage.replacingOccurrences(of: "\\s", with: " ")
        let badges = parseBadges(badgesString)
        
        onUserNoticeReceived(UserNotice(id: id, chatroom: chatroom, userName: userName, userLogin: userLogin, badges: badges, color: color, type: type, systemMessage: systemMessage, text: content))
    }
    
    public struct UserNotice: IRCMessage, IRCUserInfo {
        public var id: String
        public var chatroom: String
        
        public var userName: String
        public var userLogin: String
        public var badges: [String : String]
        public var color: String
        
        public var type: String
        public var systemMessage: String
        public var text: String
    }
}
