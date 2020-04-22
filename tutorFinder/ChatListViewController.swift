//
//  ChatListViewController.swift
//  TutorFinder
//
//  Created by Han Nguyen on 4/5/20.
//  Copyright © 2020 Han Nguyen. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    let currentUser = PFUser.current()
    var otherUsers = [PFUser]()
    
    var chats = [PFObject]()
    var filteredChats = [PFObject]()
    var filteredUsers = [PFUser]()
    
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        chatSearchBar.delegate = self
        self.loadChats()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Load lists of chats
    }
    
    // Function to load lists of chats
    func loadChats() {
        let query = PFQuery(className: "Chats")
        
        // Retrieve chats whereKey "users" include currentUser and otherUser
        query.whereKey("users", containsAllObjectsIn:[currentUser!])
        query.order(byDescending: "updatedAt")
        query.limit = 20
        

        // Include keys in the query: users (array), lastMessage
        
        // Retrieve Chats objects to assign them to chats (list)
        query.findObjectsInBackground { (chats, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.chats = chats ?? []
                print(self.chats)
            }
        }
        chatTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if chatSearchBar.text == "" {
            return chats.count
        } else {
            return filteredChats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTable.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCellTableViewCell
        var otherUser = PFUser()
        var message = ""
        if chatSearchBar.text == "" {
            let chat = chats[indexPath.row]
            let users = chat["users"] as! [PFUser]
            message = chat["lastMessage"] as! String
            if users[0] != currentUser {
                otherUser = users[0]
            } else {
                otherUser = users[1]
            }
            otherUsers.append(otherUser)
            
        } else {
            let chat = filteredChats[indexPath.row]
            otherUser = filteredUsers[indexPath.row]
            message = chat["message"] as! String
        }
        
        let query = PFQuery(className: "Profiles")
        query.whereKey("author", equalTo: otherUser)
        query.findObjectsInBackground { (profiles, error) in
            if profiles != nil {
                let profile = profiles![0]
                let imageFile = profile["profilePic"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)
                cell.userImage.af_setImage(withURL: url!)
                
                cell.userName.text = (profile["name"] as! String)
            }
            
        }
        
        cell.message.text = message
        return cell
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        filteredChats = [PFObject]()
        filteredUsers = [PFUser]()
        
        searchBar.endEditing(true)
        chatTable.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let keyword = searchBar.text {
            
            // Grab PFUser with "name" matched keyword
            let profileQuery = PFQuery(className:"Profiles")
            profileQuery.whereKey("name", contains: keyword)
            profileQuery.includeKey("author")
            
            profileQuery.findObjectsInBackground { (profiles, error) in
                if let profiles = profiles {
                    for profile in profiles {
                        let otherUser = profile["author"] as! PFUser
                        self.otherUsers.append(otherUser)
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
        
            // Grab Chats with otherUser included in "users"
            let chatQuery = PFQuery(className: "Chats")
            chatQuery.whereKey("user", containedIn: otherUsers)
            chatQuery.includeKey("lastMessage")
            chatQuery.limit = 5
            
            chatQuery.findObjectsInBackground { (chats, error) in
                if let chats = chats {
                    for chat in chats {
                        let message = chat["lastMessage"] as! PFObject
                        self.filteredChats.append(message)
                        
                        let sender = message["sender"] as! PFUser
                        let receiver = message["receiver"] as! PFUser
                        
                        if sender == self.currentUser {
                            self.filteredUsers.append(receiver)
                        } else {
                            self.filteredUsers.append(sender)
                        }
                    }
                    
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            // Grab Message with "message" mathced keyword
            let messageQuery = PFQuery(className: "Messages")
            messageQuery.whereKey("message", contains: keyword)
            messageQuery.limit = 5
            messageQuery.findObjectsInBackground { (messages, error) in
                if let messages = messages {
                    for message in messages {
                        self.filteredChats.append(message)
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }
            
            chatTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var otherUser = PFUser()
        
        if chatSearchBar.text == "" {
            otherUser = otherUsers[indexPath.row]
        } else {
            let message = filteredChats[indexPath.row]
            let users = message["users"] as! [PFUser]
            if users[0] == currentUser {
                otherUser = users[1]
            } else {
                otherUser = users[0]
            }
        }
        
        let selectedVC = ChatDetailViewController()
        
        selectedVC.currentUser = currentUser!
        selectedVC.otherUser = otherUser
        
        selectedVC.performSegue(withIdentifier: "ToChatSegue", sender: self)
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
