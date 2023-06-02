//
//  ChatModel.swift
//  Chat
//
//  Created by Geetika on 26/05/23.
//

import Foundation

struct MessageModel: Codable{
    var senderId: String?
    var receiverId: String?
    var sendBy: String?
    var sendTo: String?
    var message: String?
    var messageTime: Int64?
    var msgId: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.senderId = try container.decodeIfPresent(String.self, forKey: .senderId)
        self.receiverId = try container.decodeIfPresent(String.self, forKey: .receiverId)
        self.sendBy = try container.decodeIfPresent(String.self, forKey: .sendBy)
        self.sendTo = try container.decodeIfPresent(String.self, forKey: .sendTo)
        self.message = try container.decodeIfPresent(String.self, forKey: .message)
        self.messageTime = try container.decodeIfPresent(Int64.self, forKey: .messageTime)
        self.msgId = try container.decodeIfPresent(String.self, forKey: .msgId)
    }
}
