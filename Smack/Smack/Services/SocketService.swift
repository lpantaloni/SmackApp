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
        self.socket.emit("newChannel", "TESTLPA", "TESTLPA")
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
    
}
