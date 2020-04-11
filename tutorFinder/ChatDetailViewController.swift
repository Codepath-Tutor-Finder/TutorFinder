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

    class Message {
        let user : String
        let message : String
        init (user: String, message: String) {
            self.user = user
            self.message = message
        }
    }
    
    let user = "Bill"
    let tutor = "Tutor 1"
    var messages = [Message(user: "Tutor", message: "My name is Tutor 1"),
                    Message(user: "Tutor", message: "I'm currently enrolled in MMG 201.")]
    
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
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        conversationTable.estimatedRowHeight = 150
//        conversationTable.rowHeight = UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = conversationTable.dequeueReusableCell(withIdentifier: "MessageCell") as! MessageCellTableViewCell
        let cellMessage = messages[indexPath.row]
        cell.user.text = cellMessage.user
        cell.message.text = cellMessage.message
        
        cell.bubbleView.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        cell.bubbleView.layer.cornerRadius = 16
        cell.bubbleView.clipsToBounds = true
        cell.bubbleView.sizeToFit()
        cell.bubbleView.layoutIfNeeded()
        
        if cell.user.text == user {
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
        if let message = textField.text {
            messages.append(Message(user: user, message: message))
            textField.text = ""
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
