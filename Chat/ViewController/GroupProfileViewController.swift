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
    
    @IBOutlet var listLongTapGeature: UILongPressGestureRecognizer!
    var participantsList = [UserDetail]()
    var groupDetail = [String: Any]()
    var adminId = ""
    
    let currentUserId = Manager.shared.auth.currentUser?.uid ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        membersTableView.dataSource = self
        membersTableView.delegate = self
        
        
        
        viewStyle(view: groupDetailView)
        viewStyle(view: participantsListView)
        adminId = groupDetail[Keys.adminUid] as? String ?? ""
        if groupDetail[Keys.groupIcon] != nil{
            groupIcon.kf.setImage(with: URL(string: groupDetail[Keys.groupIcon] as! String))
            
        }
        else{
            groupIcon.image = UIImage(systemName: Keys.twoPersonImage)
            
        }
        groupTitle.text = groupDetail[Keys.groupName] as? String
        self.profileImageStyle(profileImage: groupIcon)
        participantsCount.text = "\(participantsList.count) \(Keys.participants)"
        membersTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    @IBAction func exitGroupButton(_ sender: Any) {
        showLogoutAlert()
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func longTapGesture(_ sender: Any) {
        print("tapped")
    }
    
    func viewStyle(view: UIView){
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        view.layer.shadowOpacity = 0.3
        view.layer.shadowRadius = 2.0
    }
    
    
    
    func showLogoutAlert(){
        let alert = UIAlertController(title: "", message:Keys.exitGroupAlert, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in}))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            GroupChatManager.shared.deleteParticipant(groupId: self.groupDetail[Keys.groupId] as! String, completion: { isDeleted in
                print(isDeleted)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConversationsViewController") as? ConversationsViewController
                self.navigationController?.pushViewController(vc!, animated: false)
                
            })
        }))
        self.present(alert, animated: true)
    }
    
}

extension GroupProfileViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participantsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = membersTableView.dequeueReusableCell(withIdentifier: "GroupMembersListCell") as? GroupMembersListCell else{return UITableViewCell()}
        
        let profileUrl = participantsList[indexPath.row].profilePicUrl
        self.profileImageStyle(profileImage: cell.profile)
        
        if profileUrl != nil{
            cell.profile.kf.setImage(with: URL(string: profileUrl ?? ""))
        }
        else
        {
            cell.profile.image = UIImage(systemName: Keys.personWithCircle)
        }
        if participantsList[indexPath.row].uid! == Manager.shared.auth.currentUser?.uid ?? ""{
            cell.name.text = "You"
        }
        else{
            cell.name.text = participantsList[indexPath.row].name
            
        }
        cell.adminLabel.isHidden = (participantsList[indexPath.row].uid! == adminId) ? false : true
        
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
}

extension GroupProfileViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray5
        
        headerTitle(view: view)
        if groupDetail[Keys.adminUid] as! String == currentUserId{
            addParticipantsButton(view: view)
        }
        
        return view
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
}

//MARK: Header view
extension GroupProfileViewController{
    
    func headerTitle(view: UIView){
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: 11, y: 10, width:170, height: 18)
        titleLabel.text = Keys.participants
        titleLabel.font = titleLabel.font.withSize(16)
        view.addSubview(titleLabel)
    }
    func addParticipantsButton(view: UIView){
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Keys.personWithPlus), for: .normal)
        button.tintColor = UIColor.systemGreen
        
        button.frame = CGRect(x: self.view.frame.size.width - 40, y: 6, width: 30, height: 30)
        
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        view.addSubview(button)
        
    }
    
    @objc func buttonAction(_ button: UIButton){
        let vc = self.storyboard?.instantiateViewController(identifier: "CreateGroupViewController") as? CreateGroupViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        vc?.selectedUsers = participantsList
        vc?.addMoreParticipants = true
        vc?.groupDetail = groupDetail
        vc?.passData = { data in
            self.participantsList = data
            self.membersTableView.reloadData()
            
        }
    }
}

