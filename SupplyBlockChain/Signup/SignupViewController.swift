//
//  SignupViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 3/30/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import Eureka

class SignupViewController: FormViewController {
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Show the navigation bar so the user can get back to the home screen
        //
        showNavigationBar()
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create submit button in the navigation bar
        //
        let submitButton = UIButton(type: .custom)
        submitButton.setTitle("Done", for: .normal)
        submitButton.setTitleColor(.black, for: .normal)
        submitButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        submitButton.addTarget(self, action: #selector(self.submitPressed), for: .touchUpInside)
        let submitItem = UIBarButtonItem(customView: submitButton)
        self.navigationItem.setRightBarButtonItems([submitItem], animated: false)

        form +++ Section("Personal Information")
            <<< TextRow() {
                $0.tag = "First Name"
                $0.title = "First Name"
                $0.placeholder = "Steve"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
                
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            
            <<< TextRow() {
                $0.tag = "Last Name"
                $0.title = "Last Name"
                $0.placeholder = "Jobs"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            
            <<< PhoneRow() {
                $0.tag = "Phone Number"
                $0.title = "Phone Number"
                $0.placeholder = "867-5309"
                // $0.add(rule: RuleRequired())
                // $0.validationOptions = .validatesOnChange
            }
            
            +++ Section("Business Information")
            <<< TextRow() {
                $0.tag = "Business Name"
                $0.title = "Name"
                $0.placeholder = "Apple"
            }
        
            +++ Section("User Account")
            <<< EmailRow() {
                $0.tag = "Email"
                $0.title = "Email"
                $0.placeholder = "SteveJobs@apple.com"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
            
            <<< PasswordRow() {
                $0.tag = "Password"
                $0.title = "Password"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
            }
            
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        
            <<< PasswordRow() { row in
                row.tag = "Confirm Password"
                row.title = "Confirm Password"
                row.add(rule: RuleRequired())
                row.validationOptions = .validatesOnChange
            }
        
            .cellUpdate { cell, row in
                if !row.isValid {
                    cell.titleLabel?.textColor = .red
                }
            }
        
        animateScroll = true
        rowKeyboardSpacing = 20
    }
    
    @objc func submitPressed() {
        print("Submit Pressed\n")
        let formValuesDict = self.form.values()
        
        let errors = form.validate()
        print(errors.count)
        
        if errors.count > 0 {
            print(errors.count)
        } else {
            // Sign the user up and save the data
            //
            print("Form: \(formValuesDict)\n")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
