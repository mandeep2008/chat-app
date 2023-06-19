//
//  RightBubblView.swift
//  Chat
//
//  Created by Geetika on 19/05/23.
//

import UIKit
import FirebaseAuth

class BubbleView: UITableViewCell {

    @IBOutlet weak var messageTime: UILabel!
    @IBOutlet weak var checkBox: UIImageView!
    @IBOutlet weak var message: UILabel!

    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var messageView: UIView!
    var bubbleTrailingConstraints : NSLayoutConstraint?
    var bubbleLeadingConstraints : NSLayoutConstraint?
   
    var checkBoxTrailingConstraints : NSLayoutConstraint?
    var checkBoxLeadingConstraints : NSLayoutConstraint?
    
    var messageTimeLeadingConstraints : NSLayoutConstraint?
    var messageTimeTrailingConstraints : NSLayoutConstraint?
    
    static let identifier = "BubbleView"
    static var nib: UINib {
           return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bubbleTrailingConstraints?.isActive = false
        bubbleLeadingConstraints?.isActive = false

        
        checkBoxTrailingConstraints?.isActive = false
        checkBoxLeadingConstraints?.isActive = false
        
        messageTimeLeadingConstraints?.isActive = false
        messageTimeTrailingConstraints?.isActive = false
    }
    override func awakeFromNib() {
        
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    
    func updateBubblePosition(senderId: String, selectionEnable: Bool, chatType: String){
        if senderId == Auth.auth().currentUser?.uid{
            messageView.layer.cornerRadius = messageView.frame.height/3
            messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            messageView.layer.backgroundColor = CGColor(red: 52/255, green: 199/255, blue: 89/255, alpha: 1)
            
            checkBoxTrailingConstraints = checkBox.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5)
            checkBoxTrailingConstraints?.isActive = true

            rightBubbleConstraints(value: selectionEnable ? -30 : -14)
        }
        else
        {
            messageView.layer.cornerRadius = messageView.frame.height/3
            messageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            messageView.layer.backgroundColor = CGColor(red: 229/255, green: 229/255, blue: 234/255, alpha: 1)
            
            checkBoxLeadingConstraints = checkBox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5)
            checkBoxLeadingConstraints?.isActive = true

            leftBubbleConstraints(value: selectionEnable ? 30 : 14)
            if chatType == "group"{
                senderName.isHidden = false
            }
            
        }
        
    }
    
    //MARK: right bubble constraints
    
    func rightBubbleConstraints(value: CGFloat){
        bubbleTrailingConstraints = messageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: value)
        messageTimeTrailingConstraints = messageTime.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: value)
        bubbleTrailingConstraints?.isActive = true
        messageTimeTrailingConstraints?.isActive = true
    
    }
    
    //MARK: left bubble constraints
    func leftBubbleConstraints(value: CGFloat){
        bubbleLeadingConstraints = messageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: value)
        messageTimeLeadingConstraints = messageTime.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: value)
        bubbleLeadingConstraints?.isActive = true
        messageTimeLeadingConstraints?.isActive = true
    }
    

    
}
