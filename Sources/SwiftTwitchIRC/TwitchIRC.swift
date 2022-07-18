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
        joinChannel(channel: "adamcy_")
    }
    
    mutating func disconnect() {
        connection.cancel()
    }
    
    func read() {
        connection.readData(ofMinLength: 0, maxLength: 100000, timeout: 0) { data, isEOF, error in
            guard let data = data, let message = String(data: data, encoding: .utf8) else {
                return
            }
            
            for line in message.split(separator: "\r\n") {
                if let messageData = parseData(message: String(line)) {
                    onMessageReceived(messageData)
                }
            }
            read()
        }
    }
    
    func send(message: String) {
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
    
    func connect() {
        send(message: "PASS oauth:\(token)")
        send(message: "NICK \(username)")
        send(message: "CAP REQ :twitch.tv/commands twitch.tv/tags")
    }
    
    mutating func joinChannel(channel: String) {
        send(message: "JOIN #\(channel)")
        chatrooms.append(channel)
    }
    
    mutating func leaveChannel(channel: String) {
        send(message: "PART #\(channel)")
        chatrooms.removeAll(where: { $0 == channel })
    }
}
