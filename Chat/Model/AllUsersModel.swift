//
//  AllUsersModel.swift
//  Chat
//
//  Created by Geetika on 23/05/23.
//

import Foundation

//struct Users {
//    var name: String = ""
//    var email: String = ""
//    var uid: String = ""
//    var profilePicUrl: String = ""
//
//    init(json: [String: Any]) {
//        name = json[Keys.name] as? String ?? ""
//        email = json[Keys.email] as? String ?? ""
//        uid = json[Keys.userid] as? String ?? ""
//        profilePicUrl = json[Keys.profilePicUrl] as? String ?? ""
//    }
//}




struct UserDetail: Codable{
    var name: String?
    var email: String?
    var uid: String?
    var profilePicUrl: String?
    var about: String?
   
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.email = try container.decodeIfPresent(String.self, forKey: .email)
        self.uid = try container.decodeIfPresent(String.self, forKey: .uid)
        self.profilePicUrl = try container.decodeIfPresent(String.self, forKey: .profilePicUrl)
        self.about = try container.decodeIfPresent(String.self, forKey: .about)

    }
}





