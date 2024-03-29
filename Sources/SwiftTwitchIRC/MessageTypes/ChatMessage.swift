//
//  ChatMessage.swift
//  
//
//  Created by pkulik0 on 25/07/2022.
//

import Foundation

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func handlePrivMsg(info: String, chatroom: String, tags: [String: String], content: String) {
        guard let onMessageReceived = onMessageReceived,
              let id = tags["id"],
              let userID = tags["user-id"],
              let userName = tags["display-name"],
              let badgesString = tags["badges"],
              let color = tags["color"]
        else {
            return
        }
        
        let userLogin = String(info[..<(info.firstIndex(of: "!") ?? info.endIndex)])
        let badges = parseBadges(badgesString)
        var replyParent: ChatMessage.ReplyParent? = nil
        
        if let parentID = tags["reply-parent-msg-id"],
           let parentUserID = tags["reply-parent-user-id"],
           let parentUserLogin = tags["reply-parent-user-login"],
           let parentUserName = tags["reply-parent-display-name"],
           let parentBody = tags["reply-parent-msg-body"] {
            replyParent = ChatMessage.ReplyParent(id: parentID, userID: parentUserID, userName: parentUserName, userLogin: parentUserLogin, text: parentBody)
        }
        
        onMessageReceived(ChatMessage(id: id, chatroom: chatroom, userID: userID, userName: userName, userLogin: userLogin, badges: badges, color: color, text: content, replyParent: replyParent))
    }
    
    public struct ChatMessage: IRCMessage, IRCUserInfo {
        public var id: String
        public var chatroom: String
        
        public var userID: String
        public var userName: String
        public var userLogin: String
        public var badges: [String: String]
        public var color: String
        
        public var text: String
        public var replyParent: ReplyParent?
        
        public var displayableName: String {
            get {
                if userName.lowercased() != userLogin {
                    return "\(userName) (\(userLogin))"
                }
                return userLogin
            }
        }
        
        public init(id: String, chatroom: String, userID: String, userName: String, userLogin: String, badges: [String: String], color: String, text: String, replyParent: ReplyParent? = nil) {
            self.id = id
            self.chatroom = chatroom
            
            self.userID = userID
            self.userName = userName
            self.userLogin = userLogin
            self.badges = badges
            self.color = color
            
            self.text = text
            self.replyParent = replyParent
        }
        
        public init(text: String, userState: UserState) {
            self.id = UUID().uuidString
            self.chatroom = userState.chatroom
            self.userID = ""
            self.userName = userState.userName
            self.userLogin = userState.userName
            self.badges = userState.badges
            self.color = userState.color
            self.text = text
        }
        
        public struct ReplyParent: Identifiable, Hashable, Codable {
            public var id: String
            
            public var userID: String
            public var userName: String
            public var userLogin: String
            
            public var text: String
            
            public var displayableName: String {
                get {
                    if userName.lowercased() != userLogin {
                        return "\(userName) (\(userLogin))"
                    }
                    return userLogin
                }
            }
        }
    }
}
