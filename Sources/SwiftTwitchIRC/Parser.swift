//
//  Parser.swift
//  
//
//  Created by pkulik0 on 18/07/2022.
//

public extension SwiftTwitchIRC {
    struct ChatMessage: Identifiable {
        public var id: String
        public var command: String
        public var channel: String
        
        public var userID: String
        public var userName: String
        public var badges: [String: Int]
        public var color: String
        
        public var text: String
        
        public var noticeMessage: Notice?
        public var targetUserID: String?
        public var targetMessageID: String?
        public var banDuration: Int?
    }
    
    func parseData(message: String) -> ChatMessage? {
        var message = message
        var index = message.startIndex
        var chatMessage = ChatMessage(id: "", command: "", channel: "", userID: "", userName: "", badges: [:], color: "", text: "")
        
        if message[index] == "@" {
            index = message.firstIndex(of: " ") ?? message.startIndex
            
            var tags = String(message[..<index])
            if let firstCharacter = tags.first {
                if firstCharacter == "@" {
                    tags = String(tags[tags.index(after: tags.startIndex)...])
                }
            }
            
            parseTags(tags: tags, messageData: &chatMessage)
            
            index = message.index(after: index)
            message = String(message[index...])
            index = message.startIndex
        }
        
        if message[index] == ":" {
            index = message.firstIndex(of: " ") ?? message.startIndex
            message = String(message[index...])
        }
        
        index = message.firstIndex(of: ":") ?? message.endIndex
        
        if index == message.endIndex {
            return nil
        }
        
        let command = String(message[..<index]).trimmingCharacters(in: .whitespaces)
        parseCommand(command: command, messageData: &chatMessage)
        
        // Ignore numeric commands
        if let _ = Int(chatMessage.command) {
            return nil
        }
        
        index = message.index(after: index)
        chatMessage.text = String(message[index...])
        
        return chatMessage
    }
    
    func parseTags(tags: String, messageData: inout ChatMessage) {
        let tags = tags.split(separator: ";")
        
        for tag in tags {
            let tagData = tag.split(separator: "=")
            
            if tagData.count < 2 {
                continue
            }
            
            let tagName = tagData[0]
            let tagContent = tagData[1]
            
            switch(tagName) {
            case "badges":
                tagContent.split(separator: ",").forEach { badgeInfo in
                    let badgeInfo = badgeInfo.split(separator: "/")
                    let badgeName = String(badgeInfo[0])
                    let badgeLevel = Int(badgeInfo[1])
                    messageData.badges[badgeName] = badgeLevel
                }
            case "color":
                messageData.color = String(tagContent)
            case "display-name":
                messageData.userName = String(tagContent)
            case "user-id":
                messageData.userID = String(tagContent)
            case "id":
                messageData.id = String(tagContent)
            case "msg-id":
                messageData.noticeMessage = ChatMessage.Notice(rawValue: String(tagContent))
            case "target-msg-id":
                messageData.targetMessageID = String(tagContent)
            case "target-user-id":
                messageData.targetUserID = String(tagContent)
            case "ban-duration":
                messageData.banDuration = Int(tagContent)
            default:
                break
            }
        }
    }
    
    func parseCommand(command: String, messageData: inout ChatMessage) {
        let commandParts = command.split(separator: " ")
        messageData.command = String(commandParts[0])
        
        if commandParts.count > 1 {
            messageData.channel = String(commandParts[1])
        }
    }
}
