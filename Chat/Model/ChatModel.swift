//
//  ChatModel.swift
//  Chat
//
//  Created by Geetika on 26/05/23.
//

import Foundation

struct ChatModel{
    var senderId = ""
    var receiverId = ""
    var sendBy = ""
    var sendTo = ""
    var message = ""
 //   var msgId = ""
    var messageTime: Int64 = 0
    
    init(chatData: [String: Any]){
        senderId = chatData[Keys.senderId] as? String ?? ""
        receiverId = chatData[Keys.receiverId] as? String ?? ""
        sendBy = chatData[Keys.sendBy] as? String ?? ""
        sendTo = chatData[Keys.sendTo] as? String ?? ""
        message = chatData[Keys.message] as? String ?? ""
      //  msgId = chatData[Keys.msgId] as? String ?? ""
        messageTime = chatData[Keys.messageTime] as? Int64 ?? 0



    }
    
}
