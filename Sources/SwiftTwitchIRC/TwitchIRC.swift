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
    let port = 6667
    
    var chatrooms: [String] = []
    var buffer: String = ""
    
    var onMessageReceived: ((ChatMessage) -> Void)?
    var onWhisperReceived: ((WhisperMessage) -> Void)?
    
    var onNoticeReceived: ((Notice) -> Void)?
    var onUserEvent: ((UserEvent) -> Void)?
    
    var onUserStateChanged: ((UserState) -> Void)?
    var onRoomStateChanged: ((RoomState) -> Void)?
    
    var onClearChat: ((ClearChat) -> Void)?
    var onClearMessage: ((ClearMessage) -> Void)?
    
    var onHostStarted: ((HostInfo) -> Void)?
    
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
        onClearMessage: ((ClearMessage) -> Void)? = nil,
        onHostStarted: ((HostInfo) -> Void)? = nil
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
        self.onHostStarted = onHostStarted
        
        self.session = session
        self.connection = session.streamTask(withHostName: host, port: port)
        
        startParsingWorker()
        
        read()
        connect()
        joinChannel(channel: username)
    }
    
    func connect() {
        send("PASS oauth:\(token)")
        send("NICK \(username)")
        send("CAP REQ :twitch.tv/commands twitch.tv/tags")
    }
    
    public func disconnect() {
        connection.cancel()
    }
    
    func startParsingWorker() {
        Task {
            while true {
                guard let range = buffer.range(of: "\r\n") else {
                    usleep(1000)
                    continue
                }
                let line = buffer[..<range.lowerBound]
                buffer = String(buffer[range.upperBound...])
                
                if line.contains("PING") {
                    send(line.replacingOccurrences(of: "PING", with: "PONG"))
                    continue
                }
                parseData(message: String(line))
            }
        }
    }
    
    func read() {
        connection.resume()
        
        connection.readData(ofMinLength: 0, maxLength: 9999, timeout: 0) { [self] data, isEOF, error in
            defer { read() }
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data, let message = String(data: data, encoding: .utf8) else {
                return
            }
            buffer += message
        }
    }
    
    func send(_ message: String) {
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
    
    public func joinChannel(channel: String) {
        send("JOIN #\(channel)")
        chatrooms.append(channel)
    }
    
    public func leaveChannel(channel: String) {
        send("PART #\(channel)")
        chatrooms.removeAll(where: { $0 == channel })
    }
}
