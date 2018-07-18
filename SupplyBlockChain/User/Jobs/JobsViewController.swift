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
    
    var user: User?
    var jobs: [PostedJob] = [PostedJob]()
    let realm = try! Realm()
    
    var dataStores: Results<DataStore>? {
        didSet {
            loadPostedJobIds()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if user == nil {
            loadUserInformation()
        }
        
        loadDataStores()
    
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
        
        // Register the Xib for our cell
        //
        let nib = UINib.init(nibName: "JobCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "JobCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1.0)
    }
    
    private func loadUserInformation() {
        // retrieve user info for the signed in user from Realm. That means the uid must match
        //
        if let uid = Auth.auth().currentUser?.uid {
            user = realm.objects(User.self).filter("uid == %@", uid).first
        }
    }
    
    private func loadPostedJobIds() {
        guard let jobStore = dataStores?.first(where: {$0.name == "Jobs"}) else {
            showAlert(title: "Error", message: "BidStore missing")
            return
        }
        CustomActivityIndicator.shared.showActivityIndicator(uiView: self.view, color: nil, labelText: "Loading Jobs...")
        TierionWrapper.shared.getDataStoreRecords(dataStoreId: jobStore.id, { (error, recordResponse) in
            if let error = error {
                CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else if let recordResponse = recordResponse {
                if recordResponse.records.isEmpty {
                    CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                    return
                } else {
                    self.loadJobRecords(records: recordResponse.records)
                }
            }
        })
    }
    
    private func loadJobRecords(records: [Record]) {
        var errorCount: Int = 0
        for record in records {
            TierionWrapper.shared.getDataStoreJobDetails(recordId: record.id, { (error, postedJob) in
                if error != nil {
                    CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                    self.showAlert(title: "Error", message: error!.localizedDescription)
                    errorCount += 1
                } else if let postedJob = postedJob {
                    // Check if we are done
                    //
                    self.jobs.append(postedJob)
                    if self.jobs.count + errorCount == records.count {
                        // Sort by timestamp
                        //
                        self.jobs = self.jobs.sorted(by: { $0.timestamp > $1.timestamp })
                        self.tableView.reloadData()
                        CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                    }
                }
            })
        }
    }
    
    private func loadDataStores() {
        // retrieve dataStores from realm or Tierion
        //
        let results = realm.objects(DataStore.self)
        if results.isEmpty {
            // Get the dataStores from Tierion
            //
            TierionWrapper.shared.getAllDataStores({ (error, stores) in
                if error != nil {
                    self.showAlert(title: "Error Loading Data Stores", message: error!.localizedDescription)
                } else if let stores = stores {
                    self.saveDataStoresToRealm(stores: stores)
                }
            })
        } else {
            dataStores = results
        }
    }
    
    private func saveDataStoresToRealm(stores: [DataStore]) {
        do {
            try realm.write {
                for store in stores {
                    realm.add(store)
                }
                dataStores = realm.objects(DataStore.self)
            }
        } catch {
            showAlert(title: "Realm Error", message: "\(error)")
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
        return jobs.count > 0 ? jobs.count: 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "JobCell", for: indexPath) as! JobCell
        cell.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1.0)
        
        if jobs.isEmpty {
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
        } else if let job = jobs[indexPath.row].job {
            cell.companyLabel.attributedText = NSMutableAttributedString().bold("Company: ").normal("\(job.companyName)")
            cell.jobNameLabel.attributedText = NSMutableAttributedString().bold("Job Name: ").normal("\(job.jobName)")
            cell.industryLabel.attributedText = NSMutableAttributedString().bold("Industry: ").normal("\(job.industry)")
            cell.jobDescriptionLabel.attributedText = NSMutableAttributedString().bold("Description: ").normal("\(job.jobDescription)")
            cell.commentsLabel.attributedText = NSMutableAttributedString().bold("Comments: ").normal("\(job.comments)")
            cell.postedByLabel.attributedText = NSMutableAttributedString().bold("Posted by: ").normal("\(job.postedBy)")
            cell.emailLabel.attributedText = NSMutableAttributedString().bold("Email: ").normal("\(job.posterEmail)")
            cell.phoneLabel.attributedText = NSMutableAttributedString().bold("Phone: ").normal("\(job.posterPhoneNumber)")
            cell.hashLabel.attributedText = NSMutableAttributedString().bold("Hash:" ).normal("\(jobs[indexPath.row].sha256)")
            
            cell.startDateLabel.attributedText = NSMutableAttributedString().bold("Start Date: ").normal(
                "\(Int(job.expectedStartDate)?.dateString ?? " Error")")
            cell.endDateLabel.attributedText = NSMutableAttributedString().bold("End Date: ").normal(
                "\(Int(job.expectedEndDate)?.dateString ?? " Error")")
            cell.timestampLabel.attributedText = NSMutableAttributedString().bold("Posted on: ").normal(
                "\(jobs[indexPath.row].timestamp.dateString)")
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !jobs.isEmpty {
            let sb: UIStoryboard = UIStoryboard(name: "CreateBid", bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "CreateBidVC") as? CreateBidViewController {
                vc.user = self.user
                vc.postedJob = jobs[indexPath.row]
                vc.dataStores = self.dataStores
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
