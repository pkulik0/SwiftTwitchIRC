//
//  Protocols.swift
//  
//
//  Created by pkulik0 on 19/07/2022.
//

@available(macOS 10.15, iOS 13.0, *)
protocol IRCMessage: Identifiable, Hashable, Codable {
    var id: String { get set }
}

@available(macOS 10.15, iOS 13.0, *)
protocol IRCUserInfo: Identifiable, Hashable, Codable {
    var userName: String { get set }
    var badges: [String: String] { get set }
    var color: String { get set }
}
