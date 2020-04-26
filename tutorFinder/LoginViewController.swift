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
    var continueLogin = true
    
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
    override func viewDidAppear(_ animated: Bool) {
        if UserDefaults.standard.bool(forKey: "userLoggedIn") == true
        {
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }
    }
    @IBAction func onSignUp(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password)
        {
            (user,error) in
            if user != nil {
                UserDefaults.standard.set(true, forKey: "userLoggedIn")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                self.usernameField.text = ""
                self.passwordField.text = ""
            }
            else
            {
                print("Error: \(error?.localizedDescription ?? "could not log in")")
                self.performSegue(withIdentifier: "signUpSegue", sender: nil)
                self.usernameField.text = ""
                self.passwordField.text = ""
            }
        }
    }
    @IBAction func didTap(_ sender: Any) {
        view.endEditing(true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "signUpSegue")
        {
        let vc = segue.destination as! CameraRegistrationViewController
        vc.usernameFromLogin = usernameField.text!
        vc.passwordFromLogin = passwordField.text!
        }
        
    }
    @IBAction func onSignIn(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password)
        {
            (user,error) in
            if user != nil {
                UserDefaults.standard.set(true, forKey: "userLoggedIn")
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
                self.usernameField.text = ""
                self.passwordField.text = ""
            }
            else
            {
                print("Error: \(error?.localizedDescription ?? "could not log in")")
            }
        }
    }
    
}
