//
//  Manager.swift
//  Chat
//
//  Created by Geetika on 09/05/23.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase


class Manager{
    static let shared = Manager()
    var ref = Database.database().reference()
    let auth = Auth.auth()
    let dataParsing = DataParsing()
    
    //MARK: SignUp user
    func signup(email: String,
                password: String,
                name : String,
                profileUrl: String,
                completion: @escaping (_ success: Bool)-> Void){
        
        auth.createUser(withEmail: email, password: password){ result, error in
            guard let result = result?.user  else {
                return
            }
            let id = result.uid
                let email = result.email
            let dict = [Keys.userid :id,
                        Keys.email:email ?? "",
                        Keys.name: name ,
                        Keys.profilePicUrl: profileUrl]
            self.saveUser(userId: id, userDict: dict){userSaved in
                if userSaved{

                    completion(true)
                    
                }
            }
            
        }
    }
    
    //MARK: save user data in firebase
    
    func saveUser(userId: String,
                  userDict: [String: Any],
                  completion: @escaping (_ userSaved : Bool)-> Void){
        self.ref.child(Keys.users).child(userId).setValue(userDict)
        completion(true)
    }
    
    //MARK: Login
    
    func login(email: String, password: String, completion: @escaping (_ success: Bool)-> Void){
        auth.signIn(withEmail: email, password: password){ result, error in
            guard let result = result?.user else{
                return
            }
            //MARK: userdefault data
            let userDict = [Keys.userid: result.uid, Keys.email: result.email ?? "", Keys.isLoggedIn: true]
            UserDefaults.standard.set(userDict, forKey: Keys.defaults)
                completion(true)
        }
    }
    
    
    //MARK: sign out
    
    func signout(){
        do {
            try auth.signOut()
        } catch let signOutError {
            print(signOutError.localizedDescription)
        }
    }
    
   
    //MARK: get list of all users
    func getUserList(completion:@escaping (_ data: [UserDetail])-> Void){
        
        self.ref.child(Keys.users).getData(completion:  {  error, result in
            guard let values = result?.value, let usersList = values as? [String: Any]  else {
                print(error?.localizedDescription as Any)
                return
            }
            var userListValues = [[String: Any]]()

            usersList.values.forEach({ i in
                let dict = i as? [String: Any]
                if (dict?[Keys.userid] as? String ?? "") != (self.auth.currentUser?.uid as? String ?? ""){
                    userListValues.append(dict ?? [:])
                }
                else
                {
                    GlobalData.shared.userDetail = dict!
                   //  current loogged in user name using for message sendBy and sendTo
                    UserDefaults.standard.set(dict?[Keys.name], forKey: Keys.name)
                    UserDefaults.standard.set(dict?[Keys.profilePicUrl], forKey: Keys.profilePicUrl)
                }
                
            })
            
            self.dataParsing.decodeData(response: userListValues, model: [UserDetail].self){ result in
                guard result as? [UserDetail] != nil else{return}
                let data: [UserDetail] = (result as! [UserDetail]).sorted { $0.name ?? "" < $1.name ?? ""}
                
                completion(data)
            }

        })
    }

    //MARK: get conversations of current login user
    func getConversations(userList: [UserDetail],groupData: [String: Any], completion: @escaping (_ userData: [Conversations])-> Void){
        self.ref.child(Keys.conversations).observe(.value, with: {snapshot in
            if snapshot.exists(){
                if let data = snapshot.value as? [String: Any]{
                    self.saveConversationsDetails(userList: userList, groupData: groupData, snapshotData: data){ userData in
                        
                        // data parsing
                        self.dataParsing.decodeData(response: userData, model: [Conversations].self){ result in
                            guard result as? [Conversations] != nil else{return}
                            completion(result as! [Conversations])
                        }
                        
                    }
                }
            }
        })
    }
    
//MARK: save conversation details from conversations List and user detail from all user list
    func saveConversationsDetails(userList: [UserDetail],groupData: [String: Any],snapshotData: [String: Any], completion: @escaping(_ userData: [[String: Any]])-> Void){
        var userData = [[String: Any]]()

        for (conversationId,value) in snapshotData{
            
            guard let values = value as? [String: Any] else{
              return
            }
           var dict = values
            dict[Keys.conversationId] = conversationId
            if dict[Keys.chatType] != nil && dict[Keys.chatType] as! String == Keys.group{
                for i in groupData.values{
                    let valueDict = i as? [String: Any]
                    let groupDetails = valueDict?[Keys.groupDetail] as? [String: Any]
                    let participantsList = valueDict?[Keys.participants] as? [String: Any]
                    
                    if groupDetails?["groupId"] as! String == conversationId{
                        // check whether group contains loggedin user uid or not
                        let map =  participantsList.map({
                            $0.contains(where: {$0.key == self.auth.currentUser?.uid
                            })
                        })
                        
                        if map == true{
                            dict[Keys.name] = groupDetails?[Keys.groupName]
                            dict[Keys.conversationId] = groupDetails?[Keys.groupId]
                            dict[Keys.profilePicUrl] = groupDetails?[Keys.groupIcon]
                            userData.append(dict)
                        }
                    }
                }
            }
            
            // for single chat
           else if conversationId.contains(self.auth.currentUser?.uid ?? "") {
                
                self.accessUserId(id: conversationId){userId in
                    for i in userList{
                        if i.uid == userId{
                            dict[Keys.name] = i.name
                            dict[Keys.userid] = i.uid
                            dict[Keys.profilePicUrl] = i.profilePicUrl
                            userData.append(dict)
                        }
                    }
                }
            }
        }
    
        userData.sort{
            (($0[Keys.messageTime] as? Int)!) > (($1[Keys.messageTime] as? Int)!)
        }
        completion(userData)
    }
    //MARK: get userId by spliting conversation id
    func accessUserId(id: String, competion: (_ id: String)->Void){
        var userId = ""
        let data = id.components(separatedBy: "_")
        if data[0] != self.auth.currentUser?.uid{
            userId = data[0]
            competion(userId)
        }
        else{
            userId = data[1]
            competion(userId)
        }
    }
    
    
    
    //MARK: get data from database
    func readData(roomId: String, completion: @escaping (_ msgArray: [MessageModel])-> Void){
        var msgArray = [[String: Any]]()
        self.ref.child(Keys.chats).child(roomId).observe(.childAdded, with: {snapshot in
            if var snap = snapshot.value as? [String: Any]{
             snap[Keys.msgId] = snapshot.key
                msgArray.append(snap)
            }
            self.dataParsing.decodeData(response: msgArray, model: [MessageModel].self){ result in
                guard result as? [MessageModel] != nil else{return}
                completion(result as! [MessageModel])
            }
        })

    }
    
    
    //MARK: save message to database
    func saveMsg(roomId: String, msgDict: inout [String: Any]){
        msgDict[Keys.senderId] = self.auth.currentUser?.uid
        self.ref.child(Keys.chats).child(roomId).childByAutoId().setValue(msgDict)
    }
    
    
    //MARK: create converstaion
    func createConversation(roomId: String, conversationDict: [String: Any]){
        self.ref.child(Keys.conversations).child(roomId).setValue(conversationDict)
    }
    
    
    //MARK: check conversation
    func checkconversation(selectedUserId: String, completion: @escaping(_ conversationId : String)-> Void){
        let currentUser = self.auth.currentUser?.uid
        var roomId = ""
        self.ref.child(Keys.conversations).observeSingleEvent(of: .value, with: {snapshot in
            if snapshot.exists(){
                if let data = snapshot.value as? [String: Any]{
                    let chatId = data.keys  
                    for i in chatId{
                        if i.contains(currentUser ?? "") && i.contains(selectedUserId){
                            roomId = i
                            completion(i)
                            return
                        }
                    }
                    if roomId == ""{
                        completion("\(currentUser ?? "")_\(selectedUserId)")
                    }
                }
            }
            else{
                completion("\(currentUser ?? "")_\(selectedUserId)")
            }
            
        })
        
    }
    
    
    //MARK: convert timestemp
    func accessTime(time: Double)-> String{
        let date = Date(timeIntervalSince1970: time / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = Keys.timeFormat
        return(formatter.string(from: date))
    }
    
    //MARK: delete conversations
    func deleteConversation(converstaionId : String, completion: @escaping (_ isDeleted: Bool)-> Void){
        self.ref.child(Keys.chats).child(converstaionId).removeValue(completionBlock: { error , result in
            guard error == nil else{
                print(error?.localizedDescription as Any)
                return
            }
        })
        self.ref.child(Keys.conversations).child(converstaionId).removeValue(completionBlock: { error, databaseRef in
            guard error == nil else{
                return
            }
            completion(true)
        })
        
    }
    
    //MARK: delete message
    func deleteMessage(conversationId: String,selectedMsgArray: [MessageModel]){
        let chatRef =  ref.child(Keys.chats).child(conversationId)
        for message in selectedMsgArray{
            if message.senderId == self.auth.currentUser?.uid {
                chatRef.child(message.msgId ?? "").removeValue(completionBlock: {error, databaseRef in
                    guard error == nil else{
                        return
                    }
                })
            }

        } // for loop end
    }
   
    
    //MARK: update last message in conversations
    
    func updateConversationLastMessage(messageData: MessageModel, conversationId: String){
        let dict = [Keys.lastMessage: messageData.message!, Keys.messageTime: messageData.messageTime!] as [String : Any]
        self.ref.child(Keys.conversations).child(conversationId).updateChildValues(dict)
    }
    
    func updateUserProfile(dict: [String: Any], completion: @escaping ()->()){
        let userId = dict[Keys.userid]
        self.ref.child(Keys.users).child(userId as! String).updateChildValues(dict, withCompletionBlock: {
            error,_ in
            print("changed")
            completion()
        })
    }
    
    
}
























//             GroupChatManager.shared.readGroups(){ data in
//                // access group details and participants list
//                    for i in data.values{
//                        let valueDict = i as? [String: Any]
//
//                        let groupDetails = valueDict?[Keys.groupDetail] as? [String: Any]
//                        let participantsList = valueDict?[Keys.participants] as? [String: Any]
//
//                        // check whether group contains loggedin user uid or not
//                      let map =  participantsList.map({
//                            $0.contains(where: {$0.key == self.auth.currentUser?.uid
//                          })
//                        })
//
//                        if map == true{
//                            dict[Keys.name] = groupDetails?["groupName"]
//                            dict[Keys.conversationId] = groupDetails?["groupId"]
//                            dict[Keys.profilePicUrl] = groupDetails?["groupIcon"]
//                            userData.append(dict)
//                        }
//                    }
//
//                }
