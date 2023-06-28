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
        groupDetail[Keys.groupId] = key
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
            
            completion(data)
        })
    }
        
  
    
    func deleteParticipant(groupId: String, completion: @escaping(_ isDeleted: Bool)-> Void){
        
        self.ref.child(Keys.groupChat).child(groupId).child(Keys.participants).child(auth.currentUser?.uid ?? "").removeValue(completionBlock: { error, deleted in
            completion(true)
            
        } )
    }
    func accessGroupDetailsAndParticipants(groupData: [String: Any], conversationId: String, completion: @escaping(_ groupDetails: [String: Any], _ participants: [UserDetail])-> Void){
        var groupParticipants = [[String: Any]]()
        var groupDetails = [String: Any]()
        for i in groupData.values{
            let valueDict = i as? [String: Any]
            groupDetails = (valueDict?[Keys.groupDetail] as? [String: Any])!
            let participantsList = (valueDict?[Keys.participants] as? [String: Any])!
            
           
            if groupDetails[Keys.groupId] as? String == conversationId{
                for (_,value) in participantsList{
                    groupParticipants.append((value as? [String: Any])!)
                }
                
                dataParsing.decodeData(response: groupParticipants, model: [UserDetail].self){ participants in
                    completion(groupDetails,participants as! [UserDetail])

                }
               
            }
        }
      
    }
    
    
    func updateParticipantsList(updatedParticipants: [[String: Any]], conversationId: String, completion: @escaping(_ isUpdated: Bool)-> Void){
        for i in updatedParticipants{
            self.ref.child(Keys.groupChat).child(conversationId).child(Keys.participants).child(i[Keys.userid] as! String).setValue(i, withCompletionBlock: { error, updated in
                completion(true)
            })
        }
    }
    
    
    func convertSelectUserObjectToDictionary(selectedUserList: [UserDetail]) -> [[String: Any]]{
        var participants = [[String: Any]]()
        var dict = [String: Any]()
        
        for i in selectedUserList{
            dict[Keys.name] = i.name
            dict[Keys.email] = i.email
            dict[Keys.userid] = i.uid
            dict[Keys.profilePicUrl] = i.profilePicUrl
            participants.append(dict)
            
        }
        return participants
    }
    
}

