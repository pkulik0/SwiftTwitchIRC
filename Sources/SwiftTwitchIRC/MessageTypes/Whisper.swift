//
//  WhisperMessage.swift
//  
//
//  Created by pkulik0 on 25/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func handleWhisper(tags: [String: String], content: String) {
        guard let onWhisperReceived = onWhisperReceived,
              let id = tags["message-id"],
              let fromUserName = tags["display-name"],
              let badgesString = tags["badges"],
              let color = tags["color"]
        else {
            return
        }

        let badges = parseBadges(badgesString)
        onWhisperReceived(Whisper(id: id, fromUserName: fromUserName, badges: badges, color: color, text: content))
    }
    
    public struct Whisper: IRCMessage {
        public var id: String
        
        public var fromUserName: String
        public var badges: [String: String]
        public var color: String

        public var text: String
    }
}
