//
//  CreateBidViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 4/5/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAuth
import FirebaseDatabase

class CreateBidViewController: FormViewController {
    
    var userInfo: User?
    var job: String?
    
    // Variables that need to be updated as the user creates their bid
    //
    var currentIndex: Int?
    var previousHash: String?
    var observeRef: DatabaseReference?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = job
        observeChanges()
        
        // Create submit button in the navigation bar
        //
        let submitButton = UIButton(type: .custom)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        submitButton.addTarget(self, action: #selector(self.submitPressed), for: .touchUpInside)
        let submitItem = UIBarButtonItem(customView: submitButton)
        self.navigationItem.setRightBarButtonItems([submitItem], animated: false)
        
        if let info = userInfo {
            
            form +++ Section("Business Information")
                <<< TextRow() {
                    $0.tag = "Company Name"
                    $0.title = "Company Name"
                    $0.value = info.company
                    // $0.disabled = true
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                }
                
                <<< TextRow() {
                    $0.tag = "Name"
                    $0.title = "Name"
                    $0.value = info.name
                    // $0.disabled = true
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                }
                
                <<< TextRow() {
                    $0.tag = "Email"
                    $0.title = "Email"
                    $0.value = info.email
                    // $0.disabled = true
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                }
                
                <<< TextRow() {
                    $0.tag = "Phone Number"
                    $0.title = "Phone Number"
                    $0.value = info.phoneNumber
                    // $0.disabled = true
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                }
                
                +++ Section("Bid Information")
                <<< TextRow() {
                    $0.tag = "Job Name"
                    $0.title = "Job"
                    $0.value = job ?? ""
                    if job != nil {
                        $0.disabled = true
                    }
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                }
                
                <<< DecimalRow() {
                    $0.tag = "Price"
                    $0.title = "Bid Price"
                    $0.placeholder = "0"
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                    }
                    .cellUpdate { cell, row in
                        if !row.isValid {
                            cell.titleLabel?.textColor = .red
                        }
                }
                
                +++ Section("Comments")
                <<< TextAreaRow() {
                    $0.tag = "Comments"
                    $0.title = "Comments"
                    $0.placeholder = "..."
                    // Not Required!
                    //
            }
        }
    }
    
    private func getFormError() -> ValidationError? {
        let errors = form.validate()
        if errors.count == 0 {
            return nil
        } else {
            if let error = errors.last {
                return error
            } else {
                return ValidationError(msg: "Form value missing!")
            }
        }
    }
    
    @objc func submitPressed() {
        if let error = getFormError() {
            showAlert(title: "Error", message: error.msg)
        } else {
            SmallActivityIndicator.shared.showActivityIndicator(uiView: self.view)
            let formValuesDict = self.form.values()
            
            // Make sure we have all the formValues
            //
            guard let company = formValuesDict["Company Name"] as? String, let name = formValuesDict["Name"] as? String, let email = formValuesDict["Email"] as? String, let phoneNumber = formValuesDict["Phone Number"] as? String, let jobName = formValuesDict["Job Name"] as? String, let price = formValuesDict["Price"] as? Double, let uid = Auth.auth().currentUser?.uid  else {
                SmallActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                showAlert(title: "Error", message: "Form is missing values!")
                return
            }
            
            let user: User = User(name: name, company: company, email: email, phoneNumber: phoneNumber, uid: uid)
            let bid: Bid = Bid(user: user, jobName: jobName, timestamp: Date().millisecondsSince1970, price: price, comment: formValuesDict["Comments"] as? String)
            
            
            // Upload this bid to firebase
            //
            DatabaseFunctions.getLastBlock(jobName: jobName, { snapShot in
                if snapShot == nil {
                    if let genesisBlock = BlockChainHelper.createGenesisBlock(jobName: jobName) {
                        if let bidBlock = Block(index: 1, timestamp: Date().millisecondsSince1970, bid: bid, previousHash: genesisBlock.previousHash) {
                            
                            DatabaseFunctions.uploadBid(genesisBlock: genesisBlock, bidBlock: bidBlock, { error in
                                if error != nil {
                                    SmallActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                                    self.showAlert(title: "Error", message: error!.localizedDescription)
                                } else {
                                    DatabaseFunctions.uploadBidToUserInformation(block: bidBlock)
                                    self.presentSuccessAlert()
                                }
                            })
                        }
                    }
                } else {
                    self.processSnapShot(snap: snapShot!, bid: bid)
                }
            })
        }
    }
    
    private func processSnapShot(snap: DataSnapshot, bid: Bid) {
        for child in snap.children {
            let child = child as? DataSnapshot
            if let response = child?.value as? [String: AnyObject] {
                if var lastHash = response["hash"] as? String, var index = response["index"] as? Int {
                    // Check if currentIndex and previous hash have been updated
                    //
                    if let observedIndex = self.currentIndex, let prevHash = self.previousHash {
                        if observedIndex > index {
                            // Update the index and hash if needed
                            //
                            index = observedIndex
                            lastHash = prevHash
                        }
                    }
                    if let bidBlock = Block(index: index + 1, timestamp: Date().millisecondsSince1970, bid: bid, previousHash: lastHash) {
                        DatabaseFunctions.uploadBid(block: bidBlock, { error in
                            if error != nil {
                                SmallActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                                self.showAlert(title: "Error", message: error!.localizedDescription)
                            } else {
                                DatabaseFunctions.uploadBidToUserInformation(block: bidBlock)
                                self.presentSuccessAlert()
                            }
                        })
                    }
                }
            }
        }
    }
    
    // Sucess alert with action
    //
    func presentSuccessAlert() {
        SmallActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
        let alertController = UIAlertController(title: "Success", message: "Your bid was successfully submitted for \(self.job ?? "")", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func observeChanges() {
        if let jobName = job {
            observeRef = Database.database().reference()
            // Bids in the block chain cannot be removed or modified. Every action requires a new block
            // to be forged. Therefore we just listen for childAdded. This way we can keep the index and
            // previous hash in sync
            //
            observeRef?.child("processedBids").child(jobName).observe(.childAdded, with: { snap in
                for child in snap.children {
                    let child = child as? DataSnapshot
                    if let response = child?.value as? [String: AnyObject] {
                        if let lastHash = response["hash"] as? String, let index = response["index"] as? Int {
                            self.currentIndex = index + 1
                            self.previousHash = lastHash
                        }
                    }
                }
            })
        }
    }
    
    deinit {
        // Remove observer when this class is deallocated
        //
        observeRef?.removeAllObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
