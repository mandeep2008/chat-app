//
//  CreateGroupViewController.swift
//  Chat
//
//  Created by Geetika on 13/06/23.
//

import UIKit
import Kingfisher


class CreateGroupViewController: UIViewController {

    @IBOutlet weak var userTableView: UITableView!
    var userList = [UserDetail] ()
    var selectedUsers = [UserDetail]()
    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.delegate = self
        userTableView.dataSource = self
        userTableView.register(UserList.nib, forCellReuseIdentifier: UserList.identifier)
    }
    
 

}

extension CreateGroupViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = userTableView.dequeueReusableCell(withIdentifier: UserList.identifier, for: indexPath) as? UserList else{ return UITableViewCell() }
        let row = userList[indexPath.row]
        cell.name.text = row.name
        CommonViews.shared.profileImageStyle(profileImage: cell.profile)
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


extension CreateGroupViewController: UITableViewDelegate{
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
       
        self.showNextBtn()
        self.userTableView.reloadData()
    }
    
        
}

extension CreateGroupViewController{
    
    func showNextBtn(){
        if selectedUsers.isEmpty{
            self.navigationItem.rightBarButtonItems = nil
        }
        else{
            let nextBtn =  UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextButton))
            navigationItem.rightBarButtonItems = [nextBtn]
        }
    }
    @objc func nextButton(){
        let vc = self.storyboard?.instantiateViewController(identifier: "AddGroupDetailsViewController") as? AddGroupDetailsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
       
        vc?.selectedUserList = selectedUsers
    }
}
