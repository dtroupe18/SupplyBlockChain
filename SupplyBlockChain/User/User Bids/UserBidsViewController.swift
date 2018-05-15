//
//  UserBidsViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/11/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import RealmSwift

class UserBidsViewController: UITableViewController {
    
    var user: User? {
        didSet {
            loadBids()
            self.title = "\(user!.firstName) \(user!.lastName)"
        }
    }
    
    var bids: Results<PostedBid>?
    
    // Realm documentation says force unwrapping here is ok
    //
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func loadBids() {
        // retrieve all completed bids for that user
        //
        let results = user?.postedBids.sorted(byKeyPath: "timestamp", ascending: false)
        if results != nil && !results!.isEmpty {
            bids = results
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let bidCount = bids?.count else { return 1 }
        return bidCount > 0 ? bidCount: 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BidCell", for: indexPath)
        if let time = bids?[indexPath.row].timestamp {
            cell.textLabel?.text = "\(time)"
        } else {
            cell.textLabel?.text = "No bids yet"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
