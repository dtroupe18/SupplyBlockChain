//
//  EmpolyeeJobsViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/13/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import FirebaseAuth
import RealmSwift

class EmployeeJobsViewController: UITableViewController {

    @IBOutlet weak var addBarButton: UIBarButtonItem!
    
    var user: User?

    override func viewWillAppear(_ animated: Bool) {
        showNavigationBar()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Jobs"
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // Create signout button in the navigation bar
        //
        let signOutButton = UIButton(type: .custom)
        signOutButton.setTitle("Sign out", for: .normal)
        signOutButton.setTitleColor(.white, for: .normal)
        signOutButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        signOutButton.addTarget(self, action: #selector(self.signOut), for: .touchUpInside)
        let signOutItem = UIBarButtonItem(customView: signOutButton)
        self.navigationItem.setLeftBarButtonItems([signOutItem], animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let jobCount = user?.postedJobs.count {
            return jobCount > 0 ? jobCount: 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeJobCell", for: indexPath)
        if let jobs = user?.postedJobs {
            if !jobs.isEmpty {
                cell.textLabel?.text = jobs[indexPath.row].job?.jobName 
            } else {
                cell.textLabel?.text = "No jobs yet"
            }
        }
        return cell
    }
    
    @IBAction func addBarButtonPressed(_ sender: Any) {
        let sb: UIStoryboard = UIStoryboard(name: "CreateJob", bundle: nil)
        if let vc = sb.instantiateInitialViewController() as? CreateJobViewController {
            vc.user = user
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func signOut() {
        do {
            try Auth.auth().signOut()
            let sb: UIStoryboard = UIStoryboard(name: "SignIn", bundle: nil)
            if let vc = sb.instantiateInitialViewController() {
                present(vc, animated: false)
            }
        } catch {
            showAlert(title: "Error", message: "\(error)")
        }
    }
}
