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
    
    static func getBidBlockChain(jobName: String, _ completion: @escaping (DataSnapshot?) -> ()) {
        print("\nCheck called....")
        let ref = Database.database().reference()
        ref.child("processedBids").child(jobName).observeSingleEvent(of: .value, with: { snap in
            if snap.exists() {
                completion(snap)
            } else {
                print("***************")
                completion(nil)
            }
        })
    }
}
