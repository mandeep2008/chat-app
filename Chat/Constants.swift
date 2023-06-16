//
//  constants.swift
//  Chat
//
//  Created by Geetika on 22/05/23.
//

import Foundation
import UIKit

class Keys {
    // keys for user details
    static let email = "email"
    static let name = "name"
    static let profilePicUrl = "profilePicUrl"
    static let userid = "uid"
    static let isLoggedIn = "isLoggedIn"
    static let defaults = "defaults"
    
    // database name
    static let users = "Users"
    static let chats = "Chats"
    static let conversations = "Conversations"
    static let groupChat = "GroupChat"

    // chat keys
    static let senderId = "senderId"
    static let receiverId = "receiverId"
    static let conversationId = "conversationId"
    static let message = "message"
    static let messageTime = "messageTime"
    static let msgId = "msgId"
    static let sendBy = "sendBy"
    static let sendTo = "SendTo"
    static let deletedByOther = "deletedByOther"
    static let lastMessage = "lastMessage"
    static let timeFormat = "hh:mm a"
    static let chatType = "chatType"
    
    
    // alert strings
    static let cancel = "Cancel"
    static let delete = "Delete"
    static let ok = "OK"
    static let alertMessage = "Do you want to delete this chat?"
    static let messageDeleted = "Message Deleted"
    
    // GroupChat Keys
    
    static let adminUid = "adminUid"
    static let groupIcon = "groupIcon"
    static let adminName = "adminName"
    static let groupName = "groupName"
    static let groupDetail = "GroupDetails"
    static let participants = "Participants"
    static let group = "group"
    
    // image/icon name
    static let personWithCircle = "person.circle"
    static let circleInsetFilled = "circle.inset.filled"
    static let circle = "circle"
}
