//
//  RecordResponse.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/15/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

struct RecordResponse: Codable {
    
    let accountID, datastoreID, page, pageCount: Int
    let pageSize, recordCount, startDate, endDate: Int
    let records: [Record]
    
    enum CodingKeys: String, CodingKey {
        case accountID = "accountId"
        case datastoreID = "datastoreId"
        case page, pageCount, pageSize, recordCount, startDate, endDate, records
    }
}

struct Record: Codable {
    
    let id, label: String
    let timestamp: Int
}
