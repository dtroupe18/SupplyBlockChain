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
    var description: String
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
        self.description = "\(index)\(timestamp)\(bid)\(previousHash)"
    }
    
    func toDict() -> [String: Any] {
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
