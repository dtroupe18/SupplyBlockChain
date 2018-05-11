//
//  Token.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/1/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import RealmSwift

/* Currently unused because the Hash API isn't being used */

class Token: Object, Codable {
    
    @objc dynamic var accessToken: String = ""
    @objc dynamic var refreshToken: String = ""
    @objc dynamic var expiresIn: Int = 0
    
    // Update codable implementation so that keys match
    //
    enum CodingKeys : String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
    
    convenience init(accessToken: String, refreshToken: String, expiresIn: Int) {
        self.init()
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresIn = expiresIn
    }
    
    func getExpiredToken() -> Token {
        // Return an expired token for testing purposes
        //
        return Token(accessToken: "eyB9eXAiOiJKV1QiLDJhbGciOiJIUzI1NiJ8.eyJpZCI6IjU2ZyyiYzFhNWY5Yjg1MjMyZmRjYWRhNyIsInJsbiI6MjBwMCwicmxpIjoicyIsImlzQWRtaW4iOnRydWUtImlhdCI6MTQ2MTI0NzE2NSwiZXhwIjoxNDYxMjUwNzY1LCJqdGkiOiI1MDUyYmFlZDhkNTM5NjcyNDNiMjkzN2RjNjRjNTcyOTJmNTQwZDZhIn0.KNiG-QHdeaH1jVLJpx0ykov8Kk7ogts69k5OhDkgFVM",
                     refreshToken: "ec71236f77ebd665210912ae8891aa08ee8ec3e4", expiresIn: 3600)
    }
}

