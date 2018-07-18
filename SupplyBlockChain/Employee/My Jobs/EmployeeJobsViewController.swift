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
    var jobs: Results<PostedJob>?

    override func viewWillAppear(_ animated: Bool) {
        showNavigationBar()
        loadJobsFromRealm()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Jobs"
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
        
        let nib = UINib.init(nibName: "JobCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "EmployeeJobCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1.0)
    }
    
    // Load jobs from Realm
    //
    private func loadJobsFromRealm() {
        if let user = user {
            jobs = user.postedJobs.sorted(byKeyPath: "timestamp", ascending: false)
            tableView.reloadData()
        } else {
            showAlert(title: "Error", message: "Error loading user information")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let jobCount = jobs?.count {
            return jobCount > 0 ? jobCount: 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeJobCell", for: indexPath) as! JobCell
        cell.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1.0)
        if let jobs = jobs {
            if !jobs.isEmpty, let job = jobs[indexPath.row].job {
                cell.companyLabel.attributedText = NSMutableAttributedString().bold("Company:").normal(" \(job.companyName)")
                cell.jobNameLabel.attributedText = NSMutableAttributedString().bold("Job Name:").normal(" \(job.jobName)")
                cell.industryLabel.attributedText = NSMutableAttributedString().bold("Industry:").normal(" \(job.industry)")
                cell.jobDescriptionLabel.attributedText = NSMutableAttributedString().bold("Description:").normal(" \(job.jobDescription)")
                cell.commentsLabel.attributedText = NSMutableAttributedString().bold("Comments:").normal(" \(job.comments)")
                cell.postedByLabel.attributedText = NSMutableAttributedString().bold("Posted by:").normal(" \(job.postedBy)")
                cell.emailLabel.attributedText = NSMutableAttributedString().bold("Email:").normal(" \(job.posterEmail)")
                cell.phoneLabel.attributedText = NSMutableAttributedString().bold("Phone:").normal(" \(job.posterPhoneNumber)")
                cell.hashLabel.attributedText = NSMutableAttributedString().bold("Hash:").normal(" \(jobs[indexPath.row].sha256)")
                
                cell.startDateLabel.attributedText = NSMutableAttributedString().bold("Start Date:").normal(
                    " \(Int(job.expectedStartDate)?.dateString ?? " Error")")
                cell.endDateLabel.attributedText = NSMutableAttributedString().bold("End Date:").normal(
                    " \(Int(job.expectedEndDate)?.dateString ?? " Error")")
                cell.timestampLabel.attributedText = NSMutableAttributedString().bold("Posted on:").normal(
                    " \(jobs[indexPath.row].timestamp.dateString)")
            } else {
                cell.companyLabel.text = "No Jobs Yet"
                cell.jobNameLabel.text = ""
                cell.industryLabel.text = ""
                cell.jobDescriptionLabel.text = ""
                cell.startDateLabel.text = ""
                cell.endDateLabel.text = ""
                cell.commentsLabel.text = ""
                cell.postedByLabel.text = ""
                cell.emailLabel.text = ""
                cell.phoneLabel.text = ""
                cell.hashLabel.text = ""
                cell.timestampLabel.text = ""
            }
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let count = jobs?.count {
            if count > 0 {
                let sb: UIStoryboard = UIStoryboard(name: "MyBids", bundle: nil)
                if let vc = sb.instantiateViewController(withIdentifier: "MyBidsVC") as? MyBidsViewController {
                    vc.postedJob = jobs?[indexPath.row]
                    navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
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
