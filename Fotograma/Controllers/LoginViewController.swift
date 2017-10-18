//
// LoginViewController.swift
// Fotograma
//
// Created by Erick Sauri on 10/17/17.
// Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseAuthUI
import FirebaseDatabase

typealias FIRUser = FirebaseAuth.User

class LoginViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    
  }
  
  // MARK: - IBActions

  @IBAction func loginButtonTapped(_ sender: UIButton) {
    // Access firebase authentication ui singleton
    guard let authUI = FUIAuth.defaultAuthUI() else { return }
    
    // Set this view controller as a delegate of singleton
    authUI.delegate = self
    
    // Instantiate the firebase authentication view controller
    let authViewController = authUI.authViewController()
    
    // Present the firebase authentication view controller
    present(authViewController, animated: true)
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

extension LoginViewController: FUIAuthDelegate {
  func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
    // If error
    if let error = error {
      // Get error message
      assertionFailure("Error signing in \(error.localizedDescription)")
      
      // return
      return
    }
    
    // Make sure user is authenticated
    guard let user = user else { return }
    
    // Construct path to users information in realtime database
    let userRef = Database.database().reference().child("users").child(user.uid)
    
    // Read from the data and pass an event closure to handle the data passed back from database
    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
      // Retrieve user data from snapshot
      if let userDict = snapshot.value as? [String: Any] {
        print("User already exists \(userDict.debugDescription)")
      } else {
        print("New user!")
      }
    })
    print("Handle login")
  }
}
