//
//  SignInViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 3/30/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import FirebaseAuth
import RealmSwift

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let realm = try! Realm()
    
    var authListener: AuthStateDidChangeListenerHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Root view for the whole app so hide the navigation bar here
        //
        hideNavigationBar()
        authListener = Auth.auth().addStateDidChangeListener { (auth, firebaseUser) in
            if firebaseUser != nil {
                self.loadUserInformation(uid: firebaseUser!.uid)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if authListener != nil {
            Auth.auth().removeStateDidChangeListener(authListener!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 8
        signupButton.layer.cornerRadius = 8
        passwordTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        loginPressed(self)
        return true
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showAlert(title: "Error", message: "Email and Password are required to login!")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (firebaseUser, error) in
            if let err = error {
                self.showAlert(title: "Signin Error", message: err.localizedDescription)
            } else if firebaseUser != nil {
                self.loadUserInformation(uid: firebaseUser!.uid)
            }
        })
    }
    
    func loadUserInformation(uid: String) {
        // Helper function so that if I delete local realm data the user information can still be recovered
        //
        if let user = self.realm.objects(User.self).filter("uid == %@", uid).first {
            segueToJobs(user: user)
        } else {
            FirebaseFunctions.getUserInfo({ (error, user) in
                if error != nil {
                    self.showAlert(title: "Error", message: error!.localizedDescription)
                } else if user != nil {
                    self.saveUserToRealm(user: user!)
                    self.segueToJobs(user: user!)
                }
            })
        }
    }
    
    func segueToJobs(user: User) {
        if user.isEmployee {
            // Segue to the list of jobs for an employee
            //
            let sb: UIStoryboard = UIStoryboard(name: "EmployeeJobs", bundle: nil)
            if let vc = sb.instantiateViewController(withIdentifier: "EmployeeJobsVC") as? EmployeeJobsViewController {
                vc.user = user
                // Set view controllers because we don't want the back button
                //
                self.navigationController?.setViewControllers([vc], animated: true)
            }
        } else {
            // Segue to create SearchJobs view controller
            //
            let sb: UIStoryboard = UIStoryboard(name: "Jobs", bundle: nil)
            if let navController = sb.instantiateInitialViewController() as? UINavigationController {
                if let vc = navController.topViewController as? JobsViewController {
                    vc.user = user
                    self.navigationController?.setViewControllers([vc], animated: true)
                }
            }
        }
    }
    
    private func saveUserToRealm(user: User) {
        do {
            try realm.write {
                realm.add(user)
            }
        } catch {
            print("Error saving firbease user data to realm: \(error)")
        }
    }
    
    @IBAction func SignupPressed(_ sender: Any) {
        // Segue to Signup VC
        //
        let storyboard = UIStoryboard(name: "Signup", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SignupVC") as? SignupViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
