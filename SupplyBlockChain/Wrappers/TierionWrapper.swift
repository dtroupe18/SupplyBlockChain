//
//  TierionWrapper.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/1/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation
import Alamofire
import RealmSwift

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
    
    // Get the default Realm
    //
    let realm = try! Realm()
    
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
    
    func getAllDataStores(_ completion: @escaping (Error?, [DataStore]?) -> ()) {
        guard let headers = getHeaders() else { print("Error headers are nil!"); return }
        
        Alamofire.request("https://api.tierion.com/v1/datastores",
                          method: .get,
                          parameters: nil,
                          encoding: URLEncoding.default,
                          headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                case .success(_):
                    guard let jsonData = response.data else {
                        let error: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Empty response data"])
                        completion(error, nil)
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let dataStores: [DataStore] = try decoder.decode([DataStore].self, from: jsonData)
                        completion(nil, dataStores)
                    } catch {
                        let err: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(error)"])
                        completion(err, nil)
                    }
                    
                case .failure(_):
                    let err = response.result.error as NSError?
                    completion(err, nil)
                }
        }
    }
    
    func getDataStore(dataStoreId id: Int, _ completion: @escaping (Error?, DataStore?) -> ()) {
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
                switch response.result {
                    
                case .success(_):
                    guard let jsonData = response.data else {
                        let error: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Empty response data"])
                        completion(error, nil)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    do {
                        let dataStore: DataStore = try decoder.decode(DataStore.self, from: jsonData)
                        completion(nil, dataStore)
                    } catch {
                        let err: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(error)"])
                        completion(err, nil)
                    }
                    
                case .failure(_):
                    let err = response.result.error as NSError?
                    completion(err, nil)
                }
        }
    }
    
    func postBidToTierion(dataStoreId: Int, bid: Bid, _ completion: @escaping (NSError?, PostedBid?) ->()) {
        // https://api.tierion.com/v1/records
        //
        guard let headers = getHeaders() else {
            let error: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured please try again."])
            completion(error, nil)
            return
        }
        
        let parameters: [String: Any] = [
            // datastoreid is REQUIRED by Tierion
            //
            "datastoreId": dataStoreId,
            "email": "\(bid.email)",
            "name": "\(bid.name)",
            "uid": "\(bid.uid)",
            "price": "\(bid.price)",
            "jobName": "\(bid.jobName)",
            "phoneNumber": "\(bid.phoneNumber)",
            "companyName": "\(bid.companyName)",
            "comments": "\(bid.comments)"
        ]
        
        Alamofire.request("https://api.tierion.com/v1/records/\(dataStoreId)",
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                case .success(_):
                    guard let jsonData = response.data else {
                        let error: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Empty response data"])
                        completion(error, nil)
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let completedBid: PostedBid = try decoder.decode(PostedBid.self, from: jsonData)
                        completion(nil, completedBid)
                    } catch {
                        let err: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(error)"])
                        completion(err, nil)
                    }
                    
                case .failure(_):
                    let err = response.result.error as NSError?
                    completion(err, nil)
                }
        }
    }
    
    func postJobToTierion(dataStoreId: Int, job: Job, _ completion: @escaping (NSError?, PostedJob?) ->()) {
        // https://api.tierion.com/v1/records
        //
        guard let headers = getHeaders() else {
            let error: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "An unknown error occured please try again."])
            completion(error, nil)
            return
        }
        
        let parameters: [String: Any] = [
            "datastoreId": dataStoreId,
            "jobName": job.jobName,
            "expectedStartDate": job.expectedStartDate,
            "expectedEndDate": job.expectedEndDate,
            "jobDescription": job.jobDescription,
            "industry": job.industry,
            "comments": job.comments,
            "companyName": job.companyName,
            "postedBy": job.postedBy,
            "posterEmail": job.posterEmail,
            "posterPhoneNumber": job.posterPhoneNumber
        ]
        
        Alamofire.request("https://api.tierion.com/v1/records/\(dataStoreId)",
            method: .post,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers)
            //.validate()
            .responseJSON { response in
                print(response)
                switch response.result {
                    
                case .success(_):
                    guard let jsonData = response.data else {
                        let error: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Empty response data"])
                        completion(error, nil)
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let postedJob: PostedJob = try decoder.decode(PostedJob.self, from: jsonData)
                        completion(nil, postedJob)
                    } catch {
                        let err: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(error)"])
                        completion(err, nil)
                    }
                    
                case .failure(_):
                    let err = response.result.error as NSError?
                    completion(err, nil)
                }
        }
    }
    
    func getDataStoreRecords(dataStoreId id: Int, _ completion: @escaping (NSError?, RecordResponse?) -> ()) {
        // https://api.tierion.com/v1/records?datastoreId=<datastoreId>
        //
        guard let headers = getHeaders() else { print("Error headers are nil!"); return }
        
        Alamofire.request("https://api.tierion.com/v1/records?datastoreId=\(id)",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                case .success(_):
                    guard let jsonData = response.data else {
                        let error: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Empty response data"])
                        completion(error, nil)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    do {
                        let recordResponse: RecordResponse = try decoder.decode(RecordResponse.self, from: jsonData)
                        completion(nil, recordResponse)
                    } catch {
                        let err: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(error)"])
                        completion(err, nil)
                    }
                    
                case .failure(_):
                    let err = response.result.error as NSError?
                    completion(err, nil)
                }
        }
    }
    
    func getDataStoreJobDetails(recordId id: String, _ completion: @escaping (NSError?, PostedJob?) -> ()) {
        // https://api.tierion.com/v1/records/<id>
        //
        guard let headers = getHeaders() else { print("Error headers are nil!"); return }
        
        Alamofire.request("https://api.tierion.com/v1/records/\(id)",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers)
            .validate()
            .responseJSON { response in
                switch response.result {
                    
                case .success(_):
                    guard let jsonData = response.data else {
                        let error: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Empty response data"])
                        completion(error, nil)
                        return
                    }
                    
                    let decoder = JSONDecoder()
                    do {
                        let postedJob: PostedJob = try decoder.decode(PostedJob.self, from: jsonData)
                        completion(nil, postedJob)
                    } catch {
                        let err: NSError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "\(error)"])
                        completion(err, nil)
                    }
                    
                case .failure(_):
                    let err = response.result.error as NSError?
                    completion(err, nil)
                }
        }
    }
    
    func getHashToken(_ completion: @escaping (NSError?, Token?) -> ()) {
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
                    if response.data != nil {
                        let jsonData = response.data!
                        let decoder = JSONDecoder()
                        do {
                            let token = try decoder.decode(Token.self, from: jsonData)
                            self.authToken = token
                            completion(nil, token)
                        } catch {
                            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error parsing token"])
                            completion(error, nil)
                        }
                    } else {
                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Response nil"])
                        completion(error, nil)
                    }
                    
                case .failure(_):
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "Error request failure"])
                    completion(error, nil)
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



