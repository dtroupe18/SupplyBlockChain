//
//  Int++Extension.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/16/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

extension Int {
    var dateString: String {
        let date = NSDate(timeIntervalSince1970: Double(self))
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        
        return formatter.string(from: date as Date)
    }
}
