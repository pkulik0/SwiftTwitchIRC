//
//  Notice.swift
//  
//
//  Created by pkulik0 on 25/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func handleNotice(id: String, chatroom: String, tags: [String: String], content: String) {
        guard let onNoticeReceived = onNoticeReceived, let noticeType = tags["msg-id"] else {
            return
        }
        onNoticeReceived(Notice(id: id, chatroom: chatroom, type: noticeType, targetUserID: tags["target-user-id"], text: content))
    }
    
    public struct Notice: IRCMessage {
        public var id: String
        public var chatroom: String
        
        public var type: String
        public var targetUserID: String?
        public var text: String
    }
}
