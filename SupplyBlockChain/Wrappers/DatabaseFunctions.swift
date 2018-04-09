//
//  DatabaseFunctions.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/5/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class DatabaseFunctions {
    // This class serves as a Firebase Database wrapper. All upload / download data requests to and from Firebase are
    // handlded in this class
    //
    
    // Upload additional informationa about the user to Firebase
    //
    static func uploadUserInfo(uid: String, name: String, email: String, company: String, phoneNumber: String, _ completion: @escaping (Error?) -> ()) {
        // Upload information about the user to Firebase
        //
        let userInfo: [String: Any] = ["uid": uid,
                                       "displayName": name,
                                       "email": email,
                                       "company":  company,
                                       "phoneNumber": phoneNumber
                                        ]
        
        let ref = Database.database().reference()
        ref.child("users").child(uid).setValue(userInfo) { (error, ref) -> Void in
            if error != nil {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    // Function to retrieve all of a users information that cannot be stored in the default Firebase user object
    //
    static func getUserInfo(_ completion: @escaping (Error?, User?) -> ()) {
        guard let uid = Auth.auth().currentUser?.uid else {
            let error = NSError(domain: "Uid Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No UID"])
            completion(error, nil)
            return
        }
        let ref = Database.database().reference()
        ref.child("users").child(uid).observeSingleEvent(of: .value, with: { snap in
            if snap.exists() {
                if let dict = snap.value as? [String: Any] {
                    print("dict: \(dict)")
                    if let user = User(snapShot: dict) {
                        completion(nil, user)
                    } else {
                        let error = NSError(domain: "Dict Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dict Error cannot create user."])
                        completion(error, nil)
                    }
                }
            } else {
                let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "User information not in database"])
                completion(error, nil)
            }
        })
    }
    
    static func getLastBlock(jobName: String, _ completion: @escaping (DataSnapshot?) -> ()) {
        let ref = Database.database().reference()
        // Limit to last one because that will be the most recent chain
        //
        ref.child("processedBids").child(jobName).queryOrderedByKey().queryLimited(toLast: 1).observeSingleEvent(of: .value, with: { snap in
            if snap.exists() {
                completion(snap)
                
            } else {
                // print("***************")
                completion(nil)
            }
        })
    }
    
    static func uploadBid(genesisBlock: Block?, bidBlock: Block, _ completion: @escaping (Error?) -> ()) {
        if genesisBlock != nil {
            uploadBid(block: genesisBlock!, { error in
                if error == nil {
                    // Upload the other block
                    //
                    uploadBid(block: bidBlock, { err in
                        if err == nil {
                            completion(nil)
                        } else {
                            completion(err)
                        }
                    })
                } else {
                    completion(error)
                }
            })
        }
    }
    
    static func uploadBid(block: Block, _ completion: @escaping (Error?) -> ()) {
        let ref = Database.database().reference()
        let key = ref.child(block.bid.jobName).childByAutoId().key
        
        // Firebase does not work with Swift 4 codable so we still have to create a dictionary for each block
        // let encodedBlock = try? JSONEncoder().encode(block)
        //
        let blockDict = block.toDict()

        ref.child("processedBids").child(block.bid.jobName).child("\(key)").setValue(blockDict) { (error, ref) -> Void in
            if error != nil {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
}
