//
//  CommonViews.swift
//  Chat
//
//  Created by Geetika on 17/05/23.
//

import Foundation
import UIKit

class CommonViews{
    static let shared = CommonViews()
    
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
    
}
