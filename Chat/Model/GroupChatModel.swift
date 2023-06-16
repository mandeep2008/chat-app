//
//  GroupChatModel.swift
//  Chat
//
//  Created by Geetika on 16/06/23.
//

import Foundation

struct GroupChat: Codable{
    var groupDetails: GroupDetails?
    var participants:[Participants]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.groupDetails = try container.decodeIfPresent(GroupDetails.self, forKey: .groupDetails)
        self.participants = try container.decodeIfPresent([Participants].self, forKey: .participants)
    }
}

struct GroupDetails: Codable{
    var adminName: String?
    var adminUid: String?
    var groupIcon: String?
    var groupName: String?
}
struct Participants: Codable{
    var email: String?
    var name: String?
    var uid: String?
}
