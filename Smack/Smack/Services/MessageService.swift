//
//  MessageService.swift
//  Smack
//
//  Created by Laurent Pantaloni on 05/10/2018.
//  Copyright © 2018 Laurent Pantaloni. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class MessageService {
    
    static let instance = MessageService()
    
    var channels = [Channel]()
    
    func findAllChannel(completion: @escaping CompletionHandler) {
        debugPrint("FIND ALL CHANNELS !!!!")
        Alamofire.request(URL_GET_CHANNELS, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.result.error == nil {
                guard let data = response.data else { return }
                debugPrint("Data retrieval is OK")

/*                do {
                    self.channels = try JSONDecoder().decode([Channel].self, from: data)
                    
                } catch {
                    debugPrint(error as Any)
                    
                }
                
                debugPrint("Channels :")
                print(self.channels)
*/
                do {
                        if let json = try JSON(data: data).array {
                        for item in json {
                            let name = item["name"].stringValue
                            let channelDescription = item["description"].stringValue
                            let id = item["_id"].stringValue
                            let channel = Channel(channelTitle: name, channelDescription: channelDescription, id: id)
                            self.channels.append(channel)
                        }
                            print(self.channels[0].channelTitle)
                            completion(true)
                    }
                } catch {
                    return
                }

                
            } else {
                completion (false)
                debugPrint(response.result.error as Any)
            }
        }
    }
}

