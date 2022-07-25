//
//  ClearChat.swift
//  
//
//  Created by pkulik0 on 25/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func handleClearChat(id: String, chatroom: String, tags: [String: String]) {
        guard let onChatClear = onClearChat else {
            return
        }
        
        var banDuration: Int? = nil
        if let durationString = tags["ban-duration"] {
            banDuration = Int(durationString)
        }
        
        onChatClear(ClearChat(id: id, chatroom: chatroom, targetUserID: tags["target-user-id"], banDuration: banDuration))
    }
    
    public struct ClearChat: IRCMessage {
        public var id: String
        public var chatroom: String
        
        public var targetUserID: String?
        public var banDuration: Int?
    }
}
