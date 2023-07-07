//
//  SelectUsersForGroupViewController.swift
//  Chat
//
//  Created by Geetika on 13/06/23.
//

import UIKit
import Kingfisher


class SelectUsersForGroupViewController: UIViewController {

    @IBOutlet weak var userTableView: UITableView!
    var userList = [UserDetail] ()
    var selectedUsers = [UserDetail]()
    var groupDetail = [String: Any]()
    var addMoreParticipants = false

    var passData : (([UserDetail])-> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.register(UserList.nib, forCellReuseIdentifier: UserList.identifier)
        
        Manager.shared.getUserList(){ data in
          self.userList = data
            self.userTableView.reloadData()

        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
     super.viewWillDisappear(animated)
        if addMoreParticipants{
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
    
 

}

extension SelectUsersForGroupViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = userTableView.dequeueReusableCell(withIdentifier: UserList.identifier, for: indexPath) as? UserList else{ return UITableViewCell() }
        let row = userList[indexPath.row]

        cell.name.text = row.name
        cell.aboutText.text = row.about != nil ? row.about : ""
        
        self.profileImageStyle(profileImage: cell.profile)
        if row.profilePicUrl != nil{
            cell.profile.kf.setImage(with: URL(string: row.profilePicUrl!))
        }
        else
        {
            cell.profile.image = UIImage(systemName: Keys.personWithCircle)
        }
        cell.radioButton.image = selectedUsers.contains(where: {$0.uid == userList[indexPath.row].uid}) ? UIImage(systemName: Keys.circleInsetFilled) : UIImage(systemName: Keys.circle )
        return cell
    }
   
}


extension SelectUsersForGroupViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.selectedUsers.contains(where: {$0.uid == self.userList[indexPath.row].uid}) {
            guard let index = selectedUsers.firstIndex(where: { $0.uid == self.userList[indexPath.row].uid}) else { return}
            selectedUsers.remove(at: index)
        } else {
            
            self.selectedUsers.append(self.userList[indexPath.row])
        }
       
        addMoreParticipants ? self.addParticipantsButton() : self.showNextBtn()
        self.userTableView.reloadData()
    }
    
        
}

extension SelectUsersForGroupViewController{
    
    func showNextBtn(){
        if selectedUsers.isEmpty{
            self.navigationItem.rightBarButtonItems = nil
        }
        else{
            let nextBtn =  UIBarButtonItem(title: Keys.next, style: .plain, target: self, action: #selector(nextButton))
            navigationItem.rightBarButtonItems = [nextBtn]
        }
    }
    @objc func nextButton(){
        let vc = self.storyboard?.instantiateViewController(identifier: "AddGroupDetailsViewController") as? AddGroupDetailsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
       
        vc?.selectedUserList = selectedUsers
    }
    
    func addParticipantsButton(){
        let addBtn =  UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButton))
        navigationItem.rightBarButtonItems = [addBtn]
    }
    
    @objc func addButton(){
        let updatedParticipantsList = GroupChatManager.shared.convertSelectUserObjectToDictionary(selectedUserList: selectedUsers)
       print(updatedParticipantsList)
        
        GroupChatManager.shared.updateParticipantsList(updatedParticipants: updatedParticipantsList, conversationId: groupDetail[Keys.groupId] as! String){ updated in
            if updated{
                self.passData!(self.selectedUsers)
                self.navigationController?.popViewController(animated: true)
            }
        }
       
    }
}


