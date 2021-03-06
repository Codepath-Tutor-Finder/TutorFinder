//
//  CameraViewController.swift
//  tutorFinder
//
//  Created by Averi Justice on 4/8/20.
//  Copyright © 2020 BaraaHegazy. All rights reserved.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraImageView: UIImageView!
    
    @IBAction func cameraSubmitButton(_ sender: Any) {
            let user = PFUser.current()
            let authorQuery = PFQuery(className:"Profiles")
            authorQuery.whereKey("author", equalTo: user!)
            authorQuery.getFirstObjectInBackground { (profile,error) in
                if error != nil
                {
                    print("error")
                } else
                {
                    let imageData = self.cameraImageView.image!.pngData()
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
        dismiss(animated: true, completion: nil)
        }
    
    @IBAction func onCameraButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        let size = CGSize(width: 300, height: 300)
        let scaledImage = image.af_imageScaled(to: size)
        
        cameraImageView.image = scaledImage
        
        dismiss(animated: true, completion: nil)
    }
    
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

}
