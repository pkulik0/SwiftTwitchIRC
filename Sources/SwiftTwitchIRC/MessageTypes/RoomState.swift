//
//  RoomState.swift
//  
//
//  Created by pkulik0 on 25/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
extension SwiftTwitchIRC {
    internal func handleRoomState(id: String, chatroom: String, tags: [String: String]) {
        guard let onRoomStateChanged = onRoomStateChanged else {
            return
        }
        
        var isEmoteOnly: Bool? = nil
        var followersOnlyDuration: Int? = nil
        var isSubsOnly: Bool? = nil
        var slowModeDuration: Int? = nil
        var isInUniqueMode: Bool? = nil
        
        if let emoteOnlyString = tags["emote-only"] {
            isEmoteOnly = emoteOnlyString == "1"
        }
        if let followersOnlyString = tags["followers-only"] {
            followersOnlyDuration = Int(followersOnlyString)
        }
        if let subsOnlyString = tags["subs-only"] {
            isSubsOnly = subsOnlyString == "1"
        }
        if let slowModeString = tags["slow"] {
            slowModeDuration = Int(slowModeString)
        }
        if let uniqueModeString = tags["r9k"] {
            isInUniqueMode = uniqueModeString == "1"
        }
        
        onRoomStateChanged(RoomState(id: id, chatroom: chatroom, isEmoteOnly: isEmoteOnly, isSubsOnly: isSubsOnly, followersOnlyDuration: followersOnlyDuration, slowModeDuration: slowModeDuration, isInUniqueMode: isInUniqueMode))
    }
    
    public struct RoomState: IRCMessage {
        public var id: String
        public var chatroom: String
        
        public var isEmoteOnly: Bool?
        public var isSubsOnly: Bool?
        public var followersOnlyDuration: Int?
        public var slowModeDuration: Int?
        public var isInUniqueMode: Bool?
    }
}
