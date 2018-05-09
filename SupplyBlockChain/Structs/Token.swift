//
//  Token.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/1/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

struct Token: Codable {
    
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
    
    // Update codable implementation so that keys match
    //
    enum CodingKeys : String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case expiresIn = "expires_in"
    }
    
    func getExpiredToken() -> Token {
        // Return an expired token for testing purposes
        //
        return Token(accessToken: "eyB9eXAiOiJKV1QiLDJhbGciOiJIUzI1NiJ8.eyJpZCI6IjU2ZyyiYzFhNWY5Yjg1MjMyZmRjYWRhNyIsInJsbiI6MjBwMCwicmxpIjoicyIsImlzQWRtaW4iOnRydWUtImlhdCI6MTQ2MTI0NzE2NSwiZXhwIjoxNDYxMjUwNzY1LCJqdGkiOiI1MDUyYmFlZDhkNTM5NjcyNDNiMjkzN2RjNjRjNTcyOTJmNTQwZDZhIn0.KNiG-QHdeaH1jVLJpx0ykov8Kk7ogts69k5OhDkgFVM",
                     refreshToken: "ec71236f77ebd665210912ae8891aa08ee8ec3e4", expiresIn: 3600)
    }
}

