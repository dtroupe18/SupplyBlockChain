//
//  User.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/5/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import RealmSwift

/* This class will represent a JNJ supplier. So they will have an Array of CompletedBids */

class User: Object {
    
    @objc dynamic var firstName: String = ""
    @objc dynamic var lastName: String = ""
    @objc dynamic var company: String = ""
    @objc dynamic var industry: String = ""
    @objc dynamic var isEmployee: Bool = false
    @objc dynamic var email: String = ""
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var uid: String = ""
    
    // Define the child relationship -> Each user can have many CompletedBids
    //
    let completedBids = List<CompletedBid>()
    
    // TODO: Add jobs for employee use, just make it optional???
    
    // Optional init used if we have to fetch user data from Firebase
    //
    convenience init?(snapShot: [String: Any]) {
        if let firstName = snapShot["firstName"] as? String, let lastName = snapShot["lastName"] as? String,
            let company = snapShot["company"] as? String, let email = snapShot["email"] as? String,
            let phone = snapShot["phoneNumber"] as? String, let uid = snapShot["uid"] as? String,
            let industry = snapShot["industry"] as? String, let isEmployee = snapShot["isEmployee"] as? Bool {

            self.init()
            self.firstName = firstName
            self.lastName = lastName
            self.company = company
            self.industry = industry
            self.isEmployee = isEmployee
            self.email = email
            self.phoneNumber = phone
            self.uid = uid
        } else {
            return nil
        }
    }
    
    convenience init(form: SignUpForm, uid: String) {
        self.init()
        self.firstName = form.firstName
        self.lastName = form.lastName
        self.company = form.company
        self.email = form.email
        self.phoneNumber = form.phoneNumber
        self.uid = uid
        self.industry = form.industry
        self.isEmployee = form.isEmployee
    }
}
