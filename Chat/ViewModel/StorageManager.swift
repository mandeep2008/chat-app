//
//  FBStorageManager.swift
//  Chat
//
//  Created by Geetika on 15/05/23.
//

import Foundation
import Firebase
import FirebaseStorage
import UIKit


class StorageManager{
    static let shared = StorageManager()
    
    let storageRef = Storage.storage().reference()
    func UploadImage(image: UIImage, completion: @escaping(_ url: String)-> Void)
        {
            let imagenode = storageRef.child("\(UUID().uuidString)")
            imagenode.putData(image.pngData()!,metadata: nil ,completion: {_ , error in
                guard error == nil else{
                    print("failed")
                    return
                }
                imagenode.downloadURL(completion: {url, error  in
                    guard error == nil else{
                        return
                    }
                    completion(url!.absoluteString)
                })
                
                
            })
        }
}

