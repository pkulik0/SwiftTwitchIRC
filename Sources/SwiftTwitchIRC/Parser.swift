//
//  Parser.swift
//  
//
//  Created by pkulik0 on 18/07/2022.
//

import Foundation

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func parseMessage(_ message: String) {
        if message.first == ":" {
            return
        }
        
        let messageParts = message.split(separator: " ")
        if messageParts.count < 4 {
            return
        }
        
        let tags = String(messageParts[0].dropFirst())
        let info = String(messageParts[1].dropFirst())
        let command = String(messageParts[2])
        var chatroom = String(messageParts[3].dropFirst())
        var content = ""
        
        if let range = message.range(of: "#\(chatroom)"), range.upperBound != message.endIndex {
            let startIndex = message.index(range.upperBound, offsetBy: 2)
            content = String(message[startIndex...])
        }
        
        let fallbackID = UUID().uuidString
        let parsedTags = parseTags(tags)
        
        switch(command) {
        case "CLEARCHAT":
            handleClearChat(id: fallbackID, chatroom: chatroom, tags: parsedTags)
        case "CLEARMSG":
            handleClearMessage(id: fallbackID, chatroom: chatroom, tags: parsedTags)
        case "GLOBALUSERSTATE":
            chatroom = "*"
            fallthrough
        case "USERSTATE":
            handleUserState(id: fallbackID, chatroom: chatroom, tags: parsedTags)
        case "NOTICE":
            handleNotice(id: fallbackID, chatroom: chatroom, tags: parsedTags, content: content)
        case "ROOMSTATE":
            handleRoomState(id: fallbackID, chatroom: chatroom, tags: parsedTags)
        case "USERNOTICE":
            handleUserNotice(chatroom: chatroom, tags: parsedTags, content: content)
        case "WHISPER":
            handleWhisper(tags: parsedTags, content: content)
        case "PRIVMSG":
            handlePrivMsg(info: info, chatroom: chatroom, tags: parsedTags, content: content)
        case "RECONNECT":
            fallthrough
        default:
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
    
    internal func parseTags(_ tags: String) -> [String: String] {
        parseFromString(tags, firstSeparator: ";", secondSeparator: "=")
    }
    
    internal func parseBadges(_ badges: String) -> [String: String] {
        parseFromString(badges, firstSeparator: ",", secondSeparator: "/")
    }
}
