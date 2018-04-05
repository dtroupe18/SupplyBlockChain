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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Jobs to Bid on"
        tableView.delegate = self
        tableView.dataSource = self
    }
    
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
        print("Selected job: \(jobs[indexPath.row])")
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