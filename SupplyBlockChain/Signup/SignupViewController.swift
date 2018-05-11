//
//  SignupViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 3/30/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import Eureka
import FirebaseAuth
import FirebaseDatabase

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
        submitButton.setTitle("Submit", for: .normal)
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
            
            <<< SwitchRow() {
                $0.tag = "SwitchRow"
                $0.title = "Johnson & Johnson Employee"
            }
            .onChange {
                $0.updateCell()
            }
            .cellUpdate { cell, row in
                if row.isDisabled {
                    cell.textLabel?.font = .boldSystemFont(ofSize: 18.0)
                } else {
                    cell.textLabel?.font = .systemFont(ofSize: 18.0)
                }
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
        
            <<< PasswordRow() {
                $0.tag = "ConfirmPassword"
                $0.title = "Password"

                let passwordsMatchRule = RuleClosure<String> { rowValue in
                    let formValuesDict = self.form.values()
                    if let password = formValuesDict["Password"] as? String {
                        if password != rowValue {
                            return ValidationError(msg: "Passwords do not match!")
                        } else {
                            return nil
                        }
                    } else {
                        return ValidationError(msg: "Passwords do not match!")
                    }
                }
                $0.add(rule: passwordsMatchRule)
                $0.validationOptions = .validatesOnChange
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
        let formValuesDict = self.form.values()
        
        let errors = form.validate()
        if errors.count > 0 {
            if let error = errors.last {
                showAlert(title: "Error", message: error.msg)
            }
        } else {
            // Sign the user up and save the data
            //
            guard let email = formValuesDict["Email"] as? String, let password = formValuesDict["Password"] as? String, let firstName = formValuesDict["First Name"] as? String, let lastName = formValuesDict["Last Name"] as? String,
                let company = formValuesDict["Business Name"] as? String, let phoneNumber = formValuesDict["Phone Number"] as? String else {
                showAlert(title: "Error", message: "Form value missing!")
                return
            }
        
            CustomActivityIndicator.shared.showActivityIndicator(uiView: self.view)
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if let err = error {
                    CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                    self.showAlert(title: "Error", message: err.localizedDescription)
                } else if let user = user {
                    // Update the user's display name
                    //
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    let name: String = "\(firstName) \(lastName)"
                    changeRequest.displayName = name
                    changeRequest.commitChanges(completion: nil)
                    
                    FirebaseFunctions.uploadUserInfo(uid: user.uid, firstName: firstName, lastName: lastName, email: email, company: company, phoneNumber: phoneNumber, { (error) in
                        if error != nil {
                            CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                            self.showAlert(title: "User Info Upload Error", message: error!.localizedDescription)
                        } else {
                            // Segue to create SearchJobs view controller
                            //
                            CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                            let sb: UIStoryboard = UIStoryboard(name: "SearchJobs", bundle: nil)
                            if let vc = sb.instantiateInitialViewController() {
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    })
                }
            })
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
