//
//  CommonViews.swift
//  Chat
//
//  Created by Geetika on 17/05/23.
//

import Foundation
import UIKit

extension UITextField{
    
    @IBInspectable var doneAccessory: Bool{
        get{
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone{
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
  @objc func doneButtonAction()
    {
        self.resignFirstResponder()
    }
}


extension UIViewController{
    
    func profileImageStyle(profileImage: UIImageView){
        profileImage.layer.borderWidth = 1.0
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.white.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
    }
    func signUpLoginButtonStyle(button: UIButton){
        button.layer.shadowColor = UIColor.darkGray.cgColor
        button.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        button.layer.shadowOpacity = 0.4
        button.layer.shadowRadius = 6.0
        button.layer.cornerRadius = button.frame.height/2
    }
    
    // global alert---
    enum alertType{
        case error, logout , delete
    }
    
    func showAlert(message: String, title: String = "Alert", actionStyle: UIAlertAction.Style, alertType: alertType){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        switch(alertType){
        case .error:
            let action1 = UIAlertAction(title: "OK", style: actionStyle, handler: {_ in})
            alert.addAction(action1)
        case.logout:
            let action1 = UIAlertAction(title: "No", style: actionStyle, handler: {_ in})
            let action2 = UIAlertAction(title: "Yes", style: actionStyle, handler: {_ in})
            alert.addAction(action1)
            alert.addAction(action2)
        case.delete:
            let action1 = UIAlertAction(title: "No", style: actionStyle, handler: {_ in})
            let action2 = UIAlertAction(title: "Yes", style: actionStyle, handler: {_ in})
            alert.addAction(action1)
            alert.addAction(action2)
        }
        self.present(alert, animated: true, completion: nil)
    }
}


extension CGFloat {
    static var random: CGFloat {
           return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
extension UIColor {
    static var random: UIColor {
           return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
}
