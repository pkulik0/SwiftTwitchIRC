//
//  TwitchIRC.swift
//
//
//  Created by pkulik0 on 18/07/2022.
//

import Foundation

@available(macOS 10.15, iOS 13.0, *)
public class SwiftTwitchIRC {
    private var username: String
    private var token: String
    
    private var session: URLSession
    private var connection: URLSessionStreamTask
    
    private let host = "irc.chat.twitch.tv"
    private let port = 6697
    
    private var chatrooms: Set<String> = []
    
    internal var buffer: String = ""
    internal var bufferLock = NSLock()
    
    internal var onMessageReceived: ((ChatMessage) -> Void)?
    internal var onWhisperReceived: ((Whisper) -> Void)?
    
    internal var onNoticeReceived: ((Notice) -> Void)?
    internal var onUserNoticeReceived: ((UserNotice) -> Void)?
    
    internal var onUserStateChanged: ((UserState) -> Void)?
    internal var onRoomStateChanged: ((RoomState) -> Void)?
    
    internal var onClearChat: ((ClearChat) -> Void)?
    internal var onClearMessage: ((ClearMessage) -> Void)?
    
    public init(
        username: String,
        token: String,
        session: URLSession = URLSession.shared,
        onMessageReceived: ((ChatMessage) -> Void)? = nil,
        onWhisperReceived: ((Whisper) -> Void)? = nil,
        onNoticeReceived: ((Notice) -> Void)? = nil,
        onUserNoticeReceived: ((UserNotice) -> Void)? = nil,
        onUserStateChanged: ((UserState) -> Void)? = nil,
        onRoomStateChanged: ((RoomState) -> Void)? = nil,
        onClearChat: ((ClearChat) -> Void)? = nil,
        onClearMessage: ((ClearMessage) -> Void)? = nil
    ) {
        self.username = username
        self.token = token
        
        self.onMessageReceived = onMessageReceived
        self.onWhisperReceived = onWhisperReceived
        self.onNoticeReceived = onNoticeReceived
        self.onUserNoticeReceived = onUserNoticeReceived
        self.onUserStateChanged = onUserStateChanged
        self.onRoomStateChanged = onRoomStateChanged
        self.onClearChat = onClearChat
        self.onClearMessage = onClearMessage
        self.session = session
        
        self.connection = session.streamTask(withHostName: host, port: port)
        connection.startSecureConnection()
        
        connect()
        read()
    }

    private func connect() {
        connection.resume()
        Task {
            startParser()
        }

        send("CAP REQ :twitch.tv/commands twitch.tv/tags")
        send("PASS oauth:\(token)")
        send("NICK \(username)")
        
        joinChatroom(username)
    }
    
    private func read() {
        connection.readData(ofMinLength: 0, maxLength: 65535, timeout: 0) { [self] data, isEOF, error in
            if error != nil {
                return
            }
            
            guard let data = data, let message = String(data: data, encoding: .utf8) else {
                return
            }
            
            bufferLock.lock()
            buffer += message
            bufferLock.unlock()
            
            read()
        }
    }
    
    internal func send(_ message: String) {
        guard let data = "\(message)\r\n".data(using: .utf8) else {
            return
        }
        
        connection.write(data, timeout: 0) { error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
    }
    
    public func sendMessage(message: String, channel: String) {
        send("PRIVMSG #\(channel) :\(message)")
    }
    
    public func sendReply(to replyParent: ChatMessage, message: String) {
        send("@reply-parent-msg-id=\(replyParent.id) PRIVMSG #\(replyParent.chatroom) :\(message)")
    }
    
    public func sendWhisper(message: String, to userName: String) {
        send("PRIVMSG #\(userName) :/w \(userName) \(message)")
    }
    
    public func joinChatroom(_ name: String) {
        send("JOIN #\(name)")
        chatrooms.insert(name)
    }
    
    public func joinChatrooms(_ names: Set<String>) {
        names.forEach({ joinChatroom($0) })
    }
    
    public func leaveChatroom(_ name: String) {
        send("PART #\(name)")
        chatrooms.remove(name)
    }
    
    public func leaveChatrooms(_ names: Set<String>) {
        names.forEach({ leaveChatroom($0) })
    }
}
