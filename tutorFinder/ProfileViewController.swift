//
//  ProfileViewController.swift
//  tutorFinder
//
//  Created by Averi Justice on 4/8/20.
//  Copyright © 2020 BaraaHegazy. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage

class ProfileViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    
    @IBAction func onSave(_ sender: Any) {
        let user = PFUser.current()
        let query = PFQuery(className:"Profiles")
        query.whereKey("author", equalTo: user!)
        query.getFirstObjectInBackground { (profile,error) in
            if error != nil
            {
                print("error")
            } else
            {
                profile!["name"] = self.nameField.text
                profile!["contactEmail"] = self.emailField.text
                profile!["description"] = self.descriptionField.text
                let imageData = self.profileImageView.image!.pngData()
                let file = PFFileObject(name: "image.png", data: imageData!)
                profile!["profilePic"] = file
                profile!.saveInBackground { (success,error) in
                    if success {
                        print("saved user data")
                    }
                    else
                    {
                        print("Error: \(error?.localizedDescription ?? "didn't save data")")
                    }
                }
            }
        }
    }
    
    @IBAction func onLogOutButton(_ sender: Any) {
        PFUser.logOut()
        let currUser = PFUser.current()
        if (currUser == nil)
        {
            print("logged out successfully")
            performSegue(withIdentifier: "logoutSegue", sender: nil)
            UserDefaults.standard.set(false, forKey: "userLoggedIn")
        }
        else
        {
            print("user not logged out")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let user = PFUser.current()
        let query = PFQuery(className:"Profiles")
        query.whereKey("author", equalTo: user!)
        //let query = PFQuery.orQuery(withSubqueries: [authorQuery])
        query.getFirstObjectInBackground { (profile,error) in
            if error != nil
            {
                print("error")
            } else
            {
                self.nameField.text = profile!["name"] as? String
                self.emailField.text = profile!["contactEmail"] as? String
                self.descriptionField.text = profile!["description"] as? String
                
                let imageFile = profile!["profilePic"] as! PFFileObject
                let urlString = imageFile.url!
                let url = URL(string: urlString)!
                
                self.profileImageView.af_setImage(withURL: url)
            }
        }
        /*
        nameField.text = PFUser.name as? String
        descriptionField.text = profile["description"] as? String
        let imageFile = profile["profilePic"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        profileImageView.af_setImage(withURL: url)
*/
        // Do any additional setup after loading the view.
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

/*
 self.nameField.text = object["name"] as? String
 self.emailField.text = object["contactEmail"] as? String
 self.descriptionField.text = object["description"] as? String
 
 let imageFile = object["profilePic"] as! PFFileObject
 let urlString = imageFile.url!
 let url = URL(string: urlString)!
 
 self.profileImageView.af_setImage(withURL: url)
 */
