//
//  ChatViewController.swift
//  Chat
//
//  Created by Geetika on 27/04/23.
//

import UIKit
import NotificationCenter
import FirebaseAuth
import Kingfisher
import IQKeyboardManagerSwift

class ChatRoomViewController: UIViewController {

    @IBOutlet weak var textfieldBottomConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var chatMsgList: UITableView!
    var msgArray = [MessageModel]()
    var groupDetail = [String: Any]()
    var participants = [UserDetail]()
    var name = ""
    var userId = ""
    var profilePic = ""
    var roomId = ""
    var chatType = ""
    var sendMessageTime  = Int64()
    var selectedMsgId = [MessageModel]()
    var selectionEnable = false
    let customNavBarViewInstance = ChatRoomNavigationBarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatMsgList.delegate = self
        chatMsgList.dataSource = self
        chatMsgList.register(BubbleView.nib, forCellReuseIdentifier: BubbleView.identifier)
        if userId != ""{
            Manager.shared.callWhenStatusUpdate(uid: userId){_ in
                
            }
        }
        Manager.shared.readData(roomId: self.roomId){ data in
            self.msgArray = data
            self.scrollToBottom()
        
            self.chatMsgList.reloadData()
        }
        
        //MARK: Navigation bar view
        let backButton = UIButton()
        backButton.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        let leftItem1 = UIBarButtonItem(customView: backButton)
        backButton.addTarget(self, action: #selector(leftBackButton), for: .touchUpInside)
        
        let leftItem2 = UIBarButtonItem(customView: customNavBarViewInstance)
        customNavBarViewInstance.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickOnNavigationBar(_:)))
        customNavBarViewInstance.addGestureRecognizer(tap)
        if profilePic != ""{
            customNavBarViewInstance.profilePic.kf.setImage(with: URL(string: profilePic))
            profileImageStyle(profileImage: customNavBarViewInstance.profilePic)
        }
        else{
            customNavBarViewInstance.profilePic.image = UIImage(systemName: Keys.personWithCircle)
        }
        
        customNavBarViewInstance.userName.text = name
        customNavBarViewInstance.status.isHidden = groupDetail[Keys.chatType] as! String == Keys.groupChat ? true : false
        navigationItem.leftBarButtonItems = [leftItem1, leftItem2]

        
        // keyboard settings
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.enable = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
    }

  
    @IBAction func textFieldChanged(_ sender: Any) {
        sendBtn.isEnabled = textField.text != "" ? true : false
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
     
            let conversationDict = [Keys.lastMessage: textField.text ?? "",  Keys.messageTime: sendMessageTime, Keys.chatType: chatType == Keys.group ? "group" : "single"] as [String : Any]
            
            Manager.shared.createConversation(roomId: roomId, conversationDict: conversationDict)
            
            textField.text = nil
            chatMsgList.reloadData()
            sendBtn.isEnabled = false
            bottomScrollWhenKeyboardOpen()
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
        let deleteButton =  UIBarButtonItem(title: Keys.delete, style: .plain, target: self, action: #selector(deleteButton))
        navigationItem.rightBarButtonItems = [cancelButton, deleteButton]
                self.chatMsgList.reloadData()
    }
    
    @objc private func leftBackButton (){
        self.navigationController?.popViewController(animated: true)
    }
    
    
   
    private func scrollToBottom(){
        DispatchQueue.main.async {
            if self.msgArray.count > 1{
                let indexPath = IndexPath(row: self.msgArray.count-1, section: 0)
                self.chatMsgList.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }

        }
    }
    
    private func bottomScrollWhenKeyboardOpen(){
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
    @objc func deleteButton(){
        Manager.shared.deleteMessage(conversationId: roomId, selectedMsgArray: selectedMsgId)
                self.navigationItem.rightBarButtonItems = nil
                self.deleteMessage()
    }
    
    //MARK: show alert
   private func deleteMessage(){
        self.selectionEnable = false
        for i in self.selectedMsgId{
            self.msgArray.removeAll(where: {$0.msgId == i.msgId})
        }
       let lastMessage =  self.msgArray.last
        if lastMessage != nil {
            Manager.shared.updateConversationLastMessage(messageData: lastMessage!, conversationId: self.roomId)
        }
        else{
            Manager.shared.deleteConversation(converstaionId: self.roomId){_ in }
        }
        self.selectedMsgId = []
        self.chatMsgList.reloadData()
    }
    
    @objc func clickOnNavigationBar(_ sender: UITapGestureRecognizer){
        print("tapped")
        if chatType == "group"{
            let vc = storyboard?.instantiateViewController(withIdentifier: "GroupProfileViewController") as? GroupProfileViewController
            self.navigationController?.pushViewController(vc!, animated: true)
            vc?.groupDetail = groupDetail
            
            vc?.participantsList = participants
           
        }
    
    }
}

//MARK: message table view
extension ChatRoomViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
                longPress.minimumPressDuration = 0.5
        guard let cell = chatMsgList.dequeueReusableCell(withIdentifier: BubbleView.identifier, for: indexPath) as? BubbleView else{
            return UITableViewCell()
        }
        let row = msgArray[indexPath.row]
        let messageTime = Manager.shared.accessTime(time: Double(row.messageTime ?? 0))
        cell.messageTime.text = messageTime
        cell.message.text = row.message
        cell.contentView.tag = indexPath.row
        cell.checkBox.isHidden = selectionEnable ? false : true
       
        cell.contentView.addGestureRecognizer(longPress)
        let msgId = msgArray[indexPath.row].msgId
        cell.checkBox.image = selectedMsgId.contains(where: {$0.msgId == msgId} ) ? UIImage(systemName: "checkmark.rectangle.fill") : UIImage(systemName: "rectangle")
        cell.senderName.text = row.sendBy ?? ""
        cell.updateBubblePosition(senderId: row.senderId ?? "", selectionEnable: selectionEnable, chatType: chatType)
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
        if self.selectedMsgId.contains(where: {$0.msgId == self.msgArray[indexPath.row].msgId}) {
            guard let index = selectedMsgId.firstIndex(where: { $0.msgId == self.msgArray[indexPath.row].msgId}) else { return}
            selectedMsgId.remove(at: index)
        } else {
            self.selectedMsgId.append(self.msgArray[indexPath.row])
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
      scrollToBottom()
        let bottomSafeArea = self.view.safeAreaInsets.bottom
        self.textfieldBottomConstraints.constant = keyboardSize.height - bottomSafeArea
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
     self.textfieldBottomConstraints.constant = 0
    }
    
}





