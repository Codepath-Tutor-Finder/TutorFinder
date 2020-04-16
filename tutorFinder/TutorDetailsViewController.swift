//
//  TutorDetailsViewController.swift
//  tutorFinder
//
//  Created by Baraa Hegazy on 4/8/20.
//  Copyright © 2020 BaraaHegazy. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class TutorDetailsViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var profile: PFObject!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameLabel.text = profile["name"] as? String
        descriptionLabel.text = profile["description"] as? String
        let imageFile = profile["profilePic"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        profileImageView.af_setImage(withURL: url)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        /*let query = PFQuery(className:"Profiles")
        if let user = PFUser.current() {
          query.whereKey("author", equalTo: user)
        }
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            if let error = error {
                // Log details of the failure
                print(error.localizedDescription)
            } else if let objects = objects {
                // The find succeeded.
                print("Successfully retrieved \(objects.count) profiles.")
                // Do something with the found objects
                for object in objects {
                    self.nameLabel.text = object["name"] as? String
                    self.contactLabel.text = object["contactEmail"] as? String
                    self.descriptionLabel.text = object["description"] as? String
                    
                    let imageFile = object["profilePic"] as! PFFileObject
                    let urlString = imageFile.url!
                    let url = URL(string: urlString)!
                    
                    self.profileImageView.af_setImage(withURL: url)
                }
            }*/
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
