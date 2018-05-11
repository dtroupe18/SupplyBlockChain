//
//  SignInViewController.swift
//  SupplyBlockChain
//
//  Created by Dave on 3/30/18.
//  Copyright © 2018 High Tree Development. All rights reserved.
//

import UIKit
import FirebaseAuth

class SignInViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Root view for the whole app so we can hide the navigation bar here
        //
        hideNavigationBar()
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.segueToJobs()
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
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            if let err = error {
                self.showAlert(title: "Signin Error", message: err.localizedDescription)
            } else {
                self.segueToJobs()
            }
        })
    }
    
    private func segueToJobs() {
        // Segue to create SearchJobs view controller
        //
        let sb: UIStoryboard = UIStoryboard(name: "Jobs", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func SignupPressed(_ sender: Any) {
        // Segue to Signup VC
        //
        let storyboard = UIStoryboard(name: "Signup", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "SignupVC") as? SignupViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
