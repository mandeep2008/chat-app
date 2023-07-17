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

        
        let containerView = UIControl(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        containerView.addTarget(self, action: #selector(profileButtonPressed), for: .touchUpInside)
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))
        imageView.image = UIImage(systemName: Keys.personWithCircle)
        imageView.contentMode = .scaleAspectFill 
        containerView.addSubview(imageView)
        self.profileImageStyle(profileImage: imageView)
        let item = UIBarButtonItem(customView: containerView)
        item.width = 20
        navigationItem.rightBarButtonItem = item
        
      

        allUserButtonStyle(button: allUser)
        
        
        GroupChatManager.shared.readGroups(){ groupData in
            self.groupData = groupData
        }
        Manager.shared.getUserList(){ data  in
            guard GlobalData.shared.userDetail != nil else{return}
            self.currentUserDetail = GlobalData.shared.userDetail!
            if GlobalData.shared.userDetail?[Keys.profilePicUrl] != nil{
                imageView.kf.setImage(with: URL(string: GlobalData.shared.userDetail?[Keys.profilePicUrl] as! String))
                
            }
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

//MARK: view style(allUserButton , title)
extension ConversationsViewController{
    private func allUserButtonStyle(button: UIButton){
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 3.0)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 6.0
        button.layer.cornerRadius = button.frame.size.width/2
    }
    private func titleOfNavigation()-> UIView{
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
        let vc = self.storyboard?.instantiateViewController(identifier: "ChatRoomViewController") as? ChatRoomViewController
        navigationController?.pushViewController(vc!, animated: true)
        let row = conversations[indexPath.row]
         vc?.name = row.name ?? ""
         vc?.userId = row.uid ?? ""
         vc?.roomId = row.conversationId ?? ""
         vc?.chatType = row.chatType ?? ""
         vc?.profilePic = row.profilePicUrl ?? ""
        let conversationId = row.conversationId
    
         GroupChatManager.shared.accessGroupDetailsAndParticipants(groupData: groupData, conversationId: conversationId ?? ""){groupDetails, groupParticipants in
             vc?.participants = groupParticipants
             vc?.groupDetail = groupDetails
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
   private func showAlert(){
        let alert = UIAlertController(title: "", message:Keys.exitGroupAlert, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in}))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
       
    }))
                                     
   }
}



