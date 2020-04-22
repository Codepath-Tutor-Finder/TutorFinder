//
//  SubjectSelectionViewController.swift
//  tutorFinder
//
//  Created by Baraa Hegazy on 4/22/20.
//  Copyright © 2020 BaraaHegazy. All rights reserved.
//

import UIKit

class SubjectSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {


    @IBOutlet weak var subjectTableView: UITableView!
    let subjects = ["Computer Science", "Physics", "Calculus", "TestSubject"]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCell") as! UITableViewCell
        cell.textLabel?.text = subjects[indexPath.row]
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(self.switchChanged()), for: .valueChanged)
        cell.accessoryView = switchView
        return cell
    }
    
    func switchChanged( sender:UISwitch!)
    {
        
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
