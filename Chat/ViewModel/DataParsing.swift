//
//  DataParsing.swift
//  Chat
//
//  Created by Geetika on 01/06/23.
//

import Foundation

class DataParsing{
    
    func decodeData<T: Codable>(response: [[String:Any]],model: T.Type, completion: @escaping(_ result: Codable)-> Void){
        do{
            let data = try JSONSerialization.data(withJSONObject: response)
            let json = try JSONDecoder().decode(model.self, from: data)
            completion(json)
        }
        catch{
            print(error.localizedDescription)
        }
    }
}
