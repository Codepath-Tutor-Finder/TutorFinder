//
//  TableViewController.swift
//  tutorFinder
//
//  Created by Baraa Hegazy on 4/7/20.
//  Copyright © 2020 BaraaHegazy. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var profiles = [PFObject]()
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TutorCell") as! TutorCell
        let profile = profiles[indexPath.row]
        
        cell.nameLabel.text = profile["name"] as? String
        cell.descLabel.text = profile["description"] as? String
        
        let imageFile = profile["profilePic"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        
        cell.profileImage.af_setImage(withURL: url)
        return cell
    }
    

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Profiles")
        query.limit = 20
        query.findObjectsInBackground { (profiles, error) in
            if profiles != nil {
                self.profiles = profiles!
                self.tableView.reloadData()
            }
        }
    }
    
}
