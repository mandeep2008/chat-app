//
//  AddGroupDetailsViewController.swift
//  Chat
//
//  Created by Geetika on 13/06/23.
//

import UIKit

class Participants: UICollectionViewCell{
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var profile: UIImageView!
}
class AddGroupDetailsViewController: UIViewController {

    @IBOutlet weak var participantsCollection: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.participantsCollection.dataSource = self
        self.participantsCollection.delegate = self

    }
    

   

}

extension AddGroupDetailsViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = participantsCollection.dequeueReusableCell(withReuseIdentifier: "Participants", for: indexPath) as? Participants else {
            return UICollectionViewCell()
        }
        return cell
    }
    
    
}
//extension AddGroupDetailsViewController:UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView,
//          layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 200, height: 200)
//    }
//
//}
