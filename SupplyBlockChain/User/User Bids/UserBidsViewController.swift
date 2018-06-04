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
        
        let nib = UINib.init(nibName: "BidCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BidCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1.0)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "BidCell", for: indexPath) as! BidCell
        cell.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1.0)
        if let bid = bids?[indexPath.row].bid {
            cell.companyLabel.attributedText = NSMutableAttributedString().bold("Comapny: ").normal(bid.companyName)
            cell.priceLabel.attributedText = NSMutableAttributedString().bold("Price: ").normal("$\(bid.price)")
            cell.bidderNameLabel.attributedText = NSMutableAttributedString().bold("Bidder: ").normal("\(bid.name)")
            cell.bidderEmailLabel.attributedText = NSMutableAttributedString().bold("Email: ").normal("\(bid.email)")
            cell.bidderPhoneLabel.attributedText = NSMutableAttributedString().bold("Phone: ").normal("\(bid.phoneNumber)")
            cell.hashLabel.attributedText = NSMutableAttributedString().bold("Hash: ").normal("\(bids?[indexPath.row].sha256 ?? " error")")
            cell.commentsLabel.attributedText = NSMutableAttributedString().bold("Comments: ").normal("\(bid.comments)")
            cell.timestampLabel.attributedText = NSMutableAttributedString().bold("Submitted on: ").normal(bids![indexPath.row].timestamp.dateString)
        } else {
            cell.companyLabel.text = "No bids yet"
            cell.priceLabel.text = ""
            cell.bidderNameLabel.text = ""
            cell.bidderEmailLabel.text = ""
            cell.bidderPhoneLabel.text = ""
            cell.hashLabel.text = ""
            cell.timestampLabel.text = ""
            cell.commentsLabel.text = ""
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
