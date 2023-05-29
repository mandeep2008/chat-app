//
//  AllUsersModel.swift
//  Chat
//
//  Created by Geetika on 23/05/23.
//

import Foundation


//struct AllUsersModel{
//    let user: [UserId]?
//}
//struct UserId{
//    let userId : UserDetail?
//}
//struct UserDetail{
//    let email, name, profilePicUrl, uid : String?
//}

//struct User{
//    var userList : UserDetail?
//    init(users: [String: Any]){
//        userList = UserDetail(json: users["userList"] as? [String: Any] ?? [:])
//    }
//}

struct Users {
    var name: String = ""
    var email: String = ""
    var uid: String = ""
    var profilePicUrl: String = ""

    init(json: [String: Any]) {
        name = json[Keys.name] as? String ?? ""
        email = json[Keys.email] as? String ?? ""
        uid = json[Keys.userid] as? String ?? ""
        profilePicUrl = json[Keys.profilePicUrl] as? String ?? ""
    }
}


struct AllUsers: Codable{
    var name: String?
    var email: String?
    var uid: String?
    var profilePicUrl: String?
}



