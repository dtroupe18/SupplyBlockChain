//
//  SearchJobsViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/5/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

class SearchJobsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let jobs: [String] = ["Job One", "Job Two", "Job Three", "Job Four", "Job Five", "Job Six", "Job Seven",
                          "Job Eight", "Job Nine", "Job Ten"]
    
    var userInfo: User?
    var userBids: [Block]?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Jobs to Bid on"
        tableView.delegate = self
        tableView.dataSource = self
        
        DatabaseFunctions.getUserInfo({ (error, user) in
            if error != nil {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            } else if let user = user {
                self.userInfo = user
            }
        })
        
        DatabaseFunctions.getUserBids({ blockArray in
            if blockArray != nil {
                self.userBids = blockArray
                print("BlockArray: \(blockArray!)")
            }
        })
        
        // Add a button to take the user to their bids
        //
        // Create submit button in the navigation bar
        //
        let submitButton = UIButton(type: .custom)
        submitButton.setTitle("My Bids", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        submitButton.addTarget(self, action: #selector(self.myBidsPressed), for: .touchUpInside)
        let submitItem = UIBarButtonItem(customView: submitButton)
        self.navigationItem.setRightBarButtonItems([submitItem], animated: false)
    }
    
    @objc func myBidsPressed() {
        // Segue to myBidsVC
        //
        let sb: UIStoryboard = UIStoryboard(name: "MyBids", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "MyBidsVC") as? MyBidsViewController {
            vc.userBids = self.userBids
            vc.userInfo = self.userInfo
            navigationController?.pushViewController(vc, animated: true)
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
        let sb: UIStoryboard = UIStoryboard(name: "CreateBid", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "CreateBidVC") as? CreateBidViewController {
            vc.userInfo = self.userInfo
            vc.job = jobs[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
