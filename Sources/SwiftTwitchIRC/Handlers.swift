//
//  Handlers.swift
//  
//
//  Created by pkulik0 on 23/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func handleClearChat(id: String, chatroom: String, tags: [String: String]) {
        guard let onChatClear = onClearChat else {
            print("failed clear chat")
            return
        }
        
        var banDuration: Int? = nil
        if let durationString = tags["ban-duration"] {
            banDuration = Int(durationString)
        }
        
        onChatClear(ClearChat(id: id, chatroom: chatroom, targetUserID: tags["target-user-id"], banDuration: banDuration))
    }
    
    internal func handleClearMessage(id: String, chatroom: String, tags: [String: String]) {
        guard let onClearMessage = onClearMessage,
              let executorName = tags["login"],
              let targetMessageID = tags["target-msg-id"]
        else {
            print("failed clear msg")
            return
        }
        
        onClearMessage(ClearMessage(id: id, chatroom: chatroom, executorName: executorName, targetMessageID: targetMessageID))
    }
    
    internal func handleUserState(id: String, chatroom: String, tags: [String: String]) {
        guard let onUserStateChanged = onUserStateChanged,
              let userName = tags["display-name"],
              let badgesString = tags["badges"],
              let color = tags["color"],
              let emoteSets = tags["emote-sets"]?.split(separator: ",").map({ String($0) })
        else {
            print("failed userstate")
            return
        }
        
        let badges = parseBadges(badgesString)
        onUserStateChanged(UserState(id: id, chatroom: chatroom, userName: userName, color: color, badges: badges, emoteSets: emoteSets))
    }
    
    internal func handleNotice(id: String, chatroom: String, tags: [String: String], content: String) {
        guard let onNoticeReceived = onNoticeReceived,
              let noticeString = tags["msg-id"],
              let noticeMessage = Notice.NoticeType(rawValue: noticeString)
        else {
            print("failed notice")
            return
        }
        
        onNoticeReceived(Notice(id: id, chatroom: chatroom, type: noticeMessage, targetUserID: tags["target-user-id"], text: content))
    }
    
    internal func handleRoomState(id: String, chatroom: String, tags: [String: String]) {
        guard let onRoomStateChanged = onRoomStateChanged else {
            print("failed roomstate")
            return
        }
        
        var isEmoteOnly: Bool? = nil
        var followersOnlyDuration: Int? = nil
        var isSubsOnly: Bool? = nil
        var slowModeDuration: Int? = nil
        var isInUniqueMode: Bool? = nil
        
        if let emoteOnlyString = tags["emote-only"] {
            isEmoteOnly = emoteOnlyString == "1"
        }
        if let followersOnlyString = tags["followers-only"] {
            followersOnlyDuration = Int(followersOnlyString)
        }
        if let subsOnlyString = tags["subs-only"] {
            isSubsOnly = subsOnlyString == "1"
        }
        if let slowModeString = tags["slow"] {
            slowModeDuration = Int(slowModeString)
        }
        if let uniqueModeString = tags["r9k"] {
            isInUniqueMode = uniqueModeString == "1"
        }
        
        onRoomStateChanged(RoomState(id: id, chatroom: chatroom, isEmoteOnly: isEmoteOnly, isSubsOnly: isSubsOnly, followersOnlyDuration: followersOnlyDuration, slowModeDuration: slowModeDuration, isInUniqueMode: isInUniqueMode))
    }
    
    internal func handleUserNotice(chatroom: String, tags: [String: String]) {
        guard let onUserEvent = onUserEvent,
              let id = tags["id"],
              let userName = tags["display-name"],
              let userLogin = tags["login"],
              let badgesString = tags["badges"],
              let typeString = tags["msg-id"],
              let type = UserEvent.EventType(rawValue: typeString),
              let color = tags["color"]
        else {
            print("failed usernotice")
            return
        }
        
        let badges = parseBadges(badgesString)
        var subInfo: UserEvent.SubInfo? = nil
        var giftInfo: UserEvent.GiftInfo? = nil
        var raidInfo: UserEvent.RaidInfo? = nil
        var ritualInfo: UserEvent.RitualInfo? = nil
        var earnedBitsBadge: String? = nil
        
        switch(type) {
        case .sub:
            fallthrough
        case .resub:
            guard let cumulativeMonthsString = tags["msg-param-cumulative-months"],
                  let cumulativeMonths = Int(cumulativeMonthsString),
                  let subTypeString = tags["msg-param-sub-plan"],
                  let subType = UserEvent.SubType(rawValue: subTypeString)
            else {
                print("failed usernotice sub/resub")
                break
            }
            
            var currentStreak: Int? = nil
            if let currentStreakString = tags["msg-param-streak-months"] {
                currentStreak = Int(currentStreakString)
            }
            
            subInfo = UserEvent.SubInfo(cumulativeMonths: cumulativeMonths, currentStreak: currentStreak, subType: subType)
        case .subgift:
            guard let cumulativeMonthsString = tags["msg-param-months"],
                  let cumulativeMonths = Int(cumulativeMonthsString),
                  let giftedMonthsString = tags["msg-param-gift-months"],
                  let giftedMonths = Int(giftedMonthsString),
                  let subTypeString = tags["msg-param-sub-plan"],
                  let subType = UserEvent.SubType(rawValue: subTypeString),
                  let recipientName = tags["msg-param-recipient-display-name"],
                  let recipientID = tags["msg-param-recipient-id"]
            else {
                print("failed usernotice subgift")
                break
            }
            
            giftInfo = UserEvent.GiftInfo(cumulativeMonths: cumulativeMonths, giftedMonths: giftedMonths, subType: subType, recipientName: recipientName, recipientID: recipientID)
        case .raid:
            guard let broadcasterName = tags["msg-param-displayName"],
                  let viewerCountString = tags["msg-param-viewerCount"],
                  let viewerCount = Int(viewerCountString)
            else {
                print("failed usernotice raid")
                break
            }
            
            raidInfo = UserEvent.RaidInfo(broadcasterName: broadcasterName, viewerCount: viewerCount)
        case .ritual:
            guard let ritualTypeString = tags["msg-param-ritual-name"],
                  let ritualType = UserEvent.RitualInfo.RitualType(rawValue: ritualTypeString)
            else {
                print("failed usernotice ritual")
                break
            }
            
            ritualInfo = UserEvent.RitualInfo(type: ritualType)
        case .bitsBadgeTier:
            earnedBitsBadge = tags["msg-param-threshold"]
        default:
            break
        }
        
        onUserEvent(UserEvent(id: id, userName: userName, userLogin: userLogin, badges: badges, color: color, type: type, subInfo: subInfo, giftInfo: giftInfo, raidInfo: raidInfo, ritualInfo: ritualInfo, earnedBitsBadge: earnedBitsBadge))
    }
    
    internal func handleWhisper(tags: [String: String], content: String) {
        guard let onWhisperReceived = onWhisperReceived,
              let id = tags["message-id"],
              let fromUserName = tags["display-name"],
              let badgesString = tags["badges"],
              let color = tags["color"]
        else {
            print("failed whisper")
            return
        }

        let badges = parseBadges(badgesString)
        onWhisperReceived(WhisperMessage(id: id, fromUserName: fromUserName, badges: badges, color: color, text: content))
    }
    
    internal func handlePrivMsg(info: String, chatroom: String, tags: [String: String], content: String) {
        guard let onMessageReceived = onMessageReceived,
              let id = tags["id"],
              let userID = tags["user-id"],
              let userName = tags["display-name"],
              let badgesString = tags["badges"],
              let color = tags["color"]
        else {
            print("failed privmsg")
            return
        }

        let userLogin = String(info[..<(info.firstIndex(of: "!") ?? info.endIndex)])
        let badges = parseBadges(badgesString)
        onMessageReceived(ChatMessage(id: id, chatroom: chatroom, userID: userID, userName: userName, userLogin: userLogin, badges: badges, color: color, text: content))
    }
}
