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

class SignInViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    let realm = try! Realm()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Root view for the whole app so hide the navigation bar here
        //
        hideNavigationBar()
        Auth.auth().addStateDidChangeListener { (auth, firebaseUser) in
            if firebaseUser != nil {
                self.segueToJobs(uid: firebaseUser!.uid)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = 8
        signupButton.layer.cornerRadius = 8
    }
    
    @IBAction func LoginPressed(_ sender: Any) {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            showAlert(title: "Error", message: "Email and Password are required to login!")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (firebaseUser, error) in
            if let err = error {
                self.showAlert(title: "Signin Error", message: err.localizedDescription)
            } else if firebaseUser != nil {
                self.segueToJobs(uid: firebaseUser!.uid)
            }
        })
    }
    
    func segueToJobs(uid: String) {
        if let user = self.realm.objects(User.self).filter("uid == %@", uid).first {
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
                    print("employee failled on sign in")
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
        } else {
            // TODO: Check firebase for user information
            //
            print("No user in realm.... at sign in vc")
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
