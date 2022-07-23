//
//  TwitchIRC.swift
//
//
//  Created by pkulik0 on 18/07/2022.
//

import Foundation

@available(macOS 10.15, iOS 13.0, *)
public class SwiftTwitchIRC {
    var username: String
    var token: String
    
    var session: URLSession
    var connection: URLSessionStreamTask
    
    let host = "irc.chat.twitch.tv"
    let port = 6697
    
    var chatrooms: Set<String> = []
    var buffer: String = ""
    
    var onMessageReceived: ((ChatMessage) -> Void)?
    var onWhisperReceived: ((WhisperMessage) -> Void)?
    
    var onNoticeReceived: ((Notice) -> Void)?
    var onUserEvent: ((UserEvent) -> Void)?
    
    var onUserStateChanged: ((UserState) -> Void)?
    var onRoomStateChanged: ((RoomState) -> Void)?
    
    var onClearChat: ((ClearChat) -> Void)?
    var onClearMessage: ((ClearMessage) -> Void)?
    
    public init(
        username: String,
        token: String,
        session: URLSession = URLSession.shared,
        onMessageReceived: ((ChatMessage) -> Void)? = nil,
        onWhisperReceived: ((WhisperMessage) -> Void)? = nil,
        onNoticeReceived: ((Notice) -> Void)? = nil,
        onUserEvent: ((UserEvent) -> Void)? = nil,
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
        self.onUserEvent = onUserEvent
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
            startWorker()
        }

        send("PASS oauth:\(token)")
        send("NICK \(username)")
        send("CAP REQ :twitch.tv/commands twitch.tv/tags")
        joinChatroom(username)
    }
    
    private func startWorker() {
        while true {
            guard let index = buffer.firstIndex(of: "\r\n") else {
                usleep(100000)
                continue
            }
            
            let line = String(buffer[..<index])
            buffer = String(buffer[buffer.index(after: index)...])
            
            if line.starts(with: "PING") {
                send(line.replacingOccurrences(of: "PING", with: "PONG"))
                continue
            }
            parseMessage(line)
        }
    }
    
    private func read() {
        connection.readData(ofMinLength: 0, maxLength: 65535, timeout: 0) { [self] data, isEOF, error in
            if error != nil {
                return
            }
            
            guard let data = data, let message = String(data: data, encoding: .utf8) else {
                return
            }
            
            buffer += message
            read()
        }
    }
    
    private func send(_ message: String) {
        print("send: \(message)")
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
