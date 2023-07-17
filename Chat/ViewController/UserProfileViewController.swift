//
//  UserProfileViewController.swift
//  Chat
//
//  Created by Geetika on 04/07/23.
//

import UIKit

class UserProfileViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
     @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var nameTextfield: UITextField!
    
    @IBOutlet weak var parentViewOfAbout: UIView!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var profileVIew: UIView!
    var userDetail = [String: Any]()
    
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
       

        imagePicker.delegate = self
       loader.isHidden = true
        navigationController?.setNavigationBarHidden(true, animated: false)
        profilePicture.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openGallery(_:)))
        profilePicture.addGestureRecognizer(tap)
        
        
        self.profileImageStyle(profileImage: profilePicture)
        self.viewStyle(view: scrollView)
        if GlobalData.shared.userDetail != nil{
            userDetail = GlobalData.shared.userDetail!
        }
        profilePicture.backgroundColor = .white

        if userDetail[Keys.profilePicUrl] != nil{
            self.profilePicture.kf.setImage(with: URL(string: userDetail[Keys.profilePicUrl] as! String))
            
        }
        else
        {
            self.profilePicture.image = UIImage(systemName: Keys.personWithCircle)
        }
        self.emailTextfield.text = userDetail[Keys.email] as? String
        self.nameTextfield.text = userDetail[Keys.name] as? String
        self.aboutTextView.text = userDetail[Keys.about] as? String
        self.textViewStyle(textView: parentViewOfAbout)
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func logoutButton(_ sender: Any) {
        self.showLogoutAlert()
    }
    
    @IBAction func saveChanges(_ sender: Any) {
      loader.isHidden = false
        guard profilePicture.image != nil else{return}
        StorageManager.shared.UploadImage(image: profilePicture.image!){ url in
            let dict = [
                Keys.name: self.nameTextfield.text ?? "",
                Keys.email: self.emailTextfield.text ?? "",
                Keys.about: self.aboutTextView.text ?? "",
                Keys.profilePicUrl: url,
                Keys.userid: self.userDetail[Keys.userid] ?? ""]
            Manager.shared.updateUserProfile(dict: dict){
                GlobalData.shared.userDetail = dict
                self.loader.isHidden = true
                
            }
            
        }
        
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        self.emailTextfield.text = userDetail[Keys.email] as? String
        self.nameTextfield.text = userDetail[Keys.name] as? String
        self.profileImageStyle(profileImage: profilePicture)
        if userDetail[Keys.profilePicUrl] != nil{
            self.profilePicture.kf.setImage(with: URL(string: userDetail[Keys.profilePicUrl] as! String))
            
        }
        else
        {
            self.profilePicture.image = UIImage(systemName: Keys.personWithCircle)
            profilePicture.backgroundColor = .white
        }
        
    }
    
    @objc func openGallery(_ tapGesture: UITapGestureRecognizer){
        self.setUpImagePicker()
    }
}

extension UserProfileViewController{
    private func viewStyle(view: UIView){
        view.layer.cornerRadius = 30
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        view.layer.shadowOpacity = 0.4
        view.layer.shadowRadius = 6.0
    }
    
    private func textViewStyle(textView: UIView){
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        textView.layer.borderColor = UIColor.gray.cgColor
      
    }
    
    
    private func showLogoutAlert(){
        let currentUser = Manager.shared.auth.currentUser?.uid ?? ""
        let alert = UIAlertController(title: "", message: Keys.logoutAlertMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: {_ in}))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            var dict = UserDefaults.standard.dictionary(forKey: Keys.defaults)
            dict?[Keys.isLoggedIn] = false
            UserDefaults.standard.set(dict, forKey: Keys.defaults)
            Manager.shared.signout()
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
            self.navigationController?.pushViewController(vc!, animated: false)
        
            Manager.shared.online(uid: currentUser , status: false, success: {_ in
                })
        }))
        self.present(alert, animated: true)
    }
}



extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
        profilePicture.image = image
        self.dismiss(animated: true, completion: nil)
    }
}
