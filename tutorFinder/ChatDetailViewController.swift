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

class ChatDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var currentUser = PFUser()
    var otherUser = PFUser()
    
    var currentChat = PFObject()
    var messages = [PFObject]()
    
    var currentUsername = String()
    var otherUsername = String()
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var conversationTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conversationTable.delegate = self
        conversationTable.dataSource = self
        
//        conversationTable.estimatedRowHeight = 150
//        conversationTable.rowHeight = UITableView.automaticDimension
        conversationTable.rowHeight = 130
        conversationTable.separatorStyle = .none
        
        self.loadUsers()
        self.loadMessages()
        
    }
    
    func loadUsers() {
        let query1 = PFQuery(className: "Profiles")
        query1.whereKey("author", equalTo: currentUser)
        query1.includeKey("name")
        query1.findObjectsInBackground { (users, error) in
            if let users = users {
                self.otherUsername = users[0]["name"] as! String
            }
        }
        
        let query2 = PFQuery(className: "Profiles")
        query2.whereKey("author", equalTo: otherUser)
        query2.includeKey("name")
        
        query2.findObjectsInBackground { (users, error) in
            if let users = users {
                self.currentUsername = users[0]["name"] as! String
            }
        }
    }

    func loadMessages() {
        // Create a query
        let query = PFQuery(className: "Chats")
        
        // Retrieve Chat (only one) whereKey "users" include currentUser and otherUser
        query.whereKey("users", containsAllObjectsIn:[currentUser, otherUser])
        query.includeKey("messages")
        query.order(byDescending: "createdAt")
        query.limit = 20

        // Retrieve the Chat
        query.findObjectsInBackground { (chat, error) in
            if chat != nil {
                self.currentChat = chat![0]
                let messagesArray = self.currentChat["messages"] as! [PFObject]
                let sliceArray = messagesArray.suffix(20)
                self.messages = Array(sliceArray)
            } else if chat == nil {
                self.messages = []
            } else if let error = error {
                print(error.localizedDescription)
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
        
        cell.user.text = sender.username
        if sender == currentUser {
            cell.user.text = currentUsername
        } else {
             cell.user.text = otherUsername
        }
        
        cell.message.text = message
        
        cell.bubbleView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        cell.bubbleView.layer.cornerRadius = 16
        cell.bubbleView.clipsToBounds = true
        cell.bubbleView.sizeToFit()
        cell.bubbleView.layoutIfNeeded()
        
        if currentUser == sender {
            cell.user.textAlignment = .right
            cell.message.textAlignment = .right
        }
        
        return cell
    }
    
    @IBAction func onReturn(_ sender: Any) {
        self.dismiss(animated: true) {
            print("Return successful")
        }
    }
    
    @IBAction func onSendMessage(_ sender: Any) {
        if let newMessage = textField.text {
            
            // Create and save a new Message object
            let message = PFObject(className: "Messages")
            message["sender"] = currentUser
            message["receiver"] = otherUser
            message["message"] = newMessage
            message.saveInBackground { (sucess, error) in
                if (sucess) {
                    print("Message saved")
                } else {
                    print("Error saving message")
                }
                
            }
            
            if self.messages.count == 0 {
                
                // Create and save a new Chat object
                let chat = PFObject(className: "Chats")
                chat["users"] = [currentUser, otherUser]
                chat["lastMessage"] = newMessage
                chat["messages"] = [newMessage]
                chat.saveInBackground { (sucess, error) in
                    if (sucess) {
                        print("New chat saved")
                    } else {
                        print("Error saving new chat")
                    }
                }
            } else {
                
                // Update the current Chat object
                currentChat["lastMessage"] = textField.text
                currentChat.add(message, forKey: "messages")
                currentChat.saveInBackground { (success, error) in
                    if (success) {
                        print("Chat saved")
                    } else {
                        print("Error saving chat")
                    }
                }
            }
            textField.text = nil
            conversationTable.reloadData()
        }
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
