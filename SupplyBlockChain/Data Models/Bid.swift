//
//  Bid.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/9/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import RealmSwift

/* This class represents a bid BEFORE it is uploaded to Tierion */

class Bid: Object, Codable {
    
    @objc dynamic var email: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var price: String = ""
    @objc dynamic var jobName: String = ""
    @objc dynamic var phoneNumber: String = ""
    @objc dynamic var companyName: String = ""
    @objc dynamic var comments: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case email
        case name
        case price
        case jobName = "jobname"
        case phoneNumber = "phonenumber"
        case companyName = "companyname"
        case comments
    }
    
    func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)        
        self.email = try container.decode(String.self, forKey: .email)
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decode(String.self, forKey: .price)
        self.jobName = try container.decode(String.self, forKey: .jobName)
        self.phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        self.companyName = try container.decode(String.self, forKey: .companyName)
        self.comments = try container.decode(String.self, forKey: .comments)
    }
    
    convenience init?(dict: [String: Any?]) {
        self.init()
        guard let email = dict["Email"] as? String, let name = dict["Name"] as? String, let price = dict["Price"] as? Double, let jobName = dict["Job Name"] as? String, let phoneNumber = dict["Phone Number"] as? String, let companyName = dict["Company Name"] as? String else { print("Guard failed..."); return nil }
        
        self.email = email
        self.name = name
        self.price = "\(price)"
        self.jobName = jobName
        self.phoneNumber = phoneNumber
        self.companyName = companyName
        
        if let comments = dict["Comments"] as? String {
            self.comments = comments
        }
    }
}

//struct Bid: Codable {
//
//    let email: String
//    let name: String
//    let price: String
//    let jobName: String
//    let phoneNumber: String
//    let companyName: String
//    let comments: String?
//
//    private enum CodingKeys: String, CodingKey {
//        case email
//        case name
//        case price
//        case jobName = "jobname"
//        case phoneNumber = "phonenumber"
//        case companyName = "companyname"
//        case comments
//    }
//
//    init?(dict: [String: Any?])  {
//        guard let email = dict["Email"] as? String, let name = dict["Name"] as? String, let price = dict["Price"] as? Double, let jobName = dict["Job Name"] as? String, let phoneNumber = dict["Phone Number"] as? String, let companyName = dict["Company Name"] as? String else { print("Guard failed..."); return nil }
//
//        self.email = email
//        self.name = name
//        self.price = "\(price)"
//        self.jobName = jobName
//        self.phoneNumber = phoneNumber
//        self.companyName = companyName
//
//        if let comments = dict["Comments"] as? String {
//            self.comments = comments
//        } else {
//            self.comments = nil
//        }
//    }
//}
