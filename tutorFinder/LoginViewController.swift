//
//  LoginViewController.swift
//  tutorFinder
//
//  Created by Baraa Hegazy on 4/7/20.
//  Copyright © 2020 BaraaHegazy. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

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

    @IBAction func onSignUp(_ sender: Any) {
        /*
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        
        user.signUpInBackground { (success,error) in
            if success {
                self.performSegue(withIdentifier: "signUpSegue", sender: nil)
            }
            else{
                print("Error: \(error?.localizedDescription)")
            }
        }
        */
        self.performSegue(withIdentifier: "signUpSegue", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "signUpSegue")
        {
        let vc = segue.destination as! CameraRegistrationViewController
        vc.username = usernameField.text!
        vc.password = passwordField.text!
        }
        
    }
    @IBAction func onSignIn(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password)
        {
            (user,error) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }
            else
            {
                print("Error: \(error?.localizedDescription ?? "could not log in")")
            }
        }
    }
}
