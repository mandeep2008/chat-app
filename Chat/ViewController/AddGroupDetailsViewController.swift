//
//  AddGroupDetailsViewController.swift
//  Chat
//
//  Created by Geetika on 13/06/23.
//

import UIKit
import Kingfisher

class ParticipantsCell: UICollectionViewCell{
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView!
}
class AddGroupDetailsViewController: UIViewController {

    @IBOutlet weak var groupTitleTextfield: UITextField!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var participantsCollection: UICollectionView!
    var selectedUserList = [UserDetail]()
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var groupProflle: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.topViewStyle(view: topView)
        self.checkButtonStyle(button: checkButton)
        self.participantsCollection.dataSource = self
        
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(self.openGallery(tapGesture:)))
        groupProflle.addGestureRecognizer(tapGesture)
        CommonViews.shared.profileImageStyle(profileImage: groupProflle)


    }
    
    
    @IBAction func createGroupButton(_ sender: Any) {
        var participants = convertSelectUserObjectToDictionary()
        let conversationDict = [Keys.lastMessage: "" , Keys.messageTime:0, Keys.chatType: Keys.group] as [String: Any]

        StorageManager.shared.UploadImage(image: groupProflle.image!){ url in
            
            var groupDetail = [String: Any]()
            groupDetail[Keys.groupIcon] = url
            groupDetail[Keys.groupName] = self.groupTitleTextfield.text
            groupDetail[Keys.adminName] = UserDefaults.standard.string(forKey: Keys.name)
            
            GroupChatManager.shared.createGroup(groupDetail: &groupDetail, participants: &participants){ groupId in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConversationsViewController") as? ConversationsViewController
                self.navigationController?.pushViewController(vc!, animated: false)
                Manager.shared.createConversation(roomId: groupId, conversationDict: conversationDict)
            }
        }
    }
    
    func convertSelectUserObjectToDictionary() -> [[String: Any]]{
        var participants = [[String: Any]]()
        var dict = [String: Any]()
        
        for i in selectedUserList{
            dict[Keys.name] = i.name
            dict[Keys.email] = i.email
            dict[Keys.userid] = i.uid
            dict[Keys.profilePicUrl] = i.profilePicUrl
            participants.append(dict)
            
        }
        return participants
    }
    
    @objc func openGallery(tapGesture: UITapGestureRecognizer){
        self.setUpImagePicker()
    }
}

extension AddGroupDetailsViewController{
    func topViewStyle(view: UIView){
        view.layer.cornerRadius = view.frame.height / 9
        view.layer.shadowColor = UIColor.gray.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = .zero
    }
    
    func checkButtonStyle(button: UIButton){
        button.layer.cornerRadius = button.frame.height/2
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 6.0
    }
}

extension AddGroupDetailsViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUserList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = participantsCollection.dequeueReusableCell(withReuseIdentifier: "ParticipantsCell", for: indexPath) as? ParticipantsCell else {
            return UICollectionViewCell()
        }
        let item = selectedUserList[indexPath.row]
        cell.name.text = item.name
        CommonViews.shared.profileImageStyle(profileImage: cell.profile)
        if item.profilePicUrl != nil{
            cell.profile.kf.setImage(with: URL(string: item.profilePicUrl!))
        }
        else
        {
            cell.profile.image = UIImage(systemName: Keys.personWithCircle)
        }
        return cell
    }
    
    
}
extension AddGroupDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func setUpImagePicker(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.isEditing = true
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        groupProflle.image = image
        self.dismiss(animated: true, completion: nil)
    }
}
