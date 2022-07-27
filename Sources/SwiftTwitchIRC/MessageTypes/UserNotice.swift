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
              let typeString = tags["msg-id"],
              let type = UserNotice.EventType(rawValue: typeString),
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
        
        public var type: EventType
        public var systemMessage: String
        public var text: String
        
        public enum EventType: String, Codable {
            case sub, resub, subgift, raid, unraid, ritual, announcement
            case communityPayForward = "communitypayforward"
            case giftPaidUpgrade = "giftpaidupgrade"
            case primePaidUpgrade = "primepaidupgrade"
            case subMysteryGift = "submysterygift"
            case rewardGift = "rewardgift"
            case anonGiftPaidUpgrade = "anongiftpaidupgrade"
            case bitsBadgeTier = "bitsbadgetier"
        }
    }
}
