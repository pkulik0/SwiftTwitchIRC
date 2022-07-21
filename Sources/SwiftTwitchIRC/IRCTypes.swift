//
//  IRCTypes.swift
//  
//
//  Created by pkulik0 on 19/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
protocol IRCMessage: Identifiable, Hashable, Codable {
    var id: String { get set }
    var command: String { get set }
}

@available(macOS 10.15, iOS 13.0, *)
protocol IRCUserInfo: Identifiable, Hashable, Codable {
    var userName: String { get set }
    var badges: [String: String] { get set }
    var color: String { get set }
}

@available(macOS 10.15, iOS 13.0, *)
public extension SwiftTwitchIRC {
    struct ChatMessage: IRCMessage, IRCUserInfo {
        public var id: String
        public var command: String
        
        public var chatroom: String
        
        public var userID: String
        public var userName: String
        public var badges: [String: String]
        public var color: String
        
        public var text: String
        
        public var replyParent: ReplyParent?
        
        public struct ReplyParent: Identifiable, Hashable, Codable {
            public var id: String
            
            public var userID: String
            public var userName: String
            public var userLogin: String
            
            public var text: String
        }
    }
    
    struct EmptyMessage: IRCMessage {
        public var id: String
        public var command: String
    }
    
    struct UserState: IRCMessage, IRCUserInfo {
        public var id: String
        public var command: String
        
        public var chatroom: String
        
        public var userName: String
        public var color: String
        public var badges: [String: String]
        public var emoteSets: [String]
    }
    
    struct RoomState: IRCMessage {
        public var id: String
        public var command: String
        
        public var chatroom: String
        
        public var isEmoteOnly: Bool?
        public var isSubsOnly: Bool?
        public var followersOnlyDuration: Int?
        public var slowModeDuration: Int?
        public var isInUniqueMode: Bool?
    }
    
    struct ClearChat: IRCMessage {
        public var id: String
        public var command: String
        
        public var chatroom: String
        
        public var targetUserID: String?
        public var banDuration: Int?
    }
    
    struct ClearMessage: IRCMessage {
        public var id: String
        public var command: String
        
        public var chatroom: String
        
        public var executorName: String
        public var targetMessageID: String
    }
    
    struct WhisperMessage: IRCMessage {
        public var id: String
        public var command: String
        
        public var fromUserName: String
        public var badges: [String: String]
        public var color: String

        public var text: String
    }
    
    struct HostInfo: IRCMessage {
        public var id: String
        public var command: String
        
        public var chatroom: String
        
        public var hostedChannel: String
        public var viewerCount: Int
    }
    
    struct UserEvent: IRCMessage, IRCUserInfo {
        public var id: String
        public var command: String
        
        public var userName: String
        public var badges: [String : String]
        public var color: String
        
        public var type: EventType
        
        public var subInfo: SubInfo?
        public var giftInfo: GiftInfo?
        public var raidInfo: RaidInfo?
        public var ritualInfo: RitualInfo?
        public var earnedBitsBadge: String?
        
        public enum EventType: String, Codable {
            case sub, resub, subgift, raid, unraid, ritual
            case giftPaidUpgrade = "giftpaidupgrade"
            case rewardGift = "rewardgift"
            case anonGiftPaidUpgrade = "anongiftpaidupgrade"
            case bitsBadgeTier = "bitsbadgetier"
        }
        
        public enum SubType: String, Codable {
            case prime = "Prime"
            case tier1 = "1000"
            case tier2 = "2000"
            case tier3 = "3000"
        }
        
        public struct SubInfo: Hashable, Codable {
            public var cumulativeMonths: Int
            public var currentStreak: Int
            public var subType: SubType
            
        }
        
        public struct GiftInfo: Hashable, Codable {
            public var cumulativeMonths: Int
            public var giftedMonths: Int
            public var subType: SubType
            
            public var recipientName: String
            public var recipientID: String
            
            public var senderName: String
        }
        
        public struct RaidInfo: Hashable, Codable {
            public var broadcasterName: String
            public var viewerCount: Int
        }
        
        public struct RitualInfo: Hashable, Codable {
            public var type: RitualType
            
            public enum RitualType: String, Codable {
                case newChatter = "new_chatter"
            }
        }
    }
    
    struct Notice: IRCMessage {
        public var id: String
        public var command: String
        
        public var chatroom: String
        
        public var type: NoticeType
        public var targetUserID: String?
        public var text: String
        
        public enum NoticeType: String, Codable {
            case alreadyBanned = "already_banned"
            case alreadyEmoteOnlyOff = "already_emote_only_off"
            case alreadyEmoteOnlyOn = "already_emote_only_on"
            case alreadyFollowersOff = "already_followers_off"
            case alreadyFollowersOn = "already_followers_on"
            case alreadyR9KOff = "already_r9k_off"
            case alreadyR9KOn = "already_r9k_on"
            case alreadySlowOff = "already_slow_off"
            case alreadySlowOn = "already_slow_on"
            case alreadySubsOff = "already_subs_off"
            case alreadySubsOn = "already_subs_on"
            case autohostReceived = "autohost_receive"
            case cannotBanAdmin = "bad_ban_admin"
            case cannotBanAnonymous = "bad_ban_anon"
            case cannotBanBroadcaster = "bad_ban_broadcaster"
            case cannotBanModerator = "bad_ban_mod"
            case cannotBanYourself = "bad_ban_self"
            case cannotBanStaff = "bad_ban_staff"
            case cannotStartCommercial = "bad_commercial_error"
            case cannotDeleteBroadcasterMessage = "bad_delete_message_broadcaster"
            case cannotDeleteModeratorMessage = "bad_delete_message_mod"
            case cannotHostChannel = "bad_host_error"
            case alreadyHostingChannel = "bad_host_hosting"
            case hostRateExceeded = "bad_host_rate_exceeded"
            case unableToHost = "bad_host_rejected"
            case cannotHostYourself = "bad_host_self"
            case cannotModBanned = "bad_mod_banned"
            case userIsAlreadyMod = "bad_mod_mod"
            case invalidSlowDuration = "bad_slow_duration"
            case cannotTimoutAdmin = "bad_timeout_admin"
            case cannotTimeoutAnonymous = "bad_timeout_anon"
            case cannotTimeoutBroadcaster = "bad_timeout_broadcaster"
            case invalidTimoutDuration = "bad_timeout_duration"
            case cannotTimeoutModerator = "bad_timeout_mod"
            case cannotTimeoutYourself = "bad_timeout_self"
            case cannotTimeoutStaff = "bad_timeout_staff"
            case userIsNotBanned = "bad_unban_no_ban"
            case cannotUnhost = "bad_unhost_error"
            case userIsNotModerator = "bad_unmod_mod"
            case cannotVipBanned = "bad_vip_grantee_banned"
            case userIsAlreadyVip = "bad_vip_grantee_already_vip"
            case maxVipsReached = "bad_vip_max_vips_reached"
            case vipsNotAvailable = "bad_vip_achievement_incomplete"
            case userIsNotVip = "bad_unvip_grantee_not_vip"
            case banSuccessful = "ban_success"
            case listOfCommandsReceived = "cmds_available"
            case userColorChanged = "color_changed"
            case commercialSuccessful = "commercial_success"
            case deleteMessageSuccessful = "delete_message_success"
            case deleteStaffMessageSuccessful = "delete_staff_message_success"
            case emoteOnlyOff = "emote_only_off"
            case emoteOnlyOn = "emote_only_on"
            case followersOff = "followers_off"
            case followersOn = "followers_on"
            case followersOnNoDuration = "followers_on_zero"
            case hostOff = "host_off"
            case hostOn = "host_on"
            case hostReceived = "host_receive"
            case hostReceivedNoCount = "host_receive_no_count"
            case hostTargetWentOffline = "host_target_went_offline"
            case hostLimitRemaining = "hosts_remaining"
            case invalidUser = "invalid_user"
            case modSuccessful = "mod_success"
            case messageBanned = "msg_banned"
            case invalidMessageCharacters = "msg_bad_characters"
            case messageBlocked = "msg_channel_blocked"
            case channelSuspended = "msg_channel_suspended"
            case messageDuplicate = "msg_duplicate"
            case messageEmoteOnly = "msg_emoteonly"
            case messageFollowersOnly = "msg_followersonly"
            case messageFollowersOnlyWaiting = "msg_followersonly_followed"
            case messageFollowersOnlyZero = "msg_followersonly_zero"
            case messageNotUnique = "msg_r9k"
            case messageRateLimitReached = "msg_ratelimit"
            case messageRejectedByMods = "msg_rejected"
            case messageRejectedByRules = "msg_rejected_mandatory"
            case verifiedPhoneNumberRequired = "msg_requires_verified_phone_number"
            case messageSlowmode = "msg_slowmode"
            case messageSubmode = "msg_subsonly"
            case messageNoPermission = "msg_suspended"
            case messageTimeout = "msg_timedout"
            case verifiedEmailRequired = "msg_verified_email"
            case noMods = "no_mods"
            case noVips = "no_vips"
            case notHosting = "not_hosting"
            case noPermission = "no_permission"
            case uniqueModeOn = "r9k_off"
            case uniqueModeOff = "r9k_on"
            case raidAlreadyHappening = "raid_error_already_raiding"
            case raidForbidden = "raid_error_forbidden"
            case cannotRaidYourself = "raid_error_self"
            case raidTooManyViewers = "raid_error_too_many_viewers"
            case raidUnexpectedError = "raid_error_unexpected"
            case raidNoticeMature = "raid_notice_mature"
            case raidNoticeRestricted = "raid_notice_restricted_chat"
            case listOfModsReceived = "room_mods"
            case slowOff = "slow_off"
            case slowOn = "slow_on"
            case subsOff = "subs_off"
            case subsOn = "subs_on"
            case timeoutNotFound = "timeout_no_timeout"
            case timeoutSuccessful = "timeout_success"
            case suspendedDueToTos = "tos_ban"
            case cannotSetColorIfNotTurbo = "turbo_only_color"
            case unavailableCommand = "unavailable_command"
            case unbanSuccessful = "unban_success"
            case unmodSuccessful = "unmod_success"
            case unraidNoActiveRaid = "unraid_error_no_active_raid"
            case unraidUnexpectedError = "unraid_error_unexpected"
            case unraidSuccessful = "unraid_success"
            case unrecognizedCommand = "unrecognized_cmd"
            case cannotUntimeoutBanned = "untimeout_banned"
            case untimoutSuccessful = "untimeout_success"
            case unvipSuccessful = "unvip_success"
            case usageBan = "usage_ban"
            case usageClear = "usage_clear"
            case usageColor = "usage_color"
            case usageCommercial = "usage_commercial"
            case usageDisconnect = "usage_disconnect"
            case usageDelete = "usage_delete"
            case usageEmoteOnlyOff = "usage_emote_only_off"
            case usageEmoteOnlyOn = "usage_emote_only_on"
            case usageFollowersOff = "usage_followers_off"
            case usageFollowersOn = "usage_followers_on"
            case usageHelp = "usage_help"
            case usageHost = "usage_host"
            case usageMarker = "usage_marker"
            case usageMe = "usage_me"
            case usageMod = "usage_mod"
            case usageMods = "usage_mods"
            case usageUniqueOff = "usage_r9k_off"
            case usageUniqueOn = "usage_r9k_on"
            case usageRaid = "usage_raid"
            case usageSlowOff = "usage_slow_off"
            case usageSlowOn = "usage_slow_on"
            case usageSubsOff = "usage_subs_off"
            case usageSubsOn = "usage_subs_on"
            case usageTimout = "usage_timeout"
            case usageUnban = "usage_unban"
            case usageUnhost = "usage_unhost"
            case usageUnmod = "usage_unmod"
            case usageUnraid = "usage_unraid"
            case usageUntimeout = "usage_untimeout"
            case usageUnvip = "usage_unvip"
            case usageUser = "usage_user"
            case usageVip = "usage_vip"
            case usageVips = "usage_vips"
            case usageWhisper = "usage_whisper"
            case vipSuccessful = "vip_success"
            case vipsSuccessful = "vips_success"
            case bannedFromWhispers = "whisper_banned"
            case cannotWhisperBanned = "whisper_banned_recipient"
            case cannotWhisperUnknown = "whisper_invalid_login"
            case cannotWhisperYourself = "whisper_invalid_self"
            case whisperLimitPerMinuteReached = "whisper_limit_per_min"
            case whisperLimitPerSecondReached = "whisper_limit_per_sec"
            case whisperNotSentDueToSettings = "whisper_restricted"
            case whisperRecipientRestrictedSettings = "whisper_restricted_recipient"
        }
    }
}
