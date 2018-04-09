//
//  BlockChainHelper.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/9/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

class BlockChainHelper {
    
    static func createGenesisBlock(jobName: String) -> Block? {
        let genesisUser: User = User(name: "Genesis", company: "Genesis", email: "Genesis@genesis.com", phoneNumber: "555-555-5555", uid: "abc123")
        let bid: Bid = Bid(user: genesisUser, jobName: jobName, timestamp: Date().millisecondsSince1970, price: 0.0, comment: "Initial Block")
        return Block(index: 0, timestamp: Date().millisecondsSince1970, bid: bid, previousHash: "0000")
        
    }
}
