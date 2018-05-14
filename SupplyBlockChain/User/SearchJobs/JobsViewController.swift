//
//  SearchJobsViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/5/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import FirebaseAuth
import RealmSwift

class JobsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let jobs: [String] = ["Job One", "Job Two", "Job Three", "Job Four", "Job Five", "Job Six", "Job Seven",
                          "Job Eight", "Job Nine", "Job Ten"]
    
    var user: User?
    let realm = try! Realm()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            loadUserInformation()
        } else {
            tableView.reloadData()
        }
        
        self.navigationItem.title = "Jobs to Bid on"
        tableView.delegate = self
        tableView.dataSource = self
        
        // Create submit button in the navigation bar
        //
        let myBidsButton = UIButton(type: .custom)
        myBidsButton.setTitle("My Bids", for: .normal)
        myBidsButton.setTitleColor(.white, for: .normal)
        myBidsButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        myBidsButton.addTarget(self, action: #selector(self.myBidsPressed), for: .touchUpInside)
        let myBidsItem = UIBarButtonItem(customView: myBidsButton)
        self.navigationItem.setRightBarButtonItems([myBidsItem], animated: false)
        
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
    
    func loadUserInformation() {
        // retrieve user info for the signed in user from Realm. That means the uid must match
        //
        if let uid = Auth.auth().currentUser?.uid {
            user = realm.objects(User.self).filter("uid == %@", uid).first
            tableView.reloadData()
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
    
    @objc func myBidsPressed() {
        // Segue to myBidsVC
        //
        let sb: UIStoryboard = UIStoryboard(name: "UserBids", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "UserBids") as? UserBidsViewController {
            if let unWrappedUser = user {
                vc.user = unWrappedUser
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // Marker: TableView Delegate
    //
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "jobCell", for: indexPath)
        cell.textLabel?.text = jobs[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let sb: UIStoryboard = UIStoryboard(name: "CreateBid", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "CreateBidVC") as? CreateBidViewController {
            vc.user = self.user
            vc.job = jobs[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
