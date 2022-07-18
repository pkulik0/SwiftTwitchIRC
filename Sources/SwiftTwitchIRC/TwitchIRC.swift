//
//  TwitchIRC.swift
//
//
//  Created by pkulik0 on 18/07/2022.
//

import Foundation

public struct SwiftTwitchIRC {
    var username: String
    var token: String
    
    var session: URLSession
    var connection: URLSessionStreamTask
    
    let onMessageReceived: (ChatMessage) -> Void
    
    let host = "irc.chat.twitch.tv"
    let port = 6667
    
    private var chatrooms: [String] = []
    
    public init(username: String, token: String, session: URLSession = URLSession.shared, onMessageReceived: @escaping (ChatMessage) -> Void) {
        self.username = username
        self.token = token
        
        self.onMessageReceived = onMessageReceived
        
        self.session = session
        self.connection = session.streamTask(withHostName: host, port: port)
        connection.resume()
        
        read()
        connect()
        joinChannel(channel: username)
    }
    
    mutating public func disconnect() {
        connection.cancel()
    }
    
    func read() {
        connection.readData(ofMinLength: 0, maxLength: 100000, timeout: 0) { data, isEOF, error in
            guard let data = data, let message = String(data: data, encoding: .utf8) else {
                return
            }
            
            for line in message.split(separator: "\r\n") {
                if line.contains("PING") {
                    send(line.replacingOccurrences(of: "PING", with: "PONG"))
                    return
                }
                
                if let messageData = parseData(message: String(line)) {
                    onMessageReceived(messageData)
                }
            }
            read()
        }
    }
    
    func send(_ message: String) {
        guard let data = "\(message)\r\n".data(using: .utf8) else {
            return
        }
        
        connection.write(data, timeout: 0) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("Sent: \(message)")
            }
        }
    }
    
    public func sendMessage(message: String, channel: String) {
        send("PRIVMSG #\(channel) :\(message)")
    }
    
    public func sendReply(to messageID: String, message: String, channel: String) {
        send("@reply-parent-msg-id=\(messageID) PRIVMSG #\(channel) :\(message)")
    }
    
    public func sendWhisper(message: String, to userName: String) {
        send("PRIVMSG #\(userName) :/w \(userName) \(message)")
    }
    
    func connect() {
        send("PASS oauth:\(token)")
        send("NICK \(username)")
        send("CAP REQ :twitch.tv/commands twitch.tv/tags")
    }
    
    mutating public func joinChannel(channel: String) {
        send("JOIN #\(channel)")
        chatrooms.append(channel)
    }
    
    mutating public  func leaveChannel(channel: String) {
        send("PART #\(channel)")
        chatrooms.removeAll(where: { $0 == channel })
    }
}
