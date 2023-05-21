//
//  LeftBubbleView.swift
//  Chat
//
//  Created by Geetika on 19/05/23.
//

import UIKit

class LeftBubbleView: UITableViewCell {

    @IBOutlet weak var receiveMsg: UILabel!
    @IBOutlet weak var leftBubble: UIView!
    
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var messageTime: UILabel!
    
    var bubbleLeadingConstraints : NSLayoutConstraint!
    var checkBoxLeadingConstraints : NSLayoutConstraint!
    
    static let identifier = "LeftBubbleView"
    static var nib: UINib {
           return UINib(nibName: String(describing: self), bundle: nil)
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        

        bubbleLeadingConstraints.isActive = false

        checkBoxLeadingConstraints.isActive = false
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bubbleViewStyle(view: leftBubble)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bubbleViewStyle(view: UIView){
        view.layer.cornerRadius = view.frame.height/3
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
    }
    func setConstraints(selectionEnable: Bool){
        if selectionEnable{
            bubbleLeadingConstraints = leftBubble.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30)
            checkBoxLeadingConstraints = messageTime.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30)
            bubbleLeadingConstraints.isActive = true
            checkBoxLeadingConstraints.isActive = true

        }
        else{
            bubbleLeadingConstraints = leftBubble.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14)
            checkBoxLeadingConstraints = messageTime.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 14)
            bubbleLeadingConstraints.isActive = true
            checkBoxLeadingConstraints.isActive = true
        }
    }
  
}
