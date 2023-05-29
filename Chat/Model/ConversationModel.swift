//
//  ConversationModel.swift
//  Chat
//
//  Created by Geetika on 23/05/23.
//

import Foundation


//struct ConversationModel: Codable{
//    let conversations: [ConversationId]?
//}
//
//struct ConversationId: Codable{
//    let converstaionId: ConversationDetail?
//}
//
//struct ConversationDetail: Codable{
//    let lastMessage: String?
//    let messageTime: Int64?
//}


struct ConversationDetail{
    var conversationId = ""
    var name = ""
    var uid = ""
    var profilePicUrl = ""
    var lastMessage = ""
    var messageTime: Int64 = 0
    
    init(conversationData: [String: Any]){
        conversationId = conversationData[Keys.conversationId] as? String ?? ""
        name = conversationData[Keys.name] as? String ?? ""
        uid = conversationData[Keys.userid] as? String ?? ""
        profilePicUrl = conversationData[Keys.profilePicUrl] as? String ?? ""
        lastMessage = conversationData[Keys.lastMessage] as? String ?? ""
        messageTime = conversationData[Keys.messageTime] as? Int64 ?? 0
        
    }
}

