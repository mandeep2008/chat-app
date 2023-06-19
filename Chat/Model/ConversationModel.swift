//
//  ConversationModel.swift
//  Chat
//
//  Created by Geetika on 23/05/23.
//

import Foundation

struct Conversations: Codable{
    var conversationId: String?
    var name: String?
    var uid : String?
    var profilePicUrl: String?
    var lastMessage : String?
    var messageTime: Int64?
    var chatType: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.conversationId = try container.decodeIfPresent(String.self, forKey: .conversationId)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid)
        self.profilePicUrl = try container.decodeIfPresent(String.self, forKey: .profilePicUrl)
        self.lastMessage = try container.decodeIfPresent(String.self, forKey: .lastMessage)
        self.messageTime = try container.decodeIfPresent(Int64.self, forKey: .messageTime)
        self.chatType = try container.decodeIfPresent(String.self, forKey: .chatType)

    }
}


