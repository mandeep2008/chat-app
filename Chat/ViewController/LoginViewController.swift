//
//  LoginViewController.swift
//  Chat
//
//  Created by Geetika on 04/05/23.
//

import UIKit


class LoginViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dict = UserDefaults.standard.dictionary(forKey: Keys.defaults)
        if ((dict?[Keys.isLoggedIn] as? Bool) == true){
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConversationsViewController") as? ConversationsViewController
            navigationController?.pushViewController(vc!, animated: false)
        }
        
        CommonViews.shared.signUpLoginButtonStyle(button: loginButton) 
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
        if email.text != nil && password.text != nil{
            Manager.shared.login(email: email.text!, password: password.text!){ success in
                if success{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ConversationsViewController") as? ConversationsViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                }
                
            }
        }
    }
    
    
    @IBAction func signUp(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as? SignupViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}
