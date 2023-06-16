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
    var conversations = [Conversations]()
    
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
            Manager.shared.getConversations(userList: data){ conversationsList in
               self.conversations = conversationsList
                self.userList.reloadData()
            }
            
        }
    }
    
    
    @IBAction func allUsersButton(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AllUsersViewController") as? AllUsersViewController
          navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func logoutButton(_ sender: Any) {
        showLogoutAlert()
          
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
    
    func showLogoutAlert(){
        let alert = UIAlertController(title: "", message: "Do you want to logout", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in}))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            var dict = UserDefaults.standard.dictionary(forKey: Keys.defaults)
            dict?[Keys.isLoggedIn] = false
            UserDefaults.standard.set(dict, forKey: Keys.defaults)
            Manager.shared.signout()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        }))
        self.present(alert, animated: true)
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
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        let row = conversations[indexPath.row]
        cell.name.text = row.name
        cell.lastMessage.text = row.lastMessage
        if row.profilePicUrl != nil{
            CommonViews.shared.profileImageStyle(profileImage: cell.profile)
            cell.profile.kf.setImage(with: URL(string: row.profilePicUrl!))
        }
        else{
            cell.profile.image = UIImage(systemName: Keys.personWithCircle)
        }
        let messageTime = Manager.shared.accessTime(time: Double(row.messageTime ?? 0))
        cell.messageTime.text = messageTime
        return cell
    }
    
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
        }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            Manager.shared.deleteConversation(converstaionId: self.conversations[indexPath.row].conversationId ?? ""){ isDeleted in
                if isDeleted{
                    self.userList.reloadData()
                }
            }
            
            completionHandler(true)
        }
        deleteAction.image = UIImage(systemName: "trash")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}



