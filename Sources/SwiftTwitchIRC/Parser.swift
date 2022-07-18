//
//  Parser.swift
//  
//
//  Created by pkulik0 on 18/07/2022.
//

public extension SwiftTwitchIRC {
    struct ChatMessage {
        var id: String
        var channel: String
        
        var userID: String
        var userName: String
        var badges: [String: Int]
        var color: String
        
        var text: String
    }
    
    func parseData(message: String) -> ChatMessage? {
        var message = message
        var index = message.startIndex
        var chatMessage = ChatMessage(id: "", channel: "", userID: "", userName: "", badges: [:], color: "", text: "")
        
        if message[index] == "@" {
            index = message.firstIndex(of: " ") ?? message.startIndex
            let tags = String(message[message.index(after: message.startIndex)..<index])
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
        parseCommand(command: command)
        
        index = message.index(after: index)
        message = String(message[index...])
        chatMessage.text = message
        
        print(chatMessage)
        
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
            default:
                break
            }
        }
    }
    
    func parseCommand(command: String) {
        print("\t command")
        print(command)
    }
}
