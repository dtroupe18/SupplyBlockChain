//
//  Block.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/9/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation


struct Block {
    let index: Int
    let timestamp: Int64
    let bid: Bid
    let previousHash: String
    let hash: String
    
    init(index: Int, timestamp: Int64, bid: Bid, previousHash: String, hash: String) {
        self.index = index
        self.timestamp = timestamp
        self.bid = bid
        self.previousHash = previousHash
        
        // Probably want to calculate this hash rather than pass the value in
        //
        self.hash = hash
    }
}
