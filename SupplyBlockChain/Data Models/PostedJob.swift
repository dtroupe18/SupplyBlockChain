//
//  PostedJob.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/15/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import RealmSwift

class PostedJob: Object, Codable {
    
    @objc dynamic var accountID: Int = 0
    @objc dynamic var datastoreID: Int = 0
    @objc dynamic var id: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var sha256: String = ""
    @objc dynamic var json: String = ""
    @objc dynamic var timestamp: Int = 0
    @objc dynamic var job: Job?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case status
        case json
        case sha256
        case timestamp
        case accountID = "accountId"
        case datastoreID = "datastoreId"
        case job = "data"
    }

    required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.accountID = try container.decode(Int.self, forKey: .accountID)
        self.datastoreID = try container.decode(Int.self, forKey: .datastoreID)
        self.status = try container.decode(String.self, forKey: .status)
        self.json = try container.decode(String.self, forKey: .json)
        self.sha256 = try container.decode(String.self, forKey: .sha256)
        self.timestamp = try container.decode(Int.self, forKey: .timestamp)
        self.job = try container.decode(Job.self, forKey: .job)
    }
}
