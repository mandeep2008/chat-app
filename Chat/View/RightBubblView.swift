//
//  RightBubblView.swift
//  Chat
//
//  Created by Geetika on 19/05/23.
//

import UIKit

class RightBubblView: UITableViewCell {

    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    var bubbleTrailingConstraints : NSLayoutConstraint!
    var checkBoxTrailingConstraints : NSLayoutConstraint!
    static let identifier = "RightBubblView"
    static var nib: UINib {
           return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bubbleTrailingConstraints.isActive = false
        checkBoxTrailingConstraints.isActive = false
    }
    override func awakeFromNib() {
        
        super.awakeFromNib()
        bubbleViewStyle(view: bubbleView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func bubbleViewStyle(view: UIView){
        view.layer.cornerRadius = view.frame.height/3
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
    }
    func setConstraints(selectionEnable: Bool){
        if selectionEnable{
            bubbleTrailingConstraints = bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30)
            checkBoxTrailingConstraints = messageTime.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30)
            bubbleTrailingConstraints.isActive = true
            checkBoxTrailingConstraints.isActive = true

        }
        else{
            bubbleTrailingConstraints = bubbleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14)
            checkBoxTrailingConstraints = messageTime.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -14)
            bubbleTrailingConstraints.isActive = true
            checkBoxTrailingConstraints.isActive = true
        }
    }
    
}
