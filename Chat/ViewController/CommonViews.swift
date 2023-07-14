//
//  CommonViews.swift
//  Chat
//
//  Created by Geetika on 17/05/23.
//

import Foundation
import UIKit

extension UIViewController{
    
    func profileImageStyle(profileImage: UIImageView){
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.contentMode = .scaleAspectFill
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
    
    func showAlert(message: String,
                   title: String = "Alert",
                   actionStyle: UIAlertAction.Style){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: actionStyle, handler: {_ in})
              alert.addAction(action)

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

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

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


//extension UITextField{
//    func isValid(email: String) -> String
//    {
//        var returnValue = "Valid Email"
//        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
//        let regex = try! NSRegularExpression(pattern: emailRegEx)
//        let nsRange = NSRange(location: 0, length: email.count)
//        let results = regex.matches(in: email, range: nsRange)
//        if results.count == 0
//        {
//            returnValue = "Invalid Email"
//        }
//        return  returnValue
//    }
//}


