//
//  Block.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/9/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

// Import for SHA512 hashing
//
import Arcane

struct Block: Codable, CustomStringConvertible {
    
    // Needed so we can hash the block
    //
    let description: String
    let index: Int
    let timestamp: Int64
    let bid: Bid
    let previousHash: String
    var hash: String?
    
    init?(index: Int, timestamp: Int64, bid: Bid, previousHash: String) {
        self.index = index
        self.timestamp = timestamp
        self.bid = bid
        self.previousHash = previousHash
        
        self.description = "\(index)\(timestamp)\(bid)\(previousHash)"
        
        // Calculate Hash of the entire block
        //
        self.hash = Hash.SHA512(self.description)
    }
    
    init(index: Int, timestamp: Int64, bid: Bid, previousHash: String, hash: String) {
        self.index = index
        self.timestamp = timestamp
        self.bid = bid
        self.previousHash = previousHash
        self.hash = hash
        
        // Might need to modify how this hash is calculated if cloud validation is needed
        //
        self.description = "\(index)\(timestamp)\(bid)\(previousHash)"
    }
    
    init?(dict: [String: AnyObject]) {
        guard let company = dict["company"] as? String, let email = dict["email"] as? String, let hash = dict["hash"] as? String, let index = dict["index"] as? Int, let jobName = dict["jobName"] as? String, let name = dict["name"] as? String, let phoneNumber = dict["phoneNumber"] as? String, let prevHash = dict["previousHash"] as? String, let price = dict["price"] as? Double, let timestamp = dict["timestamp"] as? Int64, let uid = dict["uid"] as? String else { print("init guard failed"); return nil }
        
        let user: User = User(name: name, company: company, email: email, phoneNumber: phoneNumber, uid: uid)
        let bid: Bid = Bid(user: user, jobName: jobName, timestamp: timestamp, price: price, comment: nil)
        
        self.index = index
        self.timestamp = timestamp
        self.bid = bid
        self.previousHash = prevHash
        self.description = "\(index)\(timestamp)\(bid)\(previousHash)"
        self.hash = hash
    }
    
    func toDict() -> [String: Any] {
        if self.bid.comment != nil {
            let dict: [String: Any] = ["jobName": self.bid.jobName,
                                       "company": self.bid.user.company,
                                       "comments": self.bid.comment!,
                                       "name": self.bid.user.name,
                                       "phoneNumber": self.bid.user.phoneNumber,
                                       "email": self.bid.user.email,
                                       "uid": self.bid.user.uid,
                                       "price": self.bid.price,
                                       "timestamp": self.timestamp,
                                       "index": self.index,
                                       "previousHash": self.previousHash,
                                       "hash": self.hash ?? "Broken"
                                    ]
            return dict
        } else {
            let dict: [String: Any] = ["jobName": self.bid.jobName,
                                       "company": self.bid.user.company,
                                       "name": self.bid.user.name,
                                       "phoneNumber": self.bid.user.phoneNumber,
                                       "email": self.bid.user.email,
                                       "uid": self.bid.user.uid,
                                       "price": self.bid.price,
                                       "timestamp": self.timestamp,
                                       "index": self.index,
                                       "previousHash": self.previousHash,
                                       "hash": self.hash ?? "Broken"
                                    ]
             return dict
        }
    }
}
