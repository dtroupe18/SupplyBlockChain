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

class FirebaseFunctions {
    // This class serves as a Firebase Database wrapper. All upload / download data requests to and from Firebase are
    // handlded in this class
    //
    
    static func uploadCompletedBidId(jobId: String, bidId: String, _ completion: @escaping (Error?) -> ()) {
        let ref = Database.database().reference()
        let key = ref.child("jobsIds").childByAutoId().key
        let info = ["bidId": "\(bidId)"]
        let postInfo = ["\(key)" : info]
        ref.child("jobIds").child(jobId).child("bidIds").updateChildValues(postInfo, withCompletionBlock: { (error, ref) in
            if error != nil {
                completion(error)
            } else {
                completion(nil)
            }
        })
    }
    
    static func loadCompletedBidIds(jobId: String, _ completion: @escaping (Error?, [String]?) -> ()) {
        var bidIds: [String] = [String]()
        let ref = Database.database().reference()
        ref.child("jobIds").child(jobId).child("bidIds").observeSingleEvent(of: .value, with: { snap in
            if snap.exists() {
                for child in snap.children {
                    let child = child as? DataSnapshot
                    if let dict = child?.value as? [String: Any] {
                        if let bidId = dict["bidId"] as? String {
                            bidIds.append(bidId)
                        }
                    } else {
                        let error = NSError(domain: "Firebase Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Bid data corrupt."])
                        completion(error, nil)
                    }
                }
                completion(nil, bidIds)
            } else {
                let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "No bids yet!"])
                completion(error, nil)
            }
        })
    }
    
    // Upload additional informationa about the user to Firebase
    //
    static func uploadUserInfo(user: User, _ completion: @escaping (Error?) -> ()) {
        // Upload information about the user to Firebase
        //
        let userInfo: [String: Any] = ["uid": user.uid,
                                       "firstName": user.firstName,
                                       "lastName": user.lastName,
                                       "email": user.email,
                                       "company":  user.company,
                                       "industry":  user.industry,
                                       "phoneNumber": user.phoneNumber,
                                       "isEmployee": user.isEmployee
                                        ]
        
        let ref = Database.database().reference()
        ref.child("users").child(user.uid).setValue(userInfo) { (error, ref) -> Void in
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
                    if let user = User(snapShot: dict) {
                        completion(nil, user)
                    } else {
                        let error = NSError(domain: "Firebase Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dict error cannot create user."])
                        completion(error, nil)
                    }
                }
            } else {
                let error = NSError(domain: "Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "User information not in database"])
                completion(error, nil)
            }
        })
    }
}
