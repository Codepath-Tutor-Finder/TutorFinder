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
    }
    
    override func viewDidDisappear(_ animated: Bool) {

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadChats()
    }
    
    // Function to load lists of chats
    func loadChats() {
        let query = PFQuery(className: "Chats")
        
        query.whereKey("users", containsAllObjectsIn:[currentUser!])
        query.order(byDescending: "updatedAt")
        query.limit = 20
        
        query.findObjectsInBackground { (chats, error) in
            if chats != nil {
                self.chats = chats!
                self.chatTable.reloadData()
            } else {
                let error = error
                print(error?.localizedDescription)
            }
        }
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
            let lastMessage = chat["lastMessage"] as! PFObject
            
            if users[0].objectId != self.currentUser?.objectId {
                otherUser = users[0]
            } else {
                otherUser = users[1]
            }
            
            let query = PFQuery(className: "Messages")
            query.whereKey("objectId", equalTo: lastMessage.objectId)
            query.findObjectsInBackground { (objects, error) in
                if objects != nil {
                    let object = objects![0] as PFObject
                    message = object["message"] as! String
                    cell.message.text = message
                } else {
                    let error = error
                    print(error?.localizedDescription)
                }
            }
            otherUsers.append(otherUser)
            
        } else {
            let chat = filteredChats[indexPath.row]
            let lastMessage = chat["lastMessage"] as! PFObject
            otherUser = filteredUsers[indexPath.row]
            let query = PFQuery(className: "Messages")
            query.whereKey("objectId", equalTo: lastMessage.objectId)
            query.findObjectsInBackground { (objects, error) in
                if objects != nil {
                    let object = objects![0] as PFObject
                    message = object["message"] as! String
                    cell.message.text = message
                } else {
                    let error = error
                    print(error?.localizedDescription)
                }
            }
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
        
        //cell.message.text = message
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
        filteredChats = [PFObject]()
        filteredUsers = [PFUser]()
        
        if searchBar.text != "" {
            let keyword = searchBar.text
            var matchedUsers = [PFObject]()
            
            // Grab PFUser with "name" matched keyword
            let profileQuery = PFQuery(className:"Profiles")
            profileQuery.whereKey("name", contains: keyword)
            print(keyword)
            profileQuery.findObjectsInBackground { (profiles, error) in
                if let profiles = profiles {
                    for profile in profiles {
                        let otherUser = profile["author"] as! PFUser
                        if otherUser.objectId != self.currentUser?.objectId {
                            matchedUsers.append(otherUser)
                        }
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
                
                let query = PFQuery(className: "Chats")
                query.whereKey("users", containedIn: matchedUsers)
                
                query.order(byDescending: "updatedAt")
                query.limit = 20
                
                query.findObjectsInBackground { (chats, error) in
                    if chats != nil {
                        self.filteredChats = chats!
                        for chat in self.filteredChats {
                            let users = chat["users"] as! [PFUser]
                            if users[0].objectId != self.currentUser?.objectId {
                                self.filteredUsers.append(users[0])
                            } else {
                                self.filteredUsers.append(users[1])
                            }
                        }
                    } else {
                        let error = error
                        print(error?.localizedDescription)
                    }
                    self.chatTable.reloadData()
                }
            }

            // Grab Chats with otherUser included in "users"
            

            // Grab Message with "message" mathced keyword
//            let messageQuery = PFQuery(className: "Messages")
//            messageQuery.whereKey("message", contains: keyword)
//            messageQuery.limit = 5
//            messageQuery.findObjectsInBackground { (messages, error) in
//                if let messages = messages {
//                    for message in messages {
//                        self.filteredChats.append(message)
//                    }
//                } else if let error = error {
//                    print(error.localizedDescription)
//                }
//            }

        } else {
            filteredChats = [PFObject]()
            filteredUsers = [PFUser]()
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
