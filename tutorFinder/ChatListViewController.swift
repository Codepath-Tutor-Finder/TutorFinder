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
        query.whereKey("users", containsAllObjectsIn:[currentUser])
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTable.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCellTableViewCell
        let chat = chats[indexPath.row]
        let users = chat["users"] as! [PFUser]
        if users[0] != currentUser {
            let otherUser = users[0]
            cell.userName.text = otherUser.username
            
        } else {
            let otherUser = users[1]
            cell.userName.text = otherUser.username
            otherUsers.append(otherUser)
        }
        
        cell.message.text = chat["lastMessage"] as! String
        return cell
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let otherUser = otherUsers[indexPath.row]
        
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
