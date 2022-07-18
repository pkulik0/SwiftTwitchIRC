import Foundation

public struct SwiftTwitchIRC {
    var username: String
    var token: String
    
    var session: URLSession
    var connection: URLSessionStreamTask
    
    let host = "irc.chat.twitch.tv"
    let port = 6667
    
    var shouldContinue = true
    
    public init(username: String, token: String, session: URLSession = URLSession.shared) {
        self.username = username
        self.token = token
        
        self.session = session
        self.connection = session.streamTask(withHostName: host, port: port)
        connection.resume()
        
        read()
        join()
    }
    
    mutating func leave() {
        connection.cancel()
    }
    
    func read() {
        connection.readData(ofMinLength: 0, maxLength: 100000, timeout: 0) { data, isEOF, error in
            guard let data = data, let message = String(data: data, encoding: .utf8) else {
                return
            }
            
            for line in message.split(separator: "\r\n") {
                print(line)
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
    
    func join() {
        send(message: "PASS oauth:\(token)")
        send(message: "NICK \(username)")
        send(message: "CAP REQ :twitch.tv/commands twitch.tv/tags")
        send(message: "JOIN #adamcy_")
    }
}
