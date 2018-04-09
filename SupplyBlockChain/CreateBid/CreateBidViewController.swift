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

class CreateBidViewController: FormViewController {
    
    var userInfo: User?
    var job: String?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = job
        
        // Create submit button in the navigation bar
        //
        let submitButton = UIButton(type: .custom)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
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
    
    @objc func submitPressed() {
        guard let jobName = job else { return }
        let formValuesDict = self.form.values()
        let timestamp = Date().millisecondsSince1970
        
        
        let errors = form.validate()
        if errors.count > 0 {
            if let error = errors.last {
                showAlert(title: "Error", message: error.msg)
            }
        } else {
            // Make sure we have all the formValues
            //
            guard let company = formValuesDict["Company Name"] as? String, let name = formValuesDict["Name"] as? String, let email = formValuesDict["Email"] as? String, let phoneNumber = formValuesDict["Phone Number"] as? String, let jobName = formValuesDict["Job Name"] as? String, let price = formValuesDict["Bid Price"] as? Double, let uid = Auth.auth().currentUser?.uid  else {
                print("Giant guard failed")
                return
            }
            
            let user: User = User(name: name, company: company, email: email, phoneNumber: phoneNumber, uid: uid)
            let bid: Bid = Bid(user: user, jobName: jobName, timeStamp: Date().millisecondsSince1970, price: price, comment: formValuesDict["Comments"] as? String)
            
            
            // Upload this bid to firebase
            //
            DatabaseFunctions.getBidBlockChain(jobName: jobName, { snapShot in
                if snapShot == nil {
                    print("First bid for \(jobName)")
                } else {
                    print("Not first bid for \(jobName)")
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
