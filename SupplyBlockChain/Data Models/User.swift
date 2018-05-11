//
//  User.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/5/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

struct User: Codable {
    
    let firstName: String
    let lastName: String
    let company: String
    let email: String
    let phoneNumber: String
    let uid: String
    
    // Optional init
    //
    init?(snapShot: [String: Any]) {
        if let firstName = snapShot["firstName"] as? String, let lastName = snapShot["lastName"] as? String, let company = snapShot["company"] as? String, let email = snapShot["email"] as? String, let phone = snapShot["phoneNumber"] as? String, let uid = snapShot["uid"] as? String {
            self.firstName = firstName
            self.lastName = lastName
            self.company = company
            self.email = email
            self.phoneNumber = phone
            self.uid = uid
        } else {
            return nil
        }
    }
    
    init(firstName: String, lastName: String, company: String, email: String, phoneNumber: String, uid: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.company = company
        self.email = email
        self.phoneNumber = phoneNumber
        self.uid = uid
    }
}
