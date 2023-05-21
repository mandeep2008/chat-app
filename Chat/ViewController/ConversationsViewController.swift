//
//  ConversationsViewController.swift
//  Chat
//
//  Created by Geetika on 09/05/23.
//

import UIKit

class UserListCell: UITableViewCell{
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
}
class ConversationsViewController: UIViewController {

    @IBOutlet weak var allUser: UIButton!
    @IBOutlet weak var userList: UITableView!
    var conversations = [[String: Any]]()
    
    let allUsersInstance = AllUsersViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
        userList.delegate = self
        userList.dataSource = self
        self.navigationItem.setHidesBackButton(true, animated: true)
        let titleView = titleOfNavigation()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleView )
        allUserButtonStyle(button: allUser)
        Manager.shared.getUserList(){ data in
            Manager.shared.getConversations(){ data in
                print(data)
                self.conversations = data
                self.userList.reloadData()
                
                
            }
            
        }
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(sender:)))
        longPress.minimumPressDuration = 1.0
        userList.addGestureRecognizer(longPress)

    }
    
    
    @IBAction func allUsersButton(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AllUsersViewController") as? AllUsersViewController
          navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func logoutButton(_ sender: Any) {
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        Manager.shared.signout()
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
          navigationController?.pushViewController(vc!, animated: false)
        
        
    }
    //MARK: long press gesture
    @objc private func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: userList)
            if let indexPath = userList.indexPathForRow(at: touchPoint) {
                let conversation = conversations[indexPath.row]["conversationId"]
                print(indexPath.item)
                showDeletAlert(conversationID: conversation as! String, index: indexPath.item)
                
            }
        }
    }
    
}

//MARK: view(allUserButton , title)
extension ConversationsViewController{
    func allUserButtonStyle(button: UIButton){
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 6.0
         button.layer.cornerRadius = button.frame.size.width/2
    }
    func titleOfNavigation()-> UIView{
        let label = UILabel()
        label.layer.frame = CGRect(x: 20, y: 0, width: 30, height: 20)
        label.textColor = UIColor.white
        label.text = "Chat"
        return(label)
    }
    
    func showDeletAlert(conversationID: String, index: Int) {
        let alert = UIAlertController(title: "", message: "Do you want to delete this chat?",  preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in }))
            alert.addAction(UIAlertAction(title: "Delete",style: UIAlertAction.Style.default,  handler: {(_: UIAlertAction!) in
                Manager.shared.deleteConversation(converstaionId: conversationID)
                print(self.conversations)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    
}



 
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = userList.dequeueReusableCell(withIdentifier: "UserListCell") as? UserListCell else{
            return UITableViewCell()
        }
        if let name = conversations[indexPath.row]["name"] as? String{
            cell.name.text = name
        }
        if let lastMessage = conversations[indexPath.row]["lastMessage"] as? String{
            cell.lastMessage.text = lastMessage
            
        }
        cell.profile.image = UIImage(systemName: "person.circle")
        if let profileUrl = conversations[indexPath.row]["profileUrl"] as? String {
                print(conversations[indexPath.row])
            CommonViews.shared.profileImageStyle(profileImage: cell.profile)
                cell.profile.kf.setImage(with: URL(string: profileUrl))
        }
        
        
      
        
        let time = conversations[indexPath.row]["messageTime"]
        let messageTime = Manager.shared.accessTime(time: time as! Double)
        cell.messageTime.text = messageTime
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userList.deselectRow(at: indexPath, animated: true)
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ChatRoomViewController") as? ChatRoomViewController
        navigationController?.pushViewController(VC!, animated: true)
        if let name = conversations[indexPath.row]["name"] as? String{
            VC?.name = name
        }
        if let userId = conversations[indexPath.row]["uid"] as? String{
            VC?.userId = userId
        }
        if let conversationId = conversations[indexPath.row]["conversationId"] as? String{
            VC?.roomId = conversationId
        }
        

    }
}



