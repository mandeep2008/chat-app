//
//  ContactListCellTableViewCell.swift
//  Chat
//
//  Created by Geetika on 13/06/23.
//

import UIKit

class ContactListCell: UITableViewCell {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var radioButton: UIImageView!
    
    var nameTrailingConstraints: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        nameTrailingConstraints.isActive = false

       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func showRadioButton(selectionEnable: Bool){
        radioButton.isHidden = selectionEnable ? false : true
    }
}
