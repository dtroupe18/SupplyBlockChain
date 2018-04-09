//
//  Bid.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/9/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

struct Bid: Codable {
    let user: User
    let jobName: String
    let timestamp: Int64
    let price: Double
    let comment: String?
    
    init(user: User, jobName: String, timestamp: Int64, price: Double, comment: String?) {
        self.user = user
        self.jobName = jobName
        self.timestamp = timestamp
        self.price = price
        self.comment = comment
    }
}
