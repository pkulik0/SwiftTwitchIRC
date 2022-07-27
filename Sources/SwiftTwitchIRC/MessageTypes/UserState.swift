//
//  UserState.swift
//  
//
//  Created by pkulik0 on 25/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func handleUserState(id: String, chatroom: String, tags: [String: String]) {
        guard let onUserStateChanged = onUserStateChanged,
              let userName = tags["display-name"],
              let badgesString = tags["badges"],
              let color = tags["color"],
              let emoteSets = tags["emote-sets"]?.split(separator: ",").map({ String($0) })
        else {
            return
        }
        
        let badges = parseBadges(badgesString)
        onUserStateChanged(UserState(id: id, chatroom: chatroom, userName: userName, color: color, badges: badges, emoteSets: emoteSets, messageID: tags["id"]))
    }
    
    public struct UserState: IRCMessage, IRCUserInfo {
        public var id: String
        public var chatroom: String
        
        public var userName: String
        public var color: String
        public var badges: [String: String]
        public var emoteSets: [String]
        
        public var messageID: String?
    }
}
