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
    let dataParsing = DataParsing()
    
    //MARK: create group
    func createGroup(groupDetail: inout [String:Any],
                    participants: inout [[String: Any]],
                     completion: @escaping (_ groupId : String)-> Void)
    {
        let currentLoginUserDict = [Keys.name: UserDefaults.standard.string(forKey: Keys.name),
                                    Keys.email: auth.currentUser?.email,
                                    Keys.userid: auth.currentUser?.uid,
                                    Keys.profilePicUrl: UserDefaults.standard.string(forKey: Keys.profilePicUrl)]
        participants.append(currentLoginUserDict as [String: Any])
    
        let key = self.ref.child(Keys.groupChat).childByAutoId().key // access auto id 
        
        groupDetail[Keys.adminUid] = self.auth.currentUser?.uid
        self.ref.child(Keys.groupChat).child(key ?? "").child(Keys.groupDetail).setValue(groupDetail)
        
        for i in participants{
            self.ref.child(Keys.groupChat).child(key ?? "").child(Keys.participants).child(i[Keys.userid] as! String).setValue(i)
        }
        completion(key ?? "")
        print("saved")
    }
    
    //MARK: read groups list
    func readGroups(completion: @escaping(_ groupsData: [String: Any])-> Void){
        self.ref.child(Keys.groupChat).observeSingleEvent(of: .value, with: {snapshot in
            guard let data = snapshot.value as? [String: Any] else {
                return
            }
            print(data)
            let groupsData = data
            var participantsData = [[String: Any]]()
            for i in snapshot.children{
                let childSnap = i as! DataSnapshot
            
                let participantsSnap = childSnap.childSnapshot(forPath: "Participants")
                
                let groupDetailsnap = childSnap.childSnapshot(forPath: "GroupDetails")
                        for groupChild in participantsSnap.children {
                            let snap = groupChild as! DataSnapshot
                            let dict = snap.value as! [String: Any]
                            participantsData.append(dict)
                        }
            }
            completion(groupsData)
        })
    }
    
}

