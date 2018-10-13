//
//  SocketService.swift
//  Smack
//
//  Created by Laurent Pantaloni on 08/10/2018.
//  Copyright © 2018 Laurent Pantaloni. All rights reserved.
//

import UIKit
import SocketIO


class SocketService: NSObject {
    
    static let instance = SocketService()
    
    override init() {
        super.init()
    }
    
    static let manager = SocketManager(socketURL: URL(string: BASE_URL)!)
    var socket  = manager.defaultSocket
//    var socket : SocketIOClient = manager.defaultSocket
    
    func establishConnection() {
        socket.connect()
    }

    func closeConnection() {
        socket.disconnect()
    }
    
    func addChannel(channelName: String, channelDescription: String, completion: @escaping CompletionHandler) {
//        debugPrint(self.socket.status)
//        self.socket.connect(timeoutAfter: 2000) {
//            debugPrint("Connect with timeout : \(self.socket.status)")
//        }
        self.socket.emit("newChannel", channelName, channelDescription)
//        debugPrint("New Channel \(channelName)")
//        debugPrint(self.socket.status)
        completion(true)
        
    }
    
    func getChannel(completion: @escaping CompletionHandler) {
        socket.on("channelCreated") { (dataArray, ack) in
            guard let channelName = dataArray[0] as? String else {return}
            guard let channelDesc = dataArray[1] as? String else {return}
            guard let channelID = dataArray[2] as? String else {return}

            let newChannel  = Channel(channelTitle: channelName, channelDescription: channelDesc, id: channelID)
            MessageService.instance.channels.append(newChannel)
//            debugPrint("ChannelCreated \(channelName)")
            completion(true)
        }
    }
    
    func addMessage(messageBody: String, userId: String, channelId: String, completion: @escaping CompletionHandler) {
        let user = UserDataService.instance
        
        self.socket.emit("newMessage", messageBody, userId, channelId, user.name, user.avatarName, user.avatarColor)
        
        completion(true)
        
    }
    
    func getChatMessage(completion: @escaping CompletionHandler) {
        socket.on("messageCreated") { (dataArray, ack) in
            guard let msgBody = dataArray[0] as? String else { return }
//            guard let userId = dataArray[1] as? String else { return }
            guard let channelId = dataArray[2] as? String else { return }
            guard let userName = dataArray[3] as? String else { return }
            guard let userAvatar = dataArray[4] as? String else { return }
            guard let userAvatarColor = dataArray[5] as? String else { return }
            guard let id = dataArray[6] as? String else { return }
            guard let timeStamp = dataArray[7] as? String else { return }

            if channelId == MessageService.instance.selectedChannel?.id && AuthService.instance.isLoggedIn {
                let newMessage = Message.init(message: msgBody, userName: userName, channelID: channelId, userAvatar: userAvatar, userAvatarColor: userAvatarColor, id: id, timeStamp: timeStamp)
                MessageService.instance.messages.append(newMessage)
                completion(true)
            } else {
                completion(false)
            }

//            let newMessage = Message( message: ,   userName: ,  channelID: ,  userAvatar: ,  userAvatarColor: ,  id:  timeStamp: String!)
        }
    }
}
