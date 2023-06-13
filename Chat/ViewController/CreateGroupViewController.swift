//
//  CreateGroupViewController.swift
//  Chat
//
//  Created by Geetika on 13/06/23.
//

import UIKit
import Kingfisher

class UserCell: UITableViewCell{
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
}

class CreateGroupViewController: UIViewController {

    @IBOutlet weak var userTableView: UITableView!
    var userList = [UserDetail] ()
    override func viewDidLoad() {
        super.viewDidLoad()
        userTableView.delegate = self
        userTableView.dataSource = self
    }
    

}

extension CreateGroupViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = userTableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserCell else{ return UITableViewCell() }
        let row = userList[indexPath.row]
        cell.userName.text = row.name
        CommonViews.shared.profileImageStyle(profileImage: cell.profilePic)
        if row.profilePicUrl != nil{
            cell.profilePic.kf.setImage(with: URL(string: row.profilePicUrl!))
        }
        else
        {
            cell.profilePic.image = UIImage(systemName: "person.circle")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
}
