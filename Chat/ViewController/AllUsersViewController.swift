//
//  ViewController.swift
//  Chat
//
//  Created by Geetika on 27/04/23.
//

import UIKit
import Kingfisher



class ContactListCell: UITableViewCell{
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var name: UILabel!
    
}

class AllUsersViewController: UIViewController {
    @IBOutlet weak var contactList: UITableView!
    
    let nameList: [String] = []
    var userDict = [UserDetail] ()

 
    override func viewDidLoad() {
        super.viewDidLoad()
    

        contactList.delegate = self
        contactList.dataSource = self
        
        Manager.shared.getUserList(){ data in
          self.userDict = data
            self.contactList.reloadData()
            
        }
    }

}


extension AllUsersViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let listCell = contactList.dequeueReusableCell(withIdentifier: "ContactListCell", for: indexPath) as? ContactListCell else{
            return UITableViewCell()
        }
        let row = userDict[indexPath.row]
        listCell.name.text = row.name
        CommonViews.shared.profileImageStyle(profileImage: listCell.profile)
        if row.profilePicUrl != nil{
            listCell.profile.kf.setImage(with: URL(string: row.profilePicUrl!))
        }
        else
        {
            listCell.profile.image = UIImage(systemName: "person.circle")
        }

        return listCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: select user 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = userDict[indexPath.row]

        contactList.deselectRow(at: indexPath, animated: true)
        let VC = self.storyboard?.instantiateViewController(identifier: "ChatRoomViewController") as? ChatRoomViewController
        VC?.name = row.name ?? ""
        VC?.userId = row.uid ?? ""
        Manager.shared.checkconversation(selectedUserId: row.uid ?? ""){ roomId in
                        VC?.roomId = roomId
                        self.navigationController?.pushViewController(VC!, animated: true)
            }
       
    }
    
   
    
}

