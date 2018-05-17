//
//  Job.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/11/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import RealmSwift

class Job: Object, Codable {
    
    @objc dynamic var jobName: String = ""
    @objc dynamic var expectedStartDate: String = ""
    @objc dynamic var expectedEndDate: String = ""
    @objc dynamic var jobDescription: String = ""
    @objc dynamic var industry: String = ""
    @objc dynamic var comments: String = ""
    @objc dynamic var companyName: String = ""
    @objc dynamic var postedBy: String = ""
    @objc dynamic var posterEmail: String = ""
    @objc dynamic var posterPhoneNumber: String = ""
    
    
    // Define the child relationship -> Each job can have many Completed Bids
    //
    let postedBids = List<PostedBid>()
    
    private enum CodingKeys: String, CodingKey {
        case jobName = "jobname"
        case expectedStartDate = "expectedstartdate"
        case expectedEndDate = "expectedenddate"
        case jobDescription = "jobdescription"
        case industry
        case comments
        case companyName = "companyname"
        case postedBy = "postedby"
        case posterEmail = "posteremail"
        case posterPhoneNumber = "posterphonenumber"
    }
    
    // Decoder becomes a func when you are using it on "nested" JSON data
    //
    func decode(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.jobName = try container.decode(String.self, forKey: .jobName)
        self.expectedStartDate = try container.decode(String.self, forKey: .expectedStartDate)
        self.expectedEndDate = try container.decode(String.self, forKey: .expectedEndDate)
        self.jobDescription = try container.decode(String.self, forKey: .jobDescription)
        self.industry = try container.decode(String.self, forKey: .industry)
        self.comments = try container.decode(String.self, forKey: .comments)
        self.companyName = try container.decode(String.self, forKey: .companyName)
        self.postedBy = try container.decode(String.self, forKey: .postedBy)
        self.posterEmail = try container.decode(String.self, forKey: .posterEmail)
        self.posterPhoneNumber = try container.decode(String.self, forKey: .posterPhoneNumber)
    }
    
    convenience init?(form: [String: Any?]) {
        self.init()

        if let description = form["Description"] as? String, let email = form["Email"] as? String, let startDate = form["Start Date"] as? Date, let endDate = form["End Date"] as? Date, let jobName = form["Job Name"] as? String, let phoneNumber = form["Phone Number"] as? String,  let companyName = form["Company Name"] as? String, let postedBy = form["Name"] as? String {

            self.jobName = jobName
            self.expectedStartDate = "\(Int(startDate.timeIntervalSince1970))"
            self.expectedEndDate = "\(Int(endDate.timeIntervalSince1970))"
            self.jobDescription = description
            self.companyName = companyName
            self.postedBy = postedBy
            self.posterEmail = email
            self.posterPhoneNumber = phoneNumber
        } else {
            return nil
        }

        if let industry = form["IT"] as? String  {
            self.industry = industry
        } else if let industry = form["Pharmaceutical"] as? String  {
            self.industry = industry
        } else if let industry = form["Medical"] as? String  {
            self.industry = industry
        } else {
            return nil
        }

        if let comments = form["Comments"] as? String {
            self.comments = comments
        }
    }
}
