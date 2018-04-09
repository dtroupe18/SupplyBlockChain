//
//  Bid.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/9/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

struct Bid {
    let user: User
    let jobName: String
    let timeStamp: Int64
    let price: Double
    let comment: String?
    
    init(user: User, jobName: String, timeStamp: Int64, price: Double, comment: String?) {
        self.user = user
        self.jobName = jobName
        self.timeStamp = timeStamp
        self.price = price
        self.comment = comment
    }
}
