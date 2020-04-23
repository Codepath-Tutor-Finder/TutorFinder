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
    var selectedSubjects = [""]
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "subjectCell")!
        cell.textLabel?.text = subjects[indexPath.row]
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(false, animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        return cell
    }
    
    @objc func switchChanged(_ sender:UISwitch!)
    {
        if (selectedSubjects.firstIndex(of: "") == 0)
        {
            selectedSubjects.remove(at: 0)
        }
        let subject = subjects[sender.tag]
        if (sender.isOn)
        {
            selectedSubjects.append(subject)
        }
        else
        {
            if let index = selectedSubjects.firstIndex(of: subject)
            {
                selectedSubjects.remove(at: index)
            }
        }
    }
    
    @IBAction func onConfirmButton(_ sender: Any) {
        print(selectedSubjects)
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
