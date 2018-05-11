//
//  Job.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/11/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import RealmSwift

class Job: Object {
    
    @objc dynamic var name: String = ""
    @objc dynamic var expectedStartDate: Int = 0
    @objc dynamic var expectedEndDate: Int = 0
    @objc dynamic var jobDescription: String = ""
    @objc dynamic var industry: String = ""
    
    
    
}
