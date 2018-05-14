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
                                       "phoneNumber": user.phoneNumber
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
                    // print("dict: \(dict)")
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
}
