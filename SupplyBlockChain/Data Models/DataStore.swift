//
//  DataStore.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/15/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import RealmSwift

/*
 DataStore is the name of the difference places you can store data on Tierion.
 
 There are two DataStores used for this app.
    1. Jobs - which stores all of the jobs and their information
    2. Bids - which stores all of the bids for every job
*/


class DataStore: Object, Codable {
    
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var key: String = ""
    @objc dynamic var postDataEnabled: Bool = false

    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.key = try container.decode(String.self, forKey: .key)
        self.postDataEnabled = try container.decode(Bool.self, forKey: .postDataEnabled)
    }
}

