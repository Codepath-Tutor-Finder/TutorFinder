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
    
    var currentUser = PFUser.current()
    var otherUser : PFUser!
    var currentChat : PFObject!
    var messages = [PFObject]()

    var currentUsername = "Self"
    var otherUsername = "Other user"

    @IBOutlet weak var textField: UITextField!

    @IBOutlet weak var conversationTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Did appear")
        conversationTable.delegate = self
        conversationTable.dataSource = self

//        conversationTable.estimatedRowHeight = 150
//        conversationTable.rowHeight = UITableView.automaticDimension
        conversationTable.rowHeight = 130
        conversationTable.separatorStyle = .none

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUsers()
        loadMessages()
    }
    func loadUsers() {
        print("Inside load users")
        let query1 = PFQuery(className: "Profiles")
        query1.whereKey("author", equalTo: currentUser)
        query1.findObjectsInBackground { (users, error) in
            if let users = users {
                self.otherUsername = users[0]["name"] as! String
            }
        }
        
        print("After query 1")

        let query2 = PFQuery(className: "Profiles")
        query2.whereKey("author", equalTo: otherUser)
        query2.findObjectsInBackground { (users, error) in
            if let users = users {
                self.currentUsername = users[0]["name"] as! String
            }
        }
        print("After query 2")
    }

    func loadMessages() {
        print("Inside load messages")
        
        // Create a query
        let query = PFQuery(className: "Chats")
        print(self.currentUser)
        // Retrieve Chat (only one) whereKey "users" include currentUser and otherUser
        query.whereKey("users", containsAllObjectsIn:[self.currentUser!])
        query.order(byDescending: "createdAt")

        print("to retrieve")
        // Retrieve the Chat
        query.findObjectsInBackground { (chats, error) in
            if chats == nil {
                print("It's nil")
            } else {
                if chats!.count != 0 {
                    print("not empty chat")
                    self.currentChat = chats![0]
                    //                let messagesArray = self.currentChat["messages"] as! [PFObject]
                    //                let sliceArray = messagesArray.suffix(20)
                    //                self.messages = Array(sliceArray)
                    self.messages = self.currentChat["messages"] as! [PFObject]
                    self.conversationTable.reloadData()
                } else if error != nil {
                    print("error")
                    print(error!.localizedDescription)
                } else {
                    print("empty chat")
                    self.messages = []
                    self.conversationTable.reloadData()
                }
                print(self.messages)
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
