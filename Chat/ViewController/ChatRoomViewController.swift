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
    var msgArray = [ChatModel]()
    
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
        chatMsgList.register(BubbleView.nib, forCellReuseIdentifier: BubbleView.identifier)

        title = name
        Manager.shared.readData(roomId: self.roomId){ data in
            self.msgArray = data
            self.chatMsgList.reloadData()

        }
        //   self.bottomScroll()
          //  self.scrollToBottom()


        // keyboard settings
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    
    @IBAction func sendButton(_ sender: Any) {

        if textField.text != ""{
            
            self.sendMessageTime = Date().toMillis()
            
            let senderName = UserDefaults.standard.string(forKey: Keys.name)
            var msgDict = [Keys.message: textField.text ?? "",
                           Keys.receiverId: self.userId,
                           Keys.sendBy: senderName ?? "" ,
                           Keys.sendTo: self.name,
                           Keys.messageTime: sendMessageTime] as [String : Any]
            Manager.shared.saveMsg(roomId: roomId, msgDict: &msgDict)
            
            let conversationDict = [Keys.lastMessage: textField.text ?? "",  Keys.messageTime: sendMessageTime] as [String : Any]
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
            return
        }
        self.selectionEnable = true
        let cancelButton =  UIBarButtonItem(title: Keys.cancel, style: .plain, target: self, action: #selector(cancelButton))
        let deleteButton =  UIBarButtonItem(title: Keys.delete, style: .plain, target: self, action: #selector(DeleteButton))
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
        self.selectionEnable = false
        self.navigationItem.rightBarButtonItems = nil

        self.chatMsgList.reloadData()
    }
    //MARK: Delete Button
    @objc func DeleteButton(){
        Manager.shared.deleteMessage(conversationId: roomId, selectedMsgArray: selectedMsgId){ isDeleted in
            if isDeleted{
                self.navigationItem.rightBarButtonItems = nil
                self.messageDeleteAlert()
                self.chatMsgList.reloadData()
                
            }
        }
    }
    
    //MARK: show alert
    
    func messageDeleteAlert(){
        let alert = UIAlertController(title: "", message: Keys.messageDeleted, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Keys.ok, style: UIAlertAction.Style.default, handler: { _ in
            self.selectionEnable = false
//            for i in self.selectedMsgId{
//                self.msgArray.removeAll(where: {$0.msgId == i})
//            }
          
          //  Manager.shared.updateConversationLastMessage(messageData: self.msgArray, conversationId: self.roomId)
            self.selectedMsgId = []
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
        guard let cell = chatMsgList.dequeueReusableCell(withIdentifier: BubbleView.identifier, for: indexPath) as? BubbleView else{
            return UITableViewCell()
        }
        let row = msgArray[indexPath.row]
        let messageTime = Manager.shared.accessTime(time: Double(row.messageTime))
        cell.messageTime.text = messageTime
        cell.message.text = row.message
        
        cell.contentView.tag = indexPath.row
        cell.checkBox.isHidden = selectionEnable ? false : true
       
        cell.contentView.addGestureRecognizer(longPress)
//        let msgId = ((msgArray[indexPath.row] as AnyObject).value(forKey: Keys.msgId) ?? "") as? String ?? ""
//        cell.checkBox.image = selectedMsgId.contains(msgId) ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
//
        cell.updateBubblePosition(senderId: row.senderId, selectionEnable: selectionEnable)

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.selectionEnable == true else {return}
//        if self.selectedMsgId.contains(self.msgArray[indexPath.row].msgId) {
//            guard let indexOfId = selectedMsgId.firstIndex(of: self.msgArray[indexPath.row].msgId) else { return }
//            selectedMsgId.remove(at: indexOfId)
//        } else {
//            self.selectedMsgId.append(self.msgArray[indexPath.row].msgId)
//        }
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



