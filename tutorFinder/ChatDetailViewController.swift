//
//  ChatDetailViewController.swift
//  TutorFinder
//
//  Created by Han Nguyen on 4/7/20.
//  Copyright © 2020 Han Nguyen. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse
import MessageInputBar

class ChatDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {
    
    var currentUser : PFUser!
    var otherUser : PFUser!
    var currentChat : PFObject!
    var messages = [PFObject]()

    var currentUsername = "Self"
    var otherUsername = "Other user"

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var conversationTable: UITableView!
    
    @IBOutlet weak var firstContraint: NSLayoutConstraint!
    @IBOutlet weak var secondConstraint: NSLayoutConstraint!
    
    
    let commentBar = MessageInputBar()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPresentation = true

        conversationTable.delegate = self
        conversationTable.dataSource = self

        conversationTable.estimatedRowHeight = 100
        conversationTable.rowHeight =  UITableView.automaticDimension
        conversationTable.separatorStyle = .none
        
        let query = PFQuery(className: "Chats")
        
        // Retrieve Chat (only one) whereKey "users" include currentUser and otherUser
        query.whereKey("users", containsAllObjectsIn:[self.currentUser!, self.otherUser!])
        query.findObjectsInBackground { (chats, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if chats!.count != 0 {
                    self.currentChat = chats![0]
                }
            }
        }
        
        conversationTable.keyboardDismissMode = .interactive
        commentBar.sendButton.title = "Send"
        commentBar.delegate = self
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyBoardWillHide(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyBoardWillShow(note:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        //let tap = UITapGestureRecognizer(target: self, action: #selector(self.keyBoardWillShow(note:)))
        //commentBar.addGestureRecognizer(tap)
//        commentBar.inputTextView.addGestureRecognizer(tap)
    }
    
    @objc func tapHandler (_ sender: UITapGestureRecognizer? = nil) {
        print(commentBar.accessibilityPerformMagicTap())
        firstContraint.priority = .defaultLow
        secondConstraint.priority = .defaultHigh
        self.view.layoutIfNeeded()

    }
    
    @objc func keyBoardWillShow (note:Notification) {
        if commentBar.inputTextView.accessibilityPerformMagicTap() == true {
            firstContraint.priority = .defaultLow
            secondConstraint.priority = .defaultHigh
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyBoardWillHide (note:Notification) {
        firstContraint.priority = .defaultHigh
        secondConstraint.priority = .defaultLow
        self.view.layoutIfNeeded()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUsers()
        loadMessages()
    }
    func loadUsers() {
        let query1 = PFQuery(className: "Profiles")
        query1.whereKey("author", equalTo: currentUser!)
        query1.findObjectsInBackground { (users, error) in
            if let users = users {
                self.currentUsername = users[0]["name"] as! String
            } else {
                let error = error!
                print(error.localizedDescription)
            }
        }

        let query2 = PFQuery(className: "Profiles")
        query2.whereKey("author", equalTo: otherUser!)
        query2.findObjectsInBackground { (users, error) in
            if let users = users {
                self.otherUsername = users[0]["name"] as! String
                self.title = self.otherUsername
            } else {
                let error = error!
                print(error.localizedDescription)
            }
        }
    }

    func loadMessages() {
        print("Loading messages")
        
        let query1 =  PFQuery(className: "Messages")
        query1.whereKey("sender", equalTo: self.currentUser!)
        
        let query2 =  PFQuery(className: "Messages")
        query2.whereKey("sender", equalTo: self.otherUser!)
        
        let query = PFQuery.orQuery(withSubqueries: [query1, query2])
        query.order(byDescending: "createdAt")
        query.limit = 20
        
        query.findObjectsInBackground { (messages, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let messages = messages!.reversed()
                for message in messages {
                    let sender = message["sender"] as! PFUser
                    let receiver = message["receiver"] as! PFUser
                    
                    if sender.objectId == self.currentUser!.objectId {
                        if receiver.objectId == self.otherUser.objectId {
                            self.messages.append(message)
                        }
                    } else if sender.objectId == self.otherUser.objectId {
                        if receiver.objectId == self.currentUser!.objectId {
                            self.messages.append(message)
                        }
                    }
                }
            }
            self.conversationTable.reloadData()
            if self.messages.count >= 1 {
                let indexPath = NSIndexPath(row: self.messages.count-1, section: 0)
                print(indexPath)
                self.conversationTable.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.middle, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = conversationTable.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCellTableViewCell
        let cellMessage = messages[indexPath.row]
        let sender = cellMessage["sender"] as! PFUser
        let message = cellMessage["message"] as! String

        //cell.user.text = sender.username
        if sender.objectId == currentUser!.objectId {
            cell.user.text = currentUsername
        } else {
            cell.user.text = otherUsername
        }

        cell.message.text = message
        
        cell.bubbleView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        if currentUser!.objectId == sender.objectId {
            cell.bubbleView.backgroundColor = #colorLiteral(red: 0.3921568627, green: 0.7137254902, blue: 0.6745098039, alpha: 1)
            cell.message.textColor = #colorLiteral(red: 0.9882352941, green: 1, blue: 0.9921568627, alpha: 1)
//            cell.user.textAlignment = .right
//            cell.message.textAlignment = .right
        }
        
        let constraintRect = CGSize(width: 255, height: 1000)

        let boundingBox = cell.message.text!.boundingRect(with: constraintRect, options: .usesFontLeading, attributes: [.font: cell.message.font], context: nil)

        let messageSize = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))
        
        cell.message.frame.size = CGSize(width: ceil(boundingBox.width), height: ceil(boundingBox.height))

        let bubbleSize = CGSize(width: cell.message.frame.size.width + 20, height: cell.message.frame.size.height)

        let currentBubble = cell.bubbleView.frame.size

        cell.bubbleView.frame.size = CGSize(width: bubbleSize.width, height: currentBubble.height)
        
        cell.bubbleView.layer.cornerRadius = 12
        cell.bubbleView.clipsToBounds = true
        cell.bubbleView.sizeToFit()
        cell.bubbleView.layoutIfNeeded()

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

    @IBAction func onReturn(_ sender: Any) {
        self.dismiss(animated: true) {
            print("Return successful")
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //Create a message
        if let newMessage = commentBar.inputTextView.text {
            
            // Create and save a new Message object
            let message = PFObject(className: "Messages")
            message["sender"] = self.currentUser!
            message["receiver"] = self.otherUser!
            message["message"] = newMessage
            message.saveInBackground { (sucess, error) in
                if (sucess) {
                    print("Message saved")
                    self.messages.append(message)
                } else {
                    print("Error saving message")
                }
                
                self.conversationTable.reloadData()
                if self.messages.count >= 1 {
                    let indexPath = NSIndexPath(row: self.messages.count-1, section: 0)
                    print(indexPath)
                    self.conversationTable.scrollToRow(at: indexPath as IndexPath, at: UITableView.ScrollPosition.middle, animated: true)
                }
            }
            
            if self.messages.count == 0 {
                
                // Create and save a new Chat object
                let chat = PFObject(className: "Chats")
                chat["users"] = [currentUser, otherUser]
                chat["lastMessage"] = message
                chat["messages"] = [message]
                chat.saveInBackground { (sucess, error) in
                    if (sucess) {
                        print("New chat saved")
                        self.currentChat = chat
                        self.loadUsers()
                    } else {
                        print("Error saving new chat")
                    }
                }
            } else {
                
                // Update the current Chat object
                currentChat["lastMessage"] = message
                currentChat.add(message, forKey: "messages")
                currentChat.saveInBackground { (success, error) in
                    if (success) {
                        print("Chat saved")
                    } else {
                        print("Error saving chat")
                    }
                }
            }
        }
        // Clear and dismiss the input bar
        commentBar.inputTextView.text = nil
        commentBar.inputTextView.resignFirstResponder()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
