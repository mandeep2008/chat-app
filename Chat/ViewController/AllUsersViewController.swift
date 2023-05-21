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
    var userDict = [[String: Any]] ()

 
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
        if let name = userDict[indexPath.row]["name"] as? String{
            listCell.name.text = name
        }
        CommonViews.shared.profileImageStyle(profileImage: listCell.profile)

        if let profileUrl = userDict[indexPath.row]["profilePicUrl"] as? String{
            listCell.profile.kf.setImage(with: URL(string: profileUrl))
        }
        return listCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    //MARK: select user 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contactList.deselectRow(at: indexPath, animated: true)
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "ChatRoomViewController") as? ChatRoomViewController
        if let name = userDict[indexPath.row]["name"] as? String{
            VC?.name = name
        }
        if let userId = userDict[indexPath.row]["uid"] as? String{
            VC?.userId = userId
            Manager.shared.checkconversation(selectedUserId:userId){ roomId in
                print(roomId)
                VC?.roomId = roomId
                self.navigationController?.pushViewController(VC!, animated: true)
                
            }
        }
       
    }
    
   
    
}

