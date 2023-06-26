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
    
    var messageTimeTrailingConstraints : NSLayoutConstraint?
    
    var topSpaceForMessage : NSLayoutConstraint?

    static let identifier = "BubbleView"
    static var nib: UINib {
           return UINib(nibName: String(describing: self), bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bubbleTrailingConstraints?.isActive = false
        bubbleLeadingConstraints?.isActive = false

        topSpaceForMessage?.isActive = false
        
        checkBoxTrailingConstraints?.isActive = false
        checkBoxLeadingConstraints?.isActive = false
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

            topSpaceForMessage = message.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 6)
            topSpaceForMessage?.isActive = true
            

            rightBubbleConstraints(value: selectionEnable ? -30 : -14)
            senderName.isHidden = true
        }
        else
        {
            messageView.layer.cornerRadius = messageView.frame.height/3
            messageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMaxXMinYCorner]
            messageView.layer.backgroundColor = CGColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1)
            
            checkBoxLeadingConstraints = checkBox.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5)
            checkBoxLeadingConstraints?.isActive = true

            leftBubbleConstraints(value: selectionEnable ? 30 : 14)
           
            if chatType == "group"{
                senderName.isHidden = false
                senderName.textColor = randomColor()
                topSpaceForMessage = message.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 18)
                topSpaceForMessage?.isActive = true
                
               
            }
            else{
                topSpaceForMessage = message.topAnchor.constraint(equalTo: messageView.topAnchor, constant: 6)
                topSpaceForMessage?.isActive = true
            }
            
        }
        
    }
    
    //MARK: right bubble constraints
    
    func rightBubbleConstraints(value: CGFloat){
        bubbleTrailingConstraints = messageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: value)
        bubbleTrailingConstraints?.isActive = true
    
    }
    
    //MARK: left bubble constraints
    func leftBubbleConstraints(value: CGFloat){
        bubbleLeadingConstraints = messageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: value)
        bubbleLeadingConstraints?.isActive = true
    }
    
    func randomColor() -> UIColor{
        let red = CGFloat(drand48())
        let green = CGFloat(drand48())
        let blue = CGFloat(drand48())
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}
