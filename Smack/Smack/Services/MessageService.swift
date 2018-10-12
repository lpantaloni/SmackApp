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
    var messages = [Message]()
    var selectedChannel : Channel?
    
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
//                            print(self.channels[0].channelTitle)
                            NotificationCenter.default.post(name: NOTIF_CHANNELS_LOADED, object: nil)
                            
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
    
    func findAllMessagesForChannel(channelID: String, completion: @escaping CompletionHandler) {
        Alamofire.request("\(URL_GET_MESSAGES)\(channelID)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER).responseJSON { (response) in
            if response.result.error == nil {
                self.clearMessages()
                
                // parsing the data
                guard let data = response.data else { return }
                do {
                    if let json = try JSON(data: data).array {
                        for item in json {
                            let messageBody = item["messageBody"].stringValue
                            let channelId = item["channelId"].stringValue
                            let id = item["_id"].stringValue
                            let userName = item["userName"].stringValue
                            let userAvatar = item["userAvatar"].stringValue
                            let userAvatarColor = item["userAvatarColor"].stringValue
                            let timeStamp = item["timeStamp"].stringValue
                            
                            let message = Message(message: messageBody, userName: userName, channelID: channelId, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timeStamp: timeStamp)
                            self.messages.append(message)
                            
                            debugPrint(message)
                        }
                        debugPrint(self.messages)
                        completion(true)
                    }
                } catch {
                        return
                    }
                
            } else {
                debugPrint("Error.....")
                debugPrint(response.result.error as Any)
                completion(false)
            }
            
        }
    }
    
    func clearMessages() {
        messages.removeAll()
    }
    
    
    func clearChannels() {
        channels.removeAll()
    }
}

