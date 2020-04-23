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

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    var profiles = [PFObject]()
    var allProfiles = [PFObject]()
    var isTutor = false
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
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
        searchBar.delegate = self
        let user = PFUser.current()
        let authorQuery = PFQuery(className:"Profiles")
        authorQuery.whereKey("author", equalTo: user!)
        //let query = PFQuery.orQuery(withSubqueries: [authorQuery])
        authorQuery.getFirstObjectInBackground { (profile,error) in
            if error != nil
            {
                print("error")
            } else
            {
                self.isTutor = profile!["isTutor"] as! Bool
            }
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Profiles")
        query.limit = 100
        query.order(byAscending: "name")
        query.whereKey("isTutor", notEqualTo: self.isTutor)
        query.findObjectsInBackground { (profiles, error) in
            if profiles != nil {
                self.profiles = profiles!
                self.tableView.reloadData()
            }
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.text = ""
            searchBar.resignFirstResponder()
        let query = PFQuery(className: "Profiles")
        query.limit = 100
        query.order(byAscending: "name")
        query.whereKey("isTutor", notEqualTo: self.isTutor)
        query.findObjectsInBackground { (profiles, error) in
            if profiles != nil {
                self.profiles = profiles!
                self.tableView.reloadData()
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
        let nameQuery = PFQuery(className: "Profiles")
        nameQuery.whereKey("name", contains: searchBar.text!)
        
        let descQuery = PFQuery(className: "Profiles")
        descQuery.whereKey("description", contains: searchBar.text!)
        
        let mailQuery = PFQuery(className: "Profiles")
        descQuery.whereKey("contactEmail", contains: searchBar.text!)
        
        let subjects = PFQuery(className: "Profiles")
        descQuery.whereKey("subjects", contains: searchBar.text!)
        
        let query = PFQuery.orQuery(withSubqueries: [nameQuery, descQuery, mailQuery, subjects])
        query.whereKey("isTutor", notEqualTo: self.isTutor)
        query.findObjectsInBackground { (profiles,error) in
            if error != nil {
                print("error")
            }
            if let objects = profiles
            {
                print(objects.count)
                self.profiles = objects
                self.tableView.reloadData()
            }
        }
        self.searchBar.resignFirstResponder()
        self.tableView.reloadData()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let profile = profiles[indexPath.row]
        let detailsViewConroller = segue.destination as! TutorDetailsViewController
        detailsViewConroller.profile = profile
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
