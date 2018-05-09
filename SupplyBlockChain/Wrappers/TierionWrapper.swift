//
//  TierionWrapper.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/1/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class TierionWrapper {
    // This class is a singleton
    //
    static let shared = TierionWrapper()
    
    // Init is private so another instance of this class cannot be created
    //
    private init() {}
    
    private var authHeaders: [String: String]?
    private var hashTokenParams: [String: String]?
    
    private var authToken: Token?
    
    private func getHeaders() -> [String: String]? {
        if authHeaders != nil {
            return authHeaders!
        } else {
            guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else { return nil }
            guard let keys = NSDictionary(contentsOfFile: path) else { return nil }
            guard let apiKey = keys["apiKey"], let username = keys["username"] else { return nil }
            self.authHeaders = ["X-Username": "\(username)", "X-Api-Key": "\(apiKey)"]
            return authHeaders!
        }
    }
    
    private func getHashTokenParameters() -> [String: String]? {
        if hashTokenParams != nil {
            return hashTokenParams!
        } else {
            guard let path = Bundle.main.path(forResource: "Keys", ofType: "plist") else { return nil }
            guard let keys = NSDictionary(contentsOfFile: path) else { return nil }
            guard let password = keys["password"], let username = keys["username"] else { return nil }
            hashTokenParams = ["username": "\(username)","password": "\(password)"]
            return hashTokenParams!
        }
    }
    
    func getAllDataStores() {
        guard let headers = getHeaders() else { print("Error headers are nil!"); return }
        
        Alamofire.request("https://api.tierion.com/v1/datastores",
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: headers)
            .validate()
            .responseJSON { response in
                if response.result.value != nil{
                    print(response)
                } else {
                    print("some how it's nil")
                    print(response)
                }
        }
    }
    
    func getDataStore(id: Int) {
        // https://api.tierion.com/v1/datastores/<id>
        //
        guard let headers = getHeaders() else { print("Error headers are nil!"); return }
        
        Alamofire.request("https://api.tierion.com/v1/datastores/\(id)",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers)
            .validate()
            .responseJSON { response in
                if response.result.value != nil{
                    print(response)
                } else {
                    print("getDataStore is nil")
                    print(response)
                }
        }
    }
    
    func createRecord(dataStoreId: Int) {
        // https://api.tierion.com/v1/records
        //
        guard let headers = getHeaders() else { print("Error headers are nil!"); return }
        
        let parameters = [
            "datastoreId": dataStoreId,
            "firstname": "Milton",
            "lastname": "Waddams",
            "emailaddress": "mwaddams@initech.net",
            "companyname": "Initech",
            "employment status": "Not Found",
            "department": "Basement",
            "likes": "Red Swingline Staplers"
            ] as [String : Any]
        
        Alamofire.request("https://api.tierion.com/v1/records/\(dataStoreId)",
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers)
            .validate()
            .responseJSON { response in
                if response.result.value != nil{
                    print(response)
                } else {
                    print("getDataStore is nil")
                    print(response)
                }
        }
    }
    
    func getHashToken(_ completion: @escaping (Token?, NSError?) -> ()) {
        // https://hashapi.tierion.com/v1/auth/token
        //
        guard let headers = getHeaders() else { print("Error headers are nil!"); return }
        guard let params = getHashTokenParameters() else { print("Error params are nil!"); return }
        
        Alamofire.request("https://hashapi.tierion.com/v1/auth/token/",
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                case .success(_):
                    print("Validation Successful")
                    if response.data != nil {
                        let jsonData = response.data!
                        let decoder = JSONDecoder()
                        do {
                            let token = try decoder.decode(Token.self, from: jsonData)
                            self.authToken = token
                            completion(token, nil)
                        } catch {
                            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error parsing token"])
                            completion(nil, error)
                        }
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Response nil"])
                        completion(nil, error)
                    }
                    
                case .failure(_):
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error request failure"])
                    completion(nil, error)
                }
        }
    }
    
    func refreshToken() {
        guard let refreshToken = authToken?.refreshToken else { return }
        let params = ["refreshToken": refreshToken]
    
        Alamofire.request("https://hashapi.tierion.com/v1/auth/refresh",
                          method: .post,
                          parameters: params,
                          encoding: URLEncoding.default,
                          headers: nil)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(_):
                    print("Validation Successful")
                case .failure(_):
                    // check or assume failure is due to invalid token
                   print("failure")
                }
        }
    }
}



