//
//  Parser.swift
//  
//
//  Created by pkulik0 on 18/07/2022.
//

import Foundation

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    func parseData(message: String) {
        if message.first == ":" {
            return
        }
        
        let messageParts = message.split(separator: " ")
        
        guard var tags = messageParts[safe: 0],
              let command = messageParts[safe: 2],
              let channel = messageParts[safe: 3]
        else {
            return
        }
        tags.remove(at: tags.startIndex)
        let parsedTags = parseTags(String(tags))
        
        var content = ""
        if let range = message.range(of: channel),
            range.upperBound != message.endIndex {
            let startIndex = message.index(range.upperBound, offsetBy: 2)
            content = String(message[startIndex...])
        }
        
        let fallbackID = UUID().uuidString
        let commandString = String(command)
        var channelString = String(channel.dropFirst())
        
        switch(command) {
        case "CLEARCHAT":
            guard let onChatClear = onClearChat else {
                print("failed clear chat")
                break
            }
            var banDuration: Int? = nil
            if let durationString = parsedTags["ban-duration"] {
                banDuration = Int(durationString)
            }
            onChatClear(ClearChat(id: fallbackID, command: commandString, chatroom: channelString, targetUserID: parsedTags["target-user-id"], banDuration: banDuration))
        case "CLEARMSG":
            guard let onClearMessage = onClearMessage,
                  let executorName = parsedTags["login"],
                  let targetMessageID = parsedTags["target-msg-id"]
            else {
                print("failed clear msg")
                break
            }
            onClearMessage(ClearMessage(id: fallbackID, command: commandString, chatroom: channelString, executorName: executorName, targetMessageID: targetMessageID))
        case "GLOBALUSERSTATE":
            channelString = "*"
            fallthrough
        case "USERSTATE":
            guard let onUserStateChanged = onUserStateChanged,
                  let userName = parsedTags["display-name"],
                  let badgesString = parsedTags["badges"],
                  let color = parsedTags["color"],
                  let emoteSets = parsedTags["emote-sets"]?.split(separator: ",").map({ String($0) })
            else {
                print("failed userstate")
                break
            }
            let badges = parseBadges(badgesString)
            onUserStateChanged(UserState(id: fallbackID, command: commandString, chatroom: channelString, userName: userName, color: color, badges: badges, emoteSets: emoteSets))
        case "HOSTTARGET":
            let contentParts = content.split(separator: " ")
            guard let onHostStarted = onHostStarted,
                  let hostedChannel = contentParts[safe: 0],
                  let viewersString = contentParts[safe: 1],
                  let viewerCount = Int(viewersString)
            else {
                print("failed hosttarget")
                break
            }
            onHostStarted(HostInfo(id: fallbackID, command: commandString, chatroom: channelString, hostedChannel: String(hostedChannel), viewerCount: viewerCount))
        case "NOTICE":
            guard let onNoticeReceived = onNoticeReceived,
                  let noticeString = parsedTags["msg-id"],
                  let noticeMessage = Notice.NoticeType(rawValue: noticeString)
            else {
                print("failed notice")
                break
            }
            onNoticeReceived(Notice(id: fallbackID, command: commandString, chatroom: channelString, type: noticeMessage, targetUserID: parsedTags["target-user-id"], text: content))
        case "RECONNECT":
            print("reconnect")
            break
        case "ROOMSTATE":
            guard let onRoomStateChanged = onRoomStateChanged else {
                print("failed roomstate")
                break
            }
            var isEmoteOnly: Bool? = nil
            var followersOnlyDuration: Int? = nil
            var isSubsOnly: Bool? = nil
            var slowModeDuration: Int? = nil
            var isInUniqueMode: Bool? = nil
            
            if let emoteOnlyString = parsedTags["emote-only"] {
                isEmoteOnly = emoteOnlyString == "1"
            }
            if let followersOnlyString = parsedTags["followers-only"] {
                followersOnlyDuration = Int(followersOnlyString)
            }
            if let subsOnlyString = parsedTags["subs-only"] {
                isSubsOnly = subsOnlyString == "1"
            }
            if let slowModeString = parsedTags["slow"] {
                slowModeDuration = Int(slowModeString)
            }
            if let uniqueModeString = parsedTags["r9k"] {
                isInUniqueMode = uniqueModeString == "1"
            }
            
            onRoomStateChanged(RoomState(id: fallbackID, command: commandString, chatroom: channelString, isEmoteOnly: isEmoteOnly, isSubsOnly: isSubsOnly, followersOnlyDuration: followersOnlyDuration, slowModeDuration: slowModeDuration, isInUniqueMode: isInUniqueMode))
        case "USERNOTICE":
            guard let onUserEvent = onUserEvent,
                  let id = parsedTags["id"],
                  let userName = parsedTags["display-name"],
                  let badgesString = parsedTags["badges"],
                  let typeString = parsedTags["msg-id"],
                  let type = UserEvent.EventType(rawValue: typeString),
                  let color = parsedTags["color"]
            else {
                print("failed usernotice")
                break
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
                guard let cumulativeMonthsString = parsedTags["msg-param-cumulative-months"],
                      let cumulativeMonths = Int(cumulativeMonthsString),
                      let subTypeString = parsedTags["msg-param-sub-plan"],
                      let subType = UserEvent.SubType(rawValue: subTypeString)
                else {
                    print("failed resub")
                    break
                }
                var currentStreak: Int? = nil
                if let currentStreakString = parsedTags["msg-param-streak-months"] {
                    currentStreak = Int(currentStreakString)
                }
                subInfo = UserEvent.SubInfo(cumulativeMonths: cumulativeMonths, currentStreak: currentStreak, subType: subType)
            case .subgift:
                guard let cumulativeMonthsString = parsedTags["msg-param-months"],
                      let cumulativeMonths = Int(cumulativeMonthsString),
                      let giftedMonthsString = parsedTags["msg-param-gift-months"],
                      let giftedMonths = Int(giftedMonthsString),
                      let subTypeString = parsedTags["msg-param-sub-plan"],
                      let subType = UserEvent.SubType(rawValue: subTypeString),
                      let recipientName = parsedTags["msg-param-recipient-display-name"],
                      let recipientID = parsedTags["msg-param-recipient-id"],
                      let senderName = parsedTags["msg-param-sender-name"]
                else {
                    print("failed subgift")
                    break
                }
                giftInfo = UserEvent.GiftInfo(cumulativeMonths: cumulativeMonths, giftedMonths: giftedMonths, subType: subType, recipientName: recipientName, recipientID: recipientID, senderName: senderName)
            case .raid:
                guard let broadcasterName = parsedTags["msg-param-displayName"],
                      let viewerCountString = parsedTags["msg-param-viewerCount"],
                      let viewerCount = Int(viewerCountString)
                else {
                    print("failed raid")
                    break
                }
                raidInfo = UserEvent.RaidInfo(broadcasterName: broadcasterName, viewerCount: viewerCount)
            case .ritual:
                guard let ritualTypeString = parsedTags["msg-param-ritual-name"],
                      let ritualType = UserEvent.RitualInfo.RitualType(rawValue: ritualTypeString)
                else {
                    print("failed ritual")
                    break
                }
                ritualInfo = UserEvent.RitualInfo(type: ritualType)
            case .bitsBadgeTier:
                earnedBitsBadge = parsedTags["msg-param-threshold"]
            default:
                break
            }
            
            onUserEvent(UserEvent(id: id, command: commandString, userName: userName, badges: badges, color: color, type: type, subInfo: subInfo, giftInfo: giftInfo, raidInfo: raidInfo, ritualInfo: ritualInfo, earnedBitsBadge: earnedBitsBadge))
        case "WHISPER":
            guard let onWhisperReceived = onWhisperReceived,
                  let id = parsedTags["message-id"],
                  let fromUserName = parsedTags["display-name"],
                  let badgesString = parsedTags["badges"],
                  let color = parsedTags["color"]
            else {
                print("failed whisper")
                break
            }
            let badges = parseBadges(badgesString)
            onWhisperReceived(WhisperMessage(id: id, command: commandString, fromUserName: fromUserName, badges: badges, color: color, text: content))
        case "PRIVMSG":
            guard let onMessageReceived = onMessageReceived,
                  let id = parsedTags["id"],
                  let userID = parsedTags["user-id"],
                  let userName = parsedTags["display-name"],
                  let badgesString = parsedTags["badges"],
                  let color = parsedTags["color"]
            else {
                print("failed privmsg")
                break
            }
            let badges = parseBadges(badgesString)
            onMessageReceived(ChatMessage(id: id, command: commandString, chatroom: channelString, userID: userID, userName: userName, badges: badges, color: color, text: content))
        default:
            print("unrecognized command: \(message)")
            break
        }
    }
    
    private func parseFromString(_ elements: String, firstSeparator: Character, secondSeparator: Character) -> [String: String] {
        var parsedElements: [String: String] = [:]
        let separatedElements = elements.split(separator: firstSeparator)
        
        for element in separatedElements {
            let data = element.split(separator: secondSeparator)
            
            guard let name = data[safe: 0] else {
                continue
            }
            parsedElements[String(name)] = String(data[safe: 1] ?? "")
        }
        return parsedElements
    }
    
    private func parseTags(_ tags: String) -> [String: String] {
        parseFromString(tags, firstSeparator: ";", secondSeparator: "=")
    }
    
    private func parseBadges(_ badges: String) -> [String: String] {
        parseFromString(badges, firstSeparator: ",", secondSeparator: "/")
    }
}
