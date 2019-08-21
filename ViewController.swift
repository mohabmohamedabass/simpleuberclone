//
//  ViewController.swift
//  Uber
//
//  Created by Mohab Mohamed's on 7/30/19.
//  Copyright © 2019 mohabmohamed. All rights reserved.
//

import UIKit
import FirebaseAuth


class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var modeSwitch: UISwitch!
    
    @IBOutlet weak var topButton: UIButton!
    
    @IBOutlet weak var buttomButton: UIButton!
    
    @IBOutlet weak var riderLabel: UILabel!
    
    @IBOutlet weak var driverLabel: UILabel!
    
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    @IBAction func signupPressed(_ sender: Any) {
        
        if emailTextField.text == "" || passwordTextField.text == ""{
            
            errorAlert(title: "Missing Information", message: "You must enter both valid email and password.")
        }else {
            
            if let email = emailTextField.text {
                if let password = passwordTextField.text{
                    
                    if signUpMode{
                        // if sign up is on
                        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                            if error != nil {
                                self.errorAlert(title: "Error!", message: error!.localizedDescription)
                            }else{
                                if self.modeSwitch.isOn {
                                    //driver mode
                                    
                                    let request = Auth.auth().currentUser?.createProfileChangeRequest()
                                    request?.displayName = "Driver"
                                    request?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                }else{
                                    //rider mode
                                    let request = Auth.auth().currentUser?.createProfileChangeRequest()
                                    request?.displayName = "Rider"
                                    request?.commitChanges(completion: nil)
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                                
                            }
                        }
                        
                    }else{
                        // if log in is on
                        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                            if error != nil {
                                self.errorAlert(title: "Error!", message: error!.localizedDescription)
                            }else{
                                if user?.user.displayName  == "Driver" {
                                    //Driver mode
                                    print("driver.")
                                    self.performSegue(withIdentifier: "driverSegue", sender: nil)
                                    
                                }else{
                                    //rider mode
                                    self.performSegue(withIdentifier: "riderSegue", sender: nil)
                                }
                                
                            }
                        }
                    }
                    
                }
            }
            
            
        }
    
        
    }
    
    func errorAlert(title: String, message: String){
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        
    }
    
    @IBAction func goToLoginPressed(_ sender: Any) {
        if signUpMode {
            signUpMode = false
            topButton.setTitle("Log in", for: .normal)
            buttomButton.setTitle("Go to SignUp", for: .normal)
            riderLabel.isHidden = true
            driverLabel.isHidden = true
            modeSwitch.isHidden = true
        }else{
            signUpMode = true
            topButton.setTitle("SignUp", for: .normal)
            buttomButton.setTitle("Go To Login", for: .normal)
            riderLabel.isHidden = false
            driverLabel.isHidden = false
            modeSwitch.isHidden = false
        }
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}

