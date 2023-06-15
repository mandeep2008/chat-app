//
//  UserList.swift
//  Chat
//
//  Created by Geetika on 14/06/23.
//

import UIKit

class UserList: UITableViewCell {
    
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var radioButton: UIImageView!
    
    static let identifier = "UserList"
    static var nib: UINib {
           return UINib(nibName: String(describing: self), bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
