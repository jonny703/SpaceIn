//
//  ChatHistoryController.swift
//  SpaceIn
//
//  Created by John Nik on 6/15/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import UIKit
import Firebase

class ChatHistoryController: UIViewController {
    
    let cellId = "cellId"
    
    var timer: Timer?
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    fileprivate var viewAppeared = false
    
    //MARK set UI
    
    fileprivate let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.light))
    
    lazy var tableView: UITableView = {
        
        var tableView = UITableView();
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 70
        
        return tableView;
    }()
    
    let backButton: UIButton = {
        
        let button = UIButton(type: .system)
        let image = UIImage(named: AssetName.dismissX.rawValue)
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        button.tintColor = .white
        return button
        
    }()

    func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupViews()
        fetchUsersAndMessages()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    
    
    fileprivate func showChatControllerForUser(user: SpaceUser, indexPath: IndexPath) {
        
        let chatOnebyOneController = ChatOnebyOneController()
        chatOnebyOneController.chatUser = user
        chatOnebyOneController.indexPath = indexPath
        chatOnebyOneController.chatHistoryController = self
        chatOnebyOneController.modalPresentationStyle = .overCurrentContext
        chatOnebyOneController.modalTransitionStyle = .crossDissolve
        self.present(chatOnebyOneController, animated: false, completion: nil)
        
    }
    
    
}


//MARK: tableview delegate

extension ChatHistoryController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        self.sendPostReadMessage(message)
        
        if let chatPartnerId = message.chatPartnerId() {
            let ref = Database.database().reference().child("user-messages").child(uid).child(chatPartnerId)
            ref.removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                
                
                self.messagesDictionary.removeValue(forKey: chatPartnerId)
                self.attemptReloadTable()
                
                let lastSeenTimeStamp = NSDate().timeIntervalSince1970 as NSNumber
                ref.updateChildValues(["lastSeenTimeStamp": lastSeenTimeStamp] as [String: AnyObject])
                
                //                //this is oone way of updating the table, but its actually not that safe.
                //                self.messages.remove(at: indexPath.row)
                //                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
            })
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cellId")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatHistoryCell
        
        
        let message = messages[indexPath.row]
        
        cell.message = message
        
        cell.setNeedsDisplay()
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let message = messages[indexPath.row]
        
        self.reloadTableViewForBadgeAtIndex(indexPath)
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            //            print(snapshot)
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = SpaceUser()
            
            user.userId = chatPartnerId
            
            user.setValuesForKeys(dictionary)
            
            self.showChatControllerForUser(user: user, indexPath: indexPath)
            
        }, withCancel: nil)
        
    }
    
    private func sendPostReadMessage(_ message: Message) {
        if let messagesCount = message.newMessageCount {
            let dictionaryData = ["readMessages": messagesCount] as [String: AnyObject]
            let nc = NotificationCenter.default
            nc.post(name: .setPushLabelReadMessages, object: nil, userInfo: dictionaryData)
        }
    }
    
    func reloadTableViewForBadgeAtIndex(_ indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        self.sendPostReadMessage(message)
        
        message.newMessageCount = nil
        let indexPath = IndexPath(row: indexPath.row, section: indexPath.section)
        tableView.reloadRows(at: [indexPath], with: .none)
        
    }

    
}

//MARK: setup Background

extension ChatHistoryController {
    
    fileprivate func setupBackground() {
        setupBackgroundView()
        addBlurEffectViewFrame()
    }
    
    fileprivate func setupBackgroundView() {
        guard viewAppeared == false else { return }
        
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            view.backgroundColor = UIColor.clear
            
            //always fill the view
            
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.insertSubview(blurEffectView, at: 0)
            blurEffectView.frame = CGRect(x: view.frame.width / 2, y: view.frame.height / 2, width: 0, height: 0)
            self.modalPresentationCapturesStatusBarAppearance = false
        } else {
            view.backgroundColor = .clear
        }
    }
    
    fileprivate func addBlurEffectViewFrame() {
        guard viewAppeared == false else { return }
        
        self.blurEffectView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
    }

    
}

//MARK: setup Views

extension ChatHistoryController {
    
    fileprivate func setupViews() {
        setupBackButton()
        setupTableView()
    }
    
    fileprivate func setupBackButton() {
        view.addSubview(backButton)
        
        backButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 25).isActive = true
        backButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
    }
    
    fileprivate func setupTableView() {
        view.addSubview(tableView)
        
        tableView.widthAnchor.constraint(equalToConstant: DEVICE_WIDTH * 0.8).isActive = true
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 15).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        
        
        tableView.register(ChatHistoryCell.self, forCellReuseIdentifier: cellId)
        
        tableView.allowsMultipleSelectionDuringEditing = true
    }

    
}

//MARK: fetch users and messages

extension ChatHistoryController {
    
    fileprivate func fetchUsersAndMessages() {
        
        
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
    }
    
    fileprivate func observeUserMessages() {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            ref.child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadTable()
            
        }, withCancel: nil)
        
    }
    
    fileprivate func attemptReloadTable() {
        
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        
    }
    
    
    
    @objc fileprivate func handleReloadTable() {
        
        self.messages = Array(self.messagesDictionary.values)
        
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.intValue)! > (message2.timestamp?.intValue)!
            
        })
        
        var newMessageCount = 0
        for message in self.messages {
            if let count = message.newMessageCount {
                newMessageCount += count
            }
        }
        
        let dictionaryData = ["newMessages": newMessageCount] as [String: AnyObject]
        let nc = NotificationCenter.default
        nc.post(name: .setPushLabelNewMessages, object: nil, userInfo: dictionaryData)
        
        DispatchQueue.main.async {
            print("reload table")
            self.tableView.reloadData()
        }
        
    }
    
    fileprivate func fetchMessageWithMessageId(messageId: String) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let messageReference = Database.database().reference().child("messages").child(messageId)
        messageReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let message = Message(dictionary: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    
                    let ref = Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).child("lastSeenTimeStamp")
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        
                        if let lastSeenTimeStamp = snapshot.value as? NSNumber {
                            
                            if chatPartnerId == message.fromId {
                                if (message.timestamp?.doubleValue)! > lastSeenTimeStamp.doubleValue {
                                    
                                    if let _ = self.messagesDictionary[chatPartnerId]?.newMessageCount {
                                        message.newMessageCount = self.messagesDictionary[chatPartnerId]!.newMessageCount! + 1
                                    } else {
                                        message.newMessageCount = 1
                                    }
                                }
                            }
                            self.messagesDictionary[chatPartnerId] = message
                            self.attemptReloadTable()
                        }
                    })
                }
            }
            
        }, withCancel: nil)
    }

    
}












