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
    static let about = "about"
    
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
    static let logoutAlertMessage =  "Do you want to logout"
    static let alertMessage = "Do you want to delete this chat?"
    static let messageDeleted = "Message Deleted"
    static let addTitleAlertMessage = "please add title for your group"
    static let exitGroupAlert =  "Do you want to leave this group? if you will exit this group it will also remove from your conversations."
    
    
    // GroupChat Keys
    static let groupId = "groupId"
    static let adminUid = "adminUid"
    static let groupIcon = "groupIcon"
    static let adminName = "adminName"
    static let groupName = "groupName"
    static let groupDetail = "GroupDetails"
    static let participants = "Participants"
    static let group = "group"
    static let next = "Next"
    
    
    // image/icon name
    static let personWithCircle = "person.circle"
    static let  twoPersonImage = "person.2.circle.fill"
    static let circleInsetFilled = "circle.inset.filled"
    static let personWithPlus = "person.crop.circle.badge.plus"
    static let circle = "circle"
    static let trash = "trash"
}
