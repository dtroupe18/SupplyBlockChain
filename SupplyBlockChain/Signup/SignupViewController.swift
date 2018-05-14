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
import RealmSwift

class SignupViewController: FormViewController {
    
    let realm = try! Realm()
    
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
        submitButton.setTitleColor(.white, for: .normal)
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
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
        }
        
        form +++ Section("Business Information")
            <<< TextRow() {
                $0.tag = "Business Name"
                $0.title = "Name"
                $0.placeholder = "Apple"
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
        }
        
        let industries = ["IT", "Pharmaceutical", "Medical"]
        
        form +++ SelectableSection<ListCheckRow<String>>() { section in
            section.header = HeaderFooterView(title: "Industry")
        }
        
        for option in industries {
            form.last! <<< ListCheckRow<String>(option) {
                $0.title = option
                $0.selectableValue = option
                $0.value = nil
                
                let industryRule = RuleClosure<String> { rowValue in
                    let formValuesDict = self.form.values()
                    if (formValuesDict["IT"] as? String) != nil {
                        return nil
                    } else if (formValuesDict["Pharmaceutical"] as? String) != nil {
                        return nil
                    } else if (formValuesDict["Medical"] as? String) != nil {
                        return nil
                    } else {
                        return ValidationError(msg: "You must select an industry")
                    }
                }
                $0.add(rule: industryRule)
                $0.validationOptions = .validatesOnChange
            }
        }
        
        form +++ Section("User Account")
            <<< EmailRow() {
                $0.tag = "Email"
                $0.title = "Email"
                $0.placeholder = "SteveJobs@apple.com"
                $0.add(rule: RuleEmail())
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnChange
                }
                // Do something when a JNJ email is used to sign up so they can see it
                //
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
        let errors = form.validate()
        print(form.values())
        if errors.count > 0 {
            if let error = errors.last {
                showAlert(title: "Error", message: error.msg)
            }
        } else {
            createFirebaseUser()
        }
    }
    
    func createFirebaseUser() {
        if let formValues: SignUpForm = SignUpForm(formValues: self.form.values()) {
            // Actually create the user account
            //
            CustomActivityIndicator.shared.showActivityIndicator(uiView: self.view, color: nil, labelText: "Creating user account")
            Auth.auth().createUser(withEmail: formValues.email, password: formValues.password, completion: { (user, error) in
                if let err = error {
                    CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                    self.showAlert(title: "Error", message: err.localizedDescription)
                } else if let user = user {
                    // Update the user's display name
                    //
                    let changeRequest = Auth.auth().currentUser!.createProfileChangeRequest()
                    let name: String = "\(formValues.firstName) \(formValues.lastName)"
                    changeRequest.displayName = name
                    changeRequest.commitChanges(completion: nil)
                    self.saveUserToRealm(formValues: formValues, uid: user.uid)
                }
            })
        } else {
            // Some formvalue was nil
            //
            showAlert(title: "Error", message: "Form is missing value(s)")
        }
    }
    
    func saveUserToRealm(formValues: SignUpForm, uid: String) {
        let user = User(form: formValues, uid: uid)
        do {
            try realm.write {
                realm.add(user)
            }
            uploadUserToFirebase(user: user)
        } catch {
            CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
            print("Error saving to user Realm: \(error)")
        }
    }
    
    func uploadUserToFirebase(user: User) {
        FirebaseFunctions.uploadUserInfo(user: user, { (error) in
            if error != nil {
                CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                self.showAlert(title: "User Info Upload Error", message: error!.localizedDescription)
            } else {
                self.segueToJobs(user: user)
            }
        })
    }
    
    private func segueToJobs(user: User) {
        CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
        if user.isEmployee {
            // Segue to the list of jobs for an employee
            //
            let sb: UIStoryboard = UIStoryboard(name: "EmployeeJobs", bundle: nil)
            if let navController = sb.instantiateInitialViewController() as? UINavigationController {
                if let vc = navController.topViewController as? EmpolyeeJobsViewController {
                    vc.user = user
                    present(navController, animated: true, completion: nil)
                }
            }
            else {
                print("employee failed on sign up")
            }
        } else {
            // Segue to create SearchJobs view controller
            //
            let sb: UIStoryboard = UIStoryboard(name: "Jobs", bundle: nil)
            if let navController = sb.instantiateInitialViewController() as? UINavigationController {
                if let vc = navController.topViewController as? JobsViewController {
                    vc.user = user
                    present(navController, animated: true, completion: nil)
                }
            }
        }
    }

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    }
}
