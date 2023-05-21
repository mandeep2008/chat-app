//
//  SignupViewController.swift
//  Chat
//
//  Created by Geetika on 04/05/23.
//

import UIKit

class SignupViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var name: UITextField!
   
    @IBOutlet weak var signUpButton: UIButton!
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        CommonViews.shared.profileImageStyle(profileImage: profile)
        let tapGesture = UITapGestureRecognizer()
        tapGesture.addTarget(self, action: #selector(self.openGallery(tapGesture:)))
        profile.addGestureRecognizer(tapGesture)
        CommonViews.shared.signUpLoginButtonStyle(button: signUpButton)

    }
    

   
    
    @IBAction func signUp(_ sender: Any) {
        if email.text != nil && password.text != nil{
            StorageManager.shared.UploadImage(image: profile.image!){ url in
                print(url )
                Manager.shared.signup(email: self.email.text!, password: self.password.text!, name: self.name.text ?? "", profileUrl: url){ success in
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
            }


        }
    }
    
    @IBAction func selectProfileImageButton(_ sender: Any) {
        self.setUpImagePicker()
    }
    
    @objc func openGallery(tapGesture: UITapGestureRecognizer){
        self.setUpImagePicker()
    }
}



extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
        profile.image = image
        self.dismiss(animated: true, completion: nil)
    }
}
