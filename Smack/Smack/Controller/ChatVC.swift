//
//  ChatVC.swift
//  Smack
//
//  Created by Laurent Pantaloni on 18/09/2018.
//  Copyright © 2018 Laurent Pantaloni. All rights reserved.
//

import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // Outlets
    @IBOutlet weak var menuBtn: UIButton!
    
    @IBOutlet weak var channelNameLbl: UILabel!
    @IBOutlet weak var messageTxtBox: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendBtn: UIButton!
    
    //Variables
    var isTyping = false
    
    @IBAction func messageBoxEditing(_ sender: Any) {
        if messageTxtBox.text == "" {
            isTyping = false
            sendBtn.isHidden = true
        } else {
            if isTyping == false {
                sendBtn.isHidden = false
            }
            isTyping = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.bindToKeyboard()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        sendBtn.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ChatVC.handleTap))

        self.view.addGestureRecognizer(tap)
        menuBtn.addTarget(self.revealViewController(), action: #selector(SWRevealViewController.revealToggle(_:)), for: .touchUpInside)
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.userDataDidChange(_:)), name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.channelSelected(_:)), name: NOTIF_CHANNEL_SELECTED, object: nil)

        SocketService.instance.getChatMessage { (success) in
            if success {
                self.tableView.reloadData()
                if MessageService.instance.messages.count > 0 {
                    let endIndex = IndexPath(row: MessageService.instance.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: endIndex, at: .bottom, animated: false)
                }
            }
        }

        if AuthService.instance.isLoggedIn {
            AuthService.instance.findUserByEmail { (success) in
                NotificationCenter.default.post(name: NOTIF_USER_DATA_DID_CHANGE, object: nil)
            }
        }
        MessageService.instance.findAllChannel { (success) in
            debugPrint("Hello World")
        }
    }
    
    @objc func userDataDidChange(_ notif: Notification) {
        if AuthService.instance.isLoggedIn {
            // get channels
            onLoginGetMessages()
        } else {
            channelNameLbl.text = "Please Log In"
            tableView.reloadData()
        }
    }
    
    @objc func channelSelected(_ notif: Notification) {
        updateWithChannel()
        
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
    func updateWithChannel() {
        // fille the chat window
        let channelName = MessageService.instance.selectedChannel?.channelTitle ?? ""
        channelNameLbl.text = "#\(channelName)"
        getMessages()
        
    }

    @IBAction func sendMessagePressed(_ sender: Any) {
        if AuthService.instance.isLoggedIn {
            guard let channelID = MessageService.instance.selectedChannel?.id else { return }
            guard let message = messageTxtBox.text else { return }
            SocketService.instance.addMessage(messageBody: message, userId: UserDataService.instance.id, channelId: channelID) { (success) in
                if success {
                    self.messageTxtBox.text = ""
                    self.messageTxtBox.resignFirstResponder()
                }
            }
        }
        
    }
    
    func onLoginGetMessages() {
        MessageService.instance.findAllChannel { (success) in
            if success {
                // do stuff with channels
                if MessageService.instance.channels.count > 0 {
                    MessageService.instance.selectedChannel = MessageService.instance.channels[0]
                    self.updateWithChannel()
                } else {
                    self.channelNameLbl.text = "No channel yet"
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMessages() {
        guard let channelID = MessageService.instance.selectedChannel?.id else { return }
        MessageService.instance.findAllMessagesForChannel(channelID: channelID) { (success) in
            if success {
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell {
            let message = MessageService.instance.messages[indexPath.row]
            cell.configureCell(message: message)
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MessageService.instance.messages.count
    }

}
