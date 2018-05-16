//
//  CreateJobViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/14/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift

class CreateJobViewController: FormViewController {
    
    let realm = try! Realm()
    var user: User?
    
    var dataStores: Results<DataStore>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataStores()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        // Create submit button in the navigation bar
        //
        let submitButton = UIButton(type: .custom)
        submitButton.setTitle("Submit", for: .normal)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        submitButton.addTarget(self, action: #selector(self.submitPressed), for: .touchUpInside)
        let submitItem = UIBarButtonItem(customView: submitButton)
        self.navigationItem.setRightBarButtonItems([submitItem], animated: false)
        
        if let info = user {
            
            form +++ Section("Business Information")
                <<< TextRow() {
                    $0.tag = "Company Name"
                    $0.title = "Company Name"
                    $0.value = info.company
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
                    $0.value = "\(info.firstName) \(info.lastName)"
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
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }
                
                +++ Section("Job Information")
                <<< TextRow() {
                    $0.tag = "Job Name"
                    $0.title = "Job"
                    $0.placeholder = "Job Name"
                    $0.add(rule: RuleRequired())
                    $0.validationOptions = .validatesOnChange
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
                }
                
                <<< DateRow() {
                    $0.tag = "Start Date"
                    $0.title = "Start Date"
                    $0.add(rule: RuleRequired())
                    $0.value = Date()
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                    }
                }
                
                <<< DateRow() {
                    $0.tag = "End Date"
                    $0.title = "End Date"
                    $0.add(rule: RuleRequired())
                    $0.value = Date()
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
                    }
                }
                
                <<< TextAreaRow() {
                    $0.tag = "Description"
                    $0.title = "Description"
                    $0.placeholder = "Description"
                    $0.add(rule: RuleRequired())
                }
                .cellUpdate { cell, row in
                    if !row.isValid {
                        cell.textLabel?.textColor = .red
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
            
            form +++ Section("Comments")
                <<< TextAreaRow() {
                    $0.tag = "Comments"
                    $0.title = "Comments"
                    $0.placeholder = "Optional"
            }
            animateScroll = true
            rowKeyboardSpacing = 20
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
        CustomActivityIndicator.shared.showActivityIndicator(uiView: self.view, color: nil, labelText: "Creating Job...")
        if let error = getFormError() {
            // Add a slight delay other wise hide will be called before the indicator appears and it will get stuck
            //
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                self.showAlert(title: "Error", message: error.msg)
            }
        } else if user != nil {
            let formValuesDict = self.form.values()
            if let job = Job(form: formValuesDict) {
                uploadJobToTierion(job: job)
            }
        }
    }
    
    private func uploadJobToTierion(job: Job) {
        if let jobStore = dataStores?.first(where: {$0.name == "Jobs"}) {
            TierionWrapper.shared.postJobToTierion(dataStoreId: jobStore.id, job: job, { (error, postedJob) in
                if let error = error {
                    CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
                    self.showAlert(title: "Error", message: error.localizedDescription)
                } else if let postedJob = postedJob {
                    self.saveJobToRealm(postedJob: postedJob)
                    self.presentSuccessAlert(jobName: job.jobName)
                }
            })
        } else {
            showAlert(title: "Error", message: "Could not find job data store!")
        }
    }
    
    private func saveJobToRealm(postedJob: PostedJob) {
        if let user = user {
            do {
                try realm.write {
                    user.postedJobs.append(postedJob)
                    self.realm.add(postedJob)
                }
            } catch {
                showAlert(title: "Error", message: "Error saving job to Realm: \(error)")
                // print("Error saving job to Realm: \(error)")
            }
        }
    }
    
    func presentSuccessAlert(jobName: String) {
        // Success alert with action
        //
        CustomActivityIndicator.shared.hideActivityIndicator(uiView: self.view)
        let alertController = UIAlertController(title: "Success", message: "Your job \(jobName) was successfully created", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func loadDataStores() {
        // retrieve dataStores from realm or Tierion
        //
        let results = realm.objects(DataStore.self)
        if results.isEmpty {
            // Get the dataStores from Tierion
            //
            TierionWrapper.shared.getAllDataStores({ (error, stores) in
                if error != nil {
                    self.showAlert(title: "Error Loading Data Stores", message: error!.localizedDescription)
                } else if let stores = stores {
                    self.saveDataStoresToRealm(stores: stores)
                }
            })
        } else {
            dataStores = results
        }
    }
    
    private func saveDataStoresToRealm(stores: [DataStore]) {
        do {
            try realm.write {
                for store in stores {
                    realm.add(store)
                }
                dataStores = realm.objects(DataStore.self)
            }
        } catch {
            showAlert(title: "Realm Error", message: "\(error)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
