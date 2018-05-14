//
//  SignUpForm.swift
//  SupplyBlockChain
//
//  Created by Dave on 5/11/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import Foundation

/* This stuct is converted from the sign up form so that we don't have to worry about unwrapping optional values */

struct SignUpForm {
    
    let email: String
    let password: String
    let firstName: String
    let lastName: String
    let company: String
    let phoneNumber: String
    let industry: String
    var isEmployee: Bool = false
    
    init?(formValues: [String: Any?]) {
        if let email = formValues["Email"] as? String, let password = formValues["Password"] as? String,
            let firstName = formValues["First Name"] as? String, let lastName = formValues["Last Name"] as? String,
            let company = formValues["Business Name"] as? String, let phoneNumber = formValues["Phone Number"] as? String {
            
            self.email = email
            self.password = password
            self.firstName = firstName
            self.lastName = lastName
            self.company = company
            self.phoneNumber = phoneNumber
            
            // Industry is under the selected string so we have to check all 3
            //
            if let industry = formValues["IT"] as? String  {
                self.industry = industry
            } else if let industry = formValues["Pharmaceutical"] as? String  {
                self.industry = industry
            } else if let industry = formValues["Medical"] as? String  {
                self.industry = industry
            } else {
                return nil
            }
            // Check if user is employee this needs to be added to user struct ...... QWE!!!!!!
            //
            self.isEmployee = checkIfEmployee(email: email, company: company)
        } else {
            return nil
        }
    }
    
    private func checkIfEmployee(email: String, company: String) -> Bool {
        // We should also require email verification
        //        
        if email.lowercased().range(of: "jnj.com") != nil && company.lowercased().range(of: "johnson") != nil {
            return true
        } else {
            return false
        }
    }
}
