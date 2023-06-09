//
//  ConversationsViewController.swift
//  Chat
//
//  Created by Geetika on 09/05/23.
//

import UIKit
import Kingfisher

class UserListCell: UITableViewCell{
    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
}
class ConversationsViewController: UIViewController {

    @IBOutlet weak var allUser: UIButton!
    @IBOutlet weak var userList: UITableView!
    var conversations = [Conversations]()
    var groupData = [String: Any]()
    var currentUserDetail = [String: Any]()
  
    let imageView = UIImageView(image: UIImage(systemName: Keys.personWithCircle))
    override func viewDidLoad() {
        super.viewDidLoad()
        userList.delegate = self
        userList.dataSource = self
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        let titleView = titleOfNavigation()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleView )

      // navigation bar right button user profile
        imageView.frame.size.width = 30
        imageView.frame.size.height = 30
        let item = UIBarButtonItem(customView: imageView)
        self.navigationItem.rightBarButtonItem = item
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileButtonPressed(_:)))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        self.profileImageStyle(profileImage: imageView)
        allUserButtonStyle(button: allUser)
        
        
        GroupChatManager.shared.readGroups(){ groupData in
            self.groupData = groupData
        }
        Manager.shared.getUserList(){ data  in
            guard GlobalData.shared.userDetail != nil else{return}
            self.currentUserDetail = GlobalData.shared.userDetail!
            Manager.shared.getConversations(userList: data, groupData: self.groupData){ conversationsList in
                    DispatchQueue.main.async {
                        self.conversations = conversationsList
                        self.userList.reloadData()
                    }
                  
            }
        }
        
    }
    
    @IBAction func allUsersButton(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AllUsersViewController") as? AllUsersViewController
        navigationController?.pushViewController(vc!, animated: true)
        
    }
    
   @objc func profileButtonPressed(_ sender: UITapGestureRecognizer) {

       let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController
       self.navigationController?.pushViewController(vc!, animated: true)
        }
}

//MARK: view(allUserButton , title)
extension ConversationsViewController{
    func allUserButtonStyle(button: UIButton){
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
        button.layer.shadowOpacity = 0.5
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
    
    
}


// conversation list
 
extension ConversationsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = userList.dequeueReusableCell(withIdentifier: "UserListCell") as? UserListCell else{
            return UITableViewCell()
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let row = conversations[indexPath.row]
        cell.name.text = row.name
        cell.lastMessage.text = row.lastMessage
        if row.profilePicUrl != nil{
            self.profileImageStyle(profileImage: cell.profile)
            cell.profile.kf.setImage(with: URL(string: row.profilePicUrl!))
        }
        else{
            cell.profile.image = UIImage(systemName: Keys.personWithCircle)
        }
        
        cell.messageTime.isHidden = row.messageTime == 0 ? true : false
        let messageTime = Manager.shared.accessTime(time: Double(row.messageTime ?? 0))
        cell.messageTime.text = messageTime
        return cell
    }
    
   
    
  
}

extension ConversationsViewController: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userList.deselectRow(at: indexPath, animated: true)
        let VC = self.storyboard?.instantiateViewController(identifier: "ChatRoomViewController") as? ChatRoomViewController
        navigationController?.pushViewController(VC!, animated: true)
        let row = conversations[indexPath.row]
            VC?.name = row.name ?? ""
            VC?.userId = row.uid ?? ""
            VC?.roomId = row.conversationId ?? ""
            VC?.chatType = row.chatType ?? ""
          let conversationId = row.conversationId
    
         GroupChatManager.shared.accessGroupDetailsAndParticipants(groupData: groupData, conversationId: conversationId ?? ""){groupDetails, groupParticipants in
             VC?.participants = groupParticipants
             VC?.groupDetail = groupDetails
         }
        }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            if self.conversations[indexPath.row].chatType == "group" {
            
            }
            else{
                Manager.shared.deleteConversation(converstaionId: self.conversations[indexPath.row].conversationId ?? ""){ isDeleted in
                    if isDeleted{
                        self.userList.reloadData()
                    }
                }
            }
          

            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: Keys.trash)
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

extension ConversationsViewController{
    func showAlert(){
        let alert = UIAlertController(title: "", message:Keys.exitGroupAlert, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in}))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
       
    }))
                                     
   }
}



