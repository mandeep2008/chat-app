//
//  CustomHeaderViewForParticipantsList.swift
//  Chat
//
//  Created by Geetika on 22/06/23.
//

import UIKit

class CustomHeaderViewForParticipantsList: UITableViewHeaderFooterView {

    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var addUser: UIButton!
    var buttonTapped = false
    
    @IBAction func addUsersInGroupButton(_ sender: Any) {
     
       buttonTapped = true
    }
    
    
    
}
