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
    
    class Chat {
        let user : String
        let message : String
        init (user: String, message: String) {
            self.user = user
            self.message = message
        }
    }
    var tutors = [Chat(user: "Tutor 1", message: "I'm currently enrolled in MMG 201."),
                  Chat(user: "Tutor 2", message: "Tuesday and Thursday work best for me."),
                  Chat(user: "Tutor 3", message: "Sounds like a good plan.")]
    
//    var data = [String]()
//    var filterData = [String]()
    
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var chatSearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatTable.delegate = self
        chatTable.dataSource = self
        chatSearchBar.delegate = self
        
        
//        for tutor in tutors {
//            data.append(tutor.user)
//        }
//
//        chatTable.register(ChatCellTableViewCell.self, forCellReuseIdentifier: "ChatCell")
//        chatTable.tableFooterView = UIView()
//        filterData = data
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tutors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = chatTable.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCellTableViewCell
        let chat = tutors[indexPath.row]
        cell.userName.text = chat.user
        cell.message.text = chat.message
        
        return cell
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
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
