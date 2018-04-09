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
        print("login pressed")
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
        let sb: UIStoryboard = UIStoryboard(name: "SearchJobs", bundle: nil)
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
