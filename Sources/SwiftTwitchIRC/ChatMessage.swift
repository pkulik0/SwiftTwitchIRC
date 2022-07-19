//
//  ChatMessage.swift
//  
//
//  Created by pkulik0 on 19/07/2022.
//

extension SwiftTwitchIRC {
    public struct ChatMessage: Identifiable, Equatable {
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
}
