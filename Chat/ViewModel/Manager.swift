//
//  Manager.swift
//  Chat
//
//  Created by Geetika on 09/05/23.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import CodableFirebase


class Manager{
    static let shared = Manager()
    var ref = Database.database().reference()
    let auth = Auth.auth()
    
    
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
    func getUserList(completion:@escaping (_ data: [Users])-> Void ){
        
        self.ref.child(Keys.users).getData(completion:  {  error, result in
            guard let values = result?.value, let usersList = values as? [String: Any]  else { return }
            print(usersList.values)
        
            var userData = [Users]()
            for data in usersList.values{
                
                let modelData = Users(json: data as? [String: Any] ?? [:])
                if modelData.uid != self.auth.currentUser?.uid{
                    userData.append(modelData)
                }
                else
                {
                    // current loogged in user name using for message sendBy and sendTo
                   UserDefaults.standard.set(modelData.name, forKey: Keys.name)
                }
            }
            completion(userData)

        })
    }

    //MARK: get conversations of current login user
    func getConversations(userList: [Users],completion: @escaping (_ userData: [ConversationDetail])-> Void){
        self.ref.child(Keys.conversations).observe(.value, with: {snapshot in
            if snapshot.exists(){
                if let data = snapshot.value as? [String: Any]{
                    self.saveConversationsDetails(userList: userList, snapshotData: data){ userData in
                        completion(userData)
                    }
                }
            }
        })
    }
    
//MARK: save conversation details from conversations List and user detail from all user list
    func saveConversationsDetails(userList: [Users],snapshotData: [String: Any], completion: @escaping(_ userData: [ConversationDetail])-> Void){
        var userData = [ConversationDetail]()

        for (conversationId,value) in snapshotData{
            var dict = [String: Any]()
            if let values = value as? [String: Any]{
                dict = values
            }
            dict[Keys.conversationId] = conversationId
            if conversationId.contains(self.auth.currentUser?.uid ?? ""){
                
                self.accessUserId(id: conversationId){userId in
                    for i in userList{
                        if i.uid == userId{
                            dict[Keys.name] = i.name
                            dict[Keys.userid] = i.uid
                            dict[Keys.profilePicUrl] = i.profilePicUrl
                            let data = ConversationDetail(conversationData: dict)
                            userData.append(data)
                        }
                    }
                }
            }
        }
        userData.sort(by: {$0.messageTime > $1.messageTime})
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
    func readData(roomId: String, completion: @escaping (_ msgArray: [ChatModel])-> Void){
        var msgArray = [ChatModel]()
        self.ref.child(Keys.chats).child(roomId).observe(.childAdded, with: {snapshot in
            print(snapshot)
            if var snap = snapshot.value as? [String: Any]{
                print(snap)
               // snap[Keys.msgId] = snapshot.key
                let messageData = ChatModel(chatData: snap)
                msgArray.append(messageData)
            }
            
            completion(msgArray)
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
    func deleteConversation(converstaionId : String){
        self.ref.child(Keys.chats).child(converstaionId).removeValue(completionBlock: { error , result in
            guard error == nil else{
                print(error?.localizedDescription as Any)
                return
            }
        })
        self.ref.child(Keys.conversations).child(converstaionId).removeValue()
    }
    
    //MARK: delete message
    func deleteMessage(conversationId: String,selectedMsgArray: [String], completion: @escaping (_ isDeleted: Bool)-> Void){
        let chatRef =  ref.child(Keys.chats).child(conversationId)
        for messageId in selectedMsgArray{
            chatRef.child(messageId).observeSingleEvent(of: .value, with: {snap in
                if let messageData = snap.value as? [String: Any]{
                    if messageData[Keys.senderId] as! String == self.auth.currentUser?.uid ?? ""{
                        self.removeMessage(messageId: messageId, messageData: messageData, chatRef: chatRef){ dataRemoved in
                            completion(dataRemoved ? true : false)
                        }
                    }
                }
            })
           
        } // for loop end
    }
    
    //MARK: remove message from database
    
    func removeMessage(messageId: String, messageData: [String: Any], chatRef: DatabaseReference, completion: @escaping (_ dataRemoved: Bool)-> Void){
        chatRef.child(messageId).removeValue(completionBlock: {error, databaseRef in
            guard error == nil else{
                return
            }
            completion(true)
        })
    }

    
    //MARK: update last message in conversations
    
    func updateConversationLastMessage(messageData: [String: Any], conversationId: String){
        let dict = [Keys.lastMessage: messageData[Keys.message], Keys.messageTime: messageData[Keys.messageTime]]
        self.ref.child(Keys.conversations).child(conversationId).updateChildValues(dict)
    }
}


