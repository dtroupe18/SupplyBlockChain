//
//  Date++Extension.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/9/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
