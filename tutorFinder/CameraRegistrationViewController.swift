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
    
    var username = ""
    var password = ""
    var subjects = [""]
    override func viewDidLoad() {
        super.viewDidLoad()
        print("username is: " ,username)
        print("password is: " ,password)
        // Do any additional setup after loading the view.
    }
    

    @IBAction func onSubmitButton(_ sender: Any) {
        let user = PFUser()
        user.username = username
        user.password = password
        
        user.signUpInBackground { (success,error) in
            if success {
                print("User was signed up success")
                PFUser.logInWithUsername(inBackground: self.username, password: self.password)
                {
                    (user,error) in
                    if user != nil {
                    }
                    else
                    {
                        print("Error: \(error?.localizedDescription ?? "could not log in")")
                    }
                }
            }
            else{
                print("Error: \(error?.localizedDescription ?? "didn't sign up")")
            }
        }
        let profile = PFObject(className: "Profiles")
        profile["name"] = nameField.text!
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
        let file = PFFileObject(data: imageData!)
        
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
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
