//
//  GroupProfileViewController.swift
//  Chat
//
//  Created by Geetika on 21/06/23.
//

import UIKit
import Kingfisher

class GroupMembersListCell: UITableViewCell{
    
    @IBOutlet weak var adminLabel: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView!
    
}

class GroupProfileViewController: UIViewController {

    @IBOutlet weak var exitGroupView: UIView!
    @IBOutlet weak var participantsListView: UIView!
    @IBOutlet weak var groupDetailView: UIView!
    
    @IBOutlet weak var membersTableView: UITableView!
    @IBOutlet weak var participantsCount: UILabel!
    @IBOutlet weak var groupTitle: UILabel!
    @IBOutlet weak var groupIcon: UIImageView!
    
    var participantsList = [[String: Any]]()
    var groupDetail = [String: Any]()
    var adminId = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        membersTableView.dataSource = self
        
        viewStyle(view: groupDetailView)
        viewStyle(view: participantsListView)
        adminId = groupDetail["adminUid"] as? String ?? ""
        if groupDetail["groupIcon"] != nil{
            groupIcon.kf.setImage(with: URL(string: groupDetail["groupIcon"] as! String))

        }
        else{
            groupIcon.image = UIImage(systemName: "person.2.circle.fill")
            
        }
        groupTitle.text = groupDetail["groupName"] as? String
        CommonViews.shared.profileImageStyle(profileImage: groupIcon)
        participantsCount.text = "\(participantsList.count) Participants"
    }
    
    
    
    @IBAction func exitGroupButton(_ sender: Any) {
        
    }
    
    func viewStyle(view: UIView){
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2.0
    }
    
}

extension GroupProfileViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participantsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = membersTableView.dequeueReusableCell(withIdentifier: "GroupMembersListCell") as? GroupMembersListCell else{return UITableViewCell()}
        
        let profileUrl = participantsList[indexPath.row][Keys.profilePicUrl]
        if profileUrl != nil{
            cell.profile.kf.setImage(with: URL(string: profileUrl as! String))
        }
        else
        {
            cell.profile.image = UIImage(systemName: Keys.personWithCircle)
        }
        CommonViews.shared.profileImageStyle(profileImage: cell.profile)
        if participantsList[indexPath.row][Keys.userid] as! String == Manager.shared.auth.currentUser?.uid ?? ""{
            cell.name.text = "You"
        }
        else{
            cell.name.text = participantsList[indexPath.row][Keys.name] as? String

        }
        cell.adminLabel.isHidden = (participantsList[indexPath.row][Keys.userid] as! String == adminId) ? false : true

        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Participants"
    }
   
}

extension GroupProfileViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
