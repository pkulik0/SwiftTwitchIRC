//
//  ClearMessage.swift
//  
//
//  Created by pkulik0 on 25/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func handleClearMessage(id: String, chatroom: String, tags: [String: String]) {
        guard let onClearMessage = onClearMessage,
              let executorName = tags["login"],
              let targetMessageID = tags["target-msg-id"]
        else {
            return
        }
        
        onClearMessage(ClearMessage(id: id, chatroom: chatroom, executorName: executorName, targetMessageID: targetMessageID))
    }
    
    public struct ClearMessage: IRCMessage {
        public var id: String
        public var chatroom: String
        
        public var executorName: String
        public var targetMessageID: String
    }
}
