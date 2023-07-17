//
//  ChatRoomNavigationBarView.swift
//  Chat
//
//  Created by Geetika on 15/07/23.
//

import UIKit

class ChatRoomNavigationBarView: UIView {

    @IBOutlet var navigationBarView: UIView!
    
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }

    required init?(coder: NSCoder) {
           super.init(coder: coder)
           initSubviews()
       }


       
        func initSubviews() {
            let nib = UINib(nibName: "ChatRoomNavigationBarView", bundle: nil)
            nib.instantiate(withOwner: self, options: nil)
            navigationBarView.frame = bounds
            addSubview(navigationBarView)


        }


}
