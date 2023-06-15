//
//  GroupChatManager.swift
//  Chat
//
//  Created by Geetika on 15/06/23.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase

class GroupChatManager{
    static let shared = GroupChatManager()
    
    var ref = Database.database().reference()
    let auth = Auth.auth()
    
    //MARK: create group
    func createGroup(groupDetail: inout [String:Any],
                    participants: inout [[String: Any]],
                     completion: @escaping (_ groupCreated : Bool)-> Void)
    {
        let currentLoginUserDict = ["name": UserDefaults.standard.string(forKey: Keys.name),
                                    "email": auth.currentUser?.email,
                                    "uid": auth.currentUser?.uid,
                                    "profilePicUrl": UserDefaults.standard.string(forKey: Keys.profilePicUrl)]
        participants.append(currentLoginUserDict)
        let groupRef = self.ref.child("GroupChat").childByAutoId()
        
        groupDetail["adminUid"] = self.auth.currentUser?.uid
        groupRef.child("GroupDetails").setValue(groupDetail)
        
        for i in participants{
            groupRef.child("Participants").child(i["uid"] as! String).setValue(i)
        }
        readGroups()
        print("saved")
        completion(true)
    }
    
    //MARK: read groups list
    func readGroups(){
        self.ref.child("GroupChat").observeSingleEvent(of: .value, with: {snapshot in
            print(snapshot)
        })
    }
    
    
    func addGroupInConverstaions(){
        
    }
}
