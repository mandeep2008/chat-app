//
//  ChatViewController.swift
//  Chat
//
//  Created by Geetika on 27/04/23.
//

import UIKit
import NotificationCenter
import FirebaseAuth

class ChatRoomViewController: UIViewController {

   
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var chatMsgList: UITableView!
    var msgArray:[[String: Any]] = []
    
    var name = ""
    var userId = ""
    var roomId = ""
    var sendMessageTime  = Int64()
    var selectedMsgId = [String]()
    var selectionEnable = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatMsgList.delegate = self
        chatMsgList.dataSource = self
        chatMsgList.register(LeftBubbleView.nib, forCellReuseIdentifier: LeftBubbleView.identifier)
        chatMsgList.register(RightBubblView.nib, forCellReuseIdentifier: RightBubblView.identifier)

        title = name
        Manager.shared.readData(roomId: self.roomId){ data in
            self.msgArray = data
            self.chatMsgList.reloadData()
            self.bottomScroll()
            self.scrollToBottom()

        }

        // keyboard settings
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
//            let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
//            view.addGestureRecognizer(tap)
    }

    
    @IBAction func sendButton(_ sender: Any) {

        if textField.text != ""{
            
            self.sendMessageTime = Date().toMillis()
            
            let senderName = UserDefaults.standard.string(forKey: "name")
            let msgDict = ["message": textField.text ?? "", "receiverId": self.userId, "sendBy": senderName ?? "" ,"SendTo": self.name,"messageTime": sendMessageTime] as [String : Any]
            Manager.shared.saveMsg(roomId: roomId, msgDict: msgDict)
            
            let conversationDict = ["lastMessage": textField.text ?? "", "messageTime": sendMessageTime] as [String : Any]
            Manager.shared.createConversation(roomId: roomId, conversationDict: conversationDict)
            textField.text = nil
            chatMsgList.reloadData()
            bottomScroll()
            scrollToBottom()

        }
    }
    
    //MARK: long press gesture
    
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        guard (sender.view?.tag) != nil else {
            print("Index not found")
            return
        }
        self.selectionEnable = true
        let cancelButton =  UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButton))
        let deleteButton =  UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(DeleteButton))
        navigationItem.rightBarButtonItems = [cancelButton, deleteButton]

                self.chatMsgList.reloadData()
    }
    
    
   
    func scrollToBottom(){
        DispatchQueue.main.async {
           let indexPath = IndexPath(row: self.msgArray.count-1, section: 0)
            self.chatMsgList.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func bottomScroll(){
        chatMsgList.setContentOffset(CGPoint(x: 0, y:self.chatMsgList.contentSize.height - self.chatMsgList.bounds.size.height), animated: false)
    }

    
}

extension ChatRoomViewController{
    //MARK: cancel button
    
    @objc func cancelButton(){
        print("tapped")
        self.selectionEnable = false
        self.navigationItem.rightBarButtonItems = nil

        self.chatMsgList.reloadData()
    }
    //MARK: Delete Button
    @objc func DeleteButton(){
        print("tapped")
        Manager.shared.deleteMessage(conversationId: roomId, selectedMsgArray: selectedMsgId){ isDeleted in
            if isDeleted{
                self.navigationItem.rightBarButtonItems = nil
                self.messageDeleteAlert()
                
            }
        }
    }
    
    //MARK: show alert
    
    func messageDeleteAlert(){
        let alert = UIAlertController(title: "", message: "Message Deleted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { [self] _ in
            self.selectionEnable = false
            self.chatMsgList.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: message table view
extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
                longPress.minimumPressDuration = 0.5
               
        
        
        if msgArray[indexPath.row]["senderId"] as! String == Auth.auth().currentUser?.uid ?? ""{
            guard let rightCell = chatMsgList.dequeueReusableCell(withIdentifier: RightBubblView.identifier, for: indexPath) as? RightBubblView  else{
                return UITableViewCell()
            }
            let messageTime = Manager.shared.accessTime(time:  msgArray[indexPath.row]["messageTime"] as! Double)
            rightCell.messageTime.text = messageTime
            rightCell.message.text = msgArray[indexPath.row]["message"] as? String
           
            
            rightCell.contentView.tag = indexPath.row
            rightCell.checkBox.isHidden = selectionEnable ? false : true
            rightCell.setConstraints(selectionEnable: selectionEnable)
            
            rightCell.contentView.addGestureRecognizer(longPress)
            let msgId = ((msgArray[indexPath.row] as AnyObject).value(forKey: "msgId") ?? "") as? String ?? ""
            rightCell.checkBox.image = selectedMsgId.contains(msgId) ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")

            return rightCell
        }
        
        else{
            guard let leftCell = chatMsgList.dequeueReusableCell(withIdentifier: LeftBubbleView.identifier, for: indexPath) as? LeftBubbleView  else{
                return UITableViewCell()
            }
            if msgArray[indexPath.row].contains(where: {$0.key == "deletedByOther"}){
                return UITableViewCell()
            }
            else{
                let messageTime = Manager.shared.accessTime(time:  msgArray[indexPath.row]["messageTime"] as! Double)
                leftCell.messageTime.text = messageTime
                leftCell.receiveMsg.text = msgArray[indexPath.row]["message"] as? String
                
               
                leftCell.contentView.addGestureRecognizer(longPress)
                leftCell.contentView.tag = indexPath.row
                leftCell.checkBox.isHidden = selectionEnable ? false : true
                
                let msgId = ((msgArray[indexPath.row] as AnyObject).value(forKey: "msgId") ?? "") as? String ?? ""
                leftCell.checkBox.image = selectedMsgId.contains(msgId) ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
                leftCell.setConstraints(selectionEnable: selectionEnable)
                return leftCell
            }
           
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.selectionEnable == true else {return}
        if self.selectedMsgId.contains(self.msgArray[indexPath.row]["msgId"] as? String ?? "") {
            guard let indexOfId = selectedMsgId.firstIndex(of: self.msgArray[indexPath.row]["msgId"] as? String ?? "") else { return }
            selectedMsgId.remove(at: indexOfId)
        } else {
            self.selectedMsgId.append(self.msgArray[indexPath.row]["msgId"] as? String ?? "")
        }
        self.chatMsgList.reloadData()
    }
    
}
 

//MARK: Keyboard

extension ChatRoomViewController{
    @objc func keyboardWillShow(notification: NSNotification) {
            
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           return
        }
      self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
      self.view.frame.origin.y = 0
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}



