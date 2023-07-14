//
//  LoginViewController.swift
//  Chat
//
//  Created by Geetika on 04/05/23.
//

import UIKit


class LoginViewController: UIViewController {
    
   @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var eyeImageView: UIImageView!
    @IBOutlet weak var passwordView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var showPswd = false
    override func viewDidLoad() {
        super.viewDidLoad()
       loader.isHidden = true
        let dict = UserDefaults.standard.dictionary(forKey: Keys.defaults)
        
        if ((dict?[Keys.isLoggedIn] as? Bool) == true){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConversationsViewController") as? ConversationsViewController
            navigationController?.pushViewController(vc!, animated: false)
        }
        
        self.passwordViewStyle(view: passwordView)

        let tap = UITapGestureRecognizer(target: self, action: #selector(showPswd(_:)))
        eyeImageView.addGestureRecognizer(tap)
        self.signUpLoginButtonStyle(button: loginButton)
       
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    

    @IBAction func login(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != ""{
           loader.isHidden = false
            Manager.shared.login(email: emailTextField.text!, password: passwordTextField.text!){ success,error  in
                if success{
                  self.loader.isHidden = true
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConversationsViewController") as? ConversationsViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
                else{
                   self.loader.isHidden = true
                    self.showAlert(message: error, actionStyle: .default)
                }
                
            }
        }
        else{
            if ((emailTextField.text?.isEmpty) != nil) {
                self.showAlert(message: "Email required", actionStyle: .default)
            }
            else if ((passwordTextField.text?.isEmpty) != nil) {
                self.showAlert(message: "Password required", actionStyle: .default)
            }
        }
        
     
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @objc func showPswd(_ tapGesture: UITapGestureRecognizer){
        self.showPswd.toggle()
        eyeImageView.image = self.showPswd ? (UIImage(systemName: "eye.fill")) : (UIImage(systemName: "eye.slash.fill"))
        passwordTextField.isSecureTextEntry = self.showPswd ? false : true
    }
    private func passwordViewStyle(view: UIView){
        view.layer.borderColor = UIColor.systemGray6.cgColor
        view.layer.borderWidth = 1
        view.layer.cornerRadius = 6
    }
}


