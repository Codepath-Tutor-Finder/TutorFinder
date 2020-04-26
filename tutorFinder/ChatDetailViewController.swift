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
    
    var currentUser : PFUser!
    var otherUser : PFUser!
    var currentChat : PFObject!
    var messages = [PFObject]()

    var currentUsername = "Self"
    var otherUsername = "Other user"

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
        
        let query = PFQuery(className: "Chats")
        print(self.currentUser!)
        print(self.otherUser!)
        
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
        print(otherUser)
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
        query.order(byAscending: "createdAt")
        query.limit = 20
        
        query.findObjectsInBackground { (messages, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                let messages = messages!
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
            print(self.messages)
            self.conversationTable.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Rows: \(messages.count)")
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Row: \(indexPath.row)")
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

        cell.bubbleView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        cell.bubbleView.layer.cornerRadius = 16
        cell.bubbleView.clipsToBounds = true
        cell.bubbleView.sizeToFit()
        cell.bubbleView.layoutIfNeeded()

        if currentUser!.objectId == sender.objectId {
            cell.user.textAlignment = .right
            cell.message.textAlignment = .right
        }

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

    @IBAction func onSendMessage(_ sender: Any) {
        if let newMessage = textField.text {

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
            }

            if self.messages.count == 0 {

                // Create and save a new Chat object
                let chat = PFObject(className: "Chats")
                chat["users"] = [currentUser, otherUser]
                chat["lastMessage"] = message
                chat["messages"] = [message]
                print(chat)
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
                //currentChat["lastMessage"] = textField.text
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
//            conversationTable.reloadData()
            textField.text = nil
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
