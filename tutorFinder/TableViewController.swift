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
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let query = PFQuery(className: "Profiles")
        query.limit = 100
        query.findObjectsInBackground { (profiles, error) in
            if profiles != nil {
                self.profiles = profiles!
                self.tableView.reloadData()
            }
        }
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            self.searchBar.showsCancelButton = true
        self.tableView.reloadData()
            
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            searchBar.showsCancelButton = false
            searchBar.text = ""
            searchBar.resignFirstResponder()
            let query = PFQuery(className: "Profiles")
            query.findObjectsInBackground { (profiles, error) in
                if profiles != nil {
                    self.profiles = profiles!
                    self.tableView.reloadData()
                }
            }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searching now")
        let predicate = NSPredicate(format: "searchText BETWEEN name OR searchText BETWEEN description")
        let query = PFQuery(className: "Profiles", predicate: predicate)
        query.order(byDescending: "name")
        query.findObjectsInBackground { (profiles,error) in
            if profiles != nil {
                self.profiles = profiles!
            }
        /*
        // uses PFQuery instead of Predicates to search, couldn't figure out how to use this correctly
        let query1 = PFQuery(className:"Profiles")
        let query2 = PFQuery(className:"Profiles")
        let query3 = PFQuery(className:"Profiles")
        query1.whereKey("name", contains: searchText)
        query2.whereKey("description", contains: searchText)
        query3.whereKey("contactEmail", contains: searchText)
        // add another query here that has subjects being searched
        let query = PFQuery.orQuery(withSubqueries: [query1])
        query.order(byDescending: "name")
        query.findObjectsInBackground { (profiles,error) in
            if profiles != nil {
                self.profiles = profiles!
            }
        }*/
            self.tableView.reloadData()
        }
        
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
