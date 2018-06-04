//
//  MyBidsViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/16/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit

class MyBidsViewController: UITableViewController {
    
    var postedJob: PostedJob?
    var bidIds: [String] = [String]()
    var bids: [PostedBid] = [PostedBid]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Bids for \(postedJob?.job?.jobName ?? "")"
        
        if let postedJob = postedJob {
            loadBidIds(jobId: postedJob.id)
        } else {
            showAlert(title: "Error", message: "Job as no id!")
        }
        
        // Register the Xib for our cell
        //
        let nib = UINib.init(nibName: "BidCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "BidCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1.0)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bids.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BidCell", for: indexPath) as! BidCell
        if let bid = bids[indexPath.row].bid {
            cell.backgroundColor = UIColor(red: 0/255, green: 150/255, blue: 255/255, alpha: 1.0)
            cell.companyLabel.attributedText = NSMutableAttributedString().bold("Comapny: ").normal(bid.companyName)
            cell.priceLabel.attributedText = NSMutableAttributedString().bold("Price: ").normal("$\(bid.price)")
            cell.bidderNameLabel.attributedText = NSMutableAttributedString().bold("Bidder: ").normal("\(bid.name)")
            cell.bidderEmailLabel.attributedText = NSMutableAttributedString().bold("Email: ").normal("\(bid.email)")
            cell.bidderPhoneLabel.attributedText = NSMutableAttributedString().bold("Phone: ").normal("\(bid.phoneNumber)")
            cell.hashLabel.attributedText = NSMutableAttributedString().bold("Hash: ").normal("\(bids[indexPath.row].sha256)")
            cell.commentsLabel.attributedText = NSMutableAttributedString().bold("Comments: ").normal("\(bid.comments)")
            cell.timestampLabel.attributedText = NSMutableAttributedString().bold("Submitted on: ").normal(
                bids[indexPath.row].timestamp.dateString)
        } else {
            cell.isHidden = true
        }
        return cell
    }
    
    private func loadBidIds(jobId: String) {
        CustomActivityIndicator.shared.showActivityIndicator(uiView: self.view, color: nil, labelText: "Loading Bids...")
        FirebaseFunctions.loadCompletedBidIds(jobId: jobId, { (error, stringArray) in
            if let error = error {
                CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                self.showAlert(title: "Error", message: error.localizedDescription)
            } else if let stringArray = stringArray {
                self.loadBidsFromTierion(bidIds: stringArray)
            }
        })
    }
    
    private func loadBidsFromTierion(bidIds: [String]) {
        var errorCount: Int = 0
        for id in bidIds {
            TierionWrapper.shared.getDataStoreBidDetails(recordId: id, { (error, postedBid) in
                if error != nil {
                    self.showAlert(title: "Error", message: error!.localizedDescription)
                    errorCount += 1
                } else if let postedBid = postedBid {
                    self.bids.append(postedBid)
                    
                    // Check if we're done loading
                    //
                    if self.bids.count + errorCount == bidIds.count {
                        self.bids = self.bids.sorted(by: { $0.timestamp > $1.timestamp })
                        self.tableView.reloadData()
                        CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                    }
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
