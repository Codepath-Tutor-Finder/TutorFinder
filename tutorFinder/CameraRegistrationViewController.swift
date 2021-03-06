//
//  CameraRegistrationViewController.swift
//  tutorFinder
//
//  Created by Baraa Hegazy on 4/7/20.
//  Copyright © 2020 BaraaHegazy. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraRegistrationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var emailContactField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var roleSegmentedControl: UISegmentedControl!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var usernameFromLogin = ""
    var passwordFromLogin = ""
    var subjects = [""]
    override func viewDidLoad() {
        super.viewDidLoad()
        print("username is: " ,usernameFromLogin)
        print("password is: " ,passwordFromLogin)
        usernameField.text! = usernameFromLogin
        passwordField.text! = passwordFromLogin
        // Do any additional setup after loading the view.
    }
    

    @IBAction func onSubmitButton(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text!
        user.password = passwordField.text!
        user.signUpInBackground { (success,error) in
            if success {
                print("User was signed up success")
            }
            else{
                print("Error: \(error?.localizedDescription ?? "didn't sign up")")
            }
        }
        do
        {
            sleep(2)
        }
        let profile = PFObject(className: "Profiles")
        if (nameField.text == "")
        {
            profile["name"] = usernameFromLogin
        }
        else
        {
            profile["name"] = nameField.text!
        }
        profile["description"] = descriptionField.text!
        profile["contactEmail"] = emailContactField.text!
        if roleSegmentedControl.selectedSegmentIndex == 0
        {
            profile["isTutor"] = false
        }
        else
        {
            profile["isTutor"] = true
        }
        

        profile["author"] = PFUser.current()
        
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png" ,data: imageData!)
        
        profile["profilePic"] = file
        profile["subjects"] = subjects
        profile.saveInBackground { (success,error) in
            if success {
                print("saved user data")
            }
            else
            {
                print("Error: \(error?.localizedDescription ?? "didn't save data")")
            }
        }
    }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    

    @IBAction func didTap(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func onSubjectButton(_ sender: Any) {
        self.performSegue(withIdentifier: "subjectChooseSegue", sender: nil)
    }
    @IBAction func unwindToVC(_ unwindSegue: UIStoryboardSegue) {
        if let sourceViewController = unwindSegue.source as? SubjectSelectionViewController
        {
            subjects = sourceViewController.selectedSubjects
        }
        // Use data from the view controller which initiated the unwind segue
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        imageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onCancelButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
