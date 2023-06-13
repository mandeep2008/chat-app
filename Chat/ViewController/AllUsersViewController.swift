//
//  ViewController.swift
//  Chat
//
//  Created by Geetika on 27/04/23.
//

import UIKit
import Kingfisher



class AllUsersViewController: UIViewController {
    @IBOutlet weak var contactList: UITableView!

    @IBOutlet weak var createGroupView: UIView!
    let nameList: [String] = []
    var userDict = [UserDetail] ()
    var selectionEnable = false


    override func viewDidLoad() {
        super.viewDidLoad()


        contactList.delegate = self
        contactList.dataSource = self
        let tapGesture = UITapGestureRecognizer(target:self,action:#selector(self.createGroupTap))
        createGroupView.addGestureRecognizer(tapGesture)
        Manager.shared.getUserList(){ data in
          self.userDict = data
            self.contactList.reloadData()

        }
    }

    @objc func createGroupTap() {
//        let vc = self.storyboard?.instantiateViewController(identifier: "CreateGroupViewController") as? CreateGroupViewController
//        self.navigationController?.pushViewController(vc!, animated: true)
//        vc?.userList = self.userDict
        self.selectionEnable.toggle()
    }

}


extension AllUsersViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
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
        listCell.showRadioButton(selectionEnable: self.selectionEnable)
        return listCell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "All Users"
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

