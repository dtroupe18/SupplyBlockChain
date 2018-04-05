//
//  User.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/5/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

struct User {
    
    let name: String
    let company: String
    let email: String
    let phoneNumber: String
    let uid: String
    
    // Optional init
    //
    init?(snapShot: [String: Any]) {
        if let name = snapShot["displayName"] as? String, let company = snapShot[""] as? String, let email = snapShot[""] as? String, let phone = snapShot[""] as? String, let uid = snapShot[""] as? String {
            self.name = name
            self.company = company
            self.email = email
            self.phoneNumber = phone
            self.uid = uid
        } else {
            return nil
        }
    }
}
