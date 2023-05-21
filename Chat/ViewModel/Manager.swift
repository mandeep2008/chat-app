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
    var userDict = [[String: Any]] ()
    
    
    //MARK: SignUp user
    func signup(email: String, password: String, name : String,profileUrl: String, completion: @escaping (_ success: Bool)-> Void){
        auth.createUser(withEmail: email, password: password){ result, error in
            if let error = error{
                print(error)
            }
            else if let result = result?.user{
                print("success", result)
                let id = result.uid
                let email = result.email
                
                let dict = ["uid":id, "email":email ?? "", "name": name , "profilePicUrl": profileUrl]
                
                self.ref.child("Users").child(id).setValue(dict){
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Data could not be saved: \(error).")
                    } else {
                        print("Data saved successfully!")
                    }
                }
                print(result)
                completion(true)
                
            }
        }
    }
    
    //MARK: Login
    
    func login(email: String, password: String, completion: @escaping (_ success: Bool)-> Void){
        auth.signIn(withEmail: email, password: password){ result, error in
            if let error = error{
                print(error.localizedDescription)
            }
            if let result = result?.user{
                //MARK: userdefault data
                let defaults = UserDefaults.standard
                defaults.set(result.uid, forKey: "uid")
                defaults.set(result.email, forKey: "email")
                defaults.set(true, forKey: "isLoggedIn")
                
                print("login successfully")
                completion(true)
            }
            
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
    func getUserList(completion:@escaping (_ data: [[String: Any]])-> Void ){
        
        self.ref.child("Users").getData(completion:  {  error, result in
            guard error == nil else {
                print(error!.localizedDescription)
                return;
            }
            if var userdata = result?.value as? [String : Any] {
                // access current user name
                let currentUserDetails: [String: Any] = userdata[Auth.auth().currentUser?.uid ?? ""] as! [String : Any]
                UserDefaults.standard.set(currentUserDetails["name"], forKey: "name")
                
                userdata.removeValue(forKey: Auth.auth().currentUser?.uid ?? "")
                self.userDict = []
                for data in userdata.values {
                    if let userDetail = data as? [String : Any]{
                        self.userDict.append(userDetail)
                    }
                    
                }
                completion(self.userDict)
                
            }
        })
    }
    
    //MARK: get conversations id of current login user
    func getConversations(completion: @escaping (_ userData: [[String: Any]])-> Void){
        var dict = [String: Any]()
        var userData = [[String: Any]]()
        self.ref.child("Conversations").observe(.value, with: {snapshot in
            if snapshot.exists(){
                if let data = snapshot.value as? [String: Any]{
                    userData = []
                    for (id,value) in data{
                        dict = value as! [String: Any]
                        dict["conversationId"] = id
                        
                        if id.contains(Auth.auth().currentUser?.uid ?? ""){
                            self.accessUserId(id: id){id in
                                
                                for i in self.userDict{
                                    if i.contains(where: {$0.value as! String == id}){
                                        dict["name"] = i["name"]
                                        dict["uid"] = i["uid"]
                                        dict["profileUrl"] = i["profilePicUrl"]
                                        userData.append(dict)
                                    }
                                }
                                
                            }
                            
                        }
                    }
                    userData.sort{ ((($0 as Dictionary<String, AnyObject>)["messageTime"] as? Int)!) > ((($1 as Dictionary<String, AnyObject>)["messageTime"] as? Int)!)}
                    completion(userData)
                }
                
            }
        })
    }
    //MARK: get userId from conversation id
    func accessUserId(id: String, competion: (_ id: String)->Void){
        var userId = ""
        let data = id.components(separatedBy: "_")
        if data[0] != Auth.auth().currentUser?.uid{
            userId = data[0]
            competion(userId)
        }
        else{
            userId = data[1]
            competion(userId)
        }
    }
    
    
    //MARK: get data from database
    func readData(roomId: String, completion: @escaping (_ msgArray: [[String: Any]])-> Void){
        var msgArray = [[String: Any]]()
        self.ref.child("Chats").child(roomId).observe(.childAdded, with: {snapshot in
            if var snap = snapshot.value as? [String: Any]{
                print("Snapshot key \(snapshot.key)")
                snap["msgId"] = snapshot.key
                msgArray.append(snap)
            }
            completion(msgArray)
        })
    }
    //MARK: save message to database
    func saveMsg(roomId: String,msgDict: [String: Any]){
        var msgDict = msgDict
        msgDict["senderId"] = Auth.auth().currentUser?.uid
        self.ref.child("Chats").child(roomId).childByAutoId().setValue(msgDict)
    }
    //MARK: create converstaion
    func createConversation(roomId: String, conversationDict: [String: Any]){
        
        self.ref.child("Conversations").child(roomId).setValue(conversationDict)
        
    }
    
    
    //MARK: check conversation
    func checkconversation(selectedUserId: String, completion: @escaping(_ conversationId : String)-> Void){
        let currentUser = Auth.auth().currentUser?.uid
        var roomId = ""
        self.ref.child("Conversations").observeSingleEvent(of: .value, with: {snapshot in
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
        formatter.dateFormat = "hh:mm a"
        let msgTime = formatter.string(from: date)
        return(msgTime)
    }
    
    //MARK: delete conversations
    func deleteConversation(converstaionId : String){
        self.ref.child("Chats").child(converstaionId).removeValue(completionBlock: { error , result in
            guard error == nil else{
                print(error?.localizedDescription as Any)
                return
            }
            print("chat remove successfully")
        })
        self.ref.child("Conversations").child(converstaionId).removeValue()
    }
    
    //MARK: delete message
    func deleteMessage(conversationId: String,selectedMsgArray: [String], completion: @escaping (_ isDeleted: Bool)-> Void){
        let chatRef =  ref.child("Chats").child(conversationId)
        for id in selectedMsgArray{
            chatRef.child(id).observeSingleEvent(of: .value, with: {snap in
                print(snap)
                if var messageData = snap.value as? [String: Any]{
                    if messageData["senderId"] as! String == Auth.auth().currentUser?.uid ?? ""{
                        
                        // delete data
                        chatRef.child(id).removeValue(completionBlock: {error, databaseRef in
                            guard error == nil else{
                                print(error?.localizedDescription as Any)
                                return
                            }
                            print("message deleted ")
                            completion(true)
                            
                        })
                    }
                    // update data 
                    else
                        {
                            messageData["deletedByOther"] = true
                            chatRef.child(id).updateChildValues(messageData)
                            completion(true)
                        }
                } // if end
            })
           
        } // for loop end
        
        
    }
    
    
    
    
    
    
    
}


