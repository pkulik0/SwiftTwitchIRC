//
//  Parser.swift
//  
//
//  Created by pkulik0 on 18/07/2022.
//

public extension SwiftTwitchIRC {
    struct ChatMessage {
        let sender: String
        let text: String
    }
    
    func parseData(message: String) -> ChatMessage? {
        var message = message
        var index = message.startIndex
        
        if message[index] == "@" {
            index = message.firstIndex(of: " ") ?? message.startIndex
            let tags = String(message[..<index])
            parseTags(tags: tags)
            
            index = message.index(after: index)
            message = String(message[index...])
            index = message.startIndex
        }
        
        if message[index] == ":" {
            index = message.firstIndex(of: " ") ?? message.startIndex
            let source = String(message[..<index])
            parseSource(source: source)
            
            message = String(message[index...])
            index = message.startIndex
        }
        
        index = message.firstIndex(of: ":") ?? message.endIndex
        
        if index == message.endIndex {
            return nil
        }
        
        let command = String(message[..<index]).trimmingCharacters(in: .whitespaces)
        parseCommand(command: command)
        
        index = message.index(after: index)
        message = String(message[index...])
        print("\t message")
        print(message)
        
        return ChatMessage(sender: "1", text: "2")
    }
    
    func parseTags(tags: String) {
        var parsedTags: [String: String] = [:]
        
        
        print("\t tags")
        print(tags)
    }
    
    func parseSource(source: String) {
        print("\t source")
        print(source)
    }
    
    func parseCommand(command: String) {
        print("\t command")
        print(command)
    }
}
