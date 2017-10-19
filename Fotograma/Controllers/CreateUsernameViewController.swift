//
//  CreateUsernameViewController.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/17/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateUsernameViewController: UIViewController {

  // MARK: - Outlet Properties
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var nextButton: UIButton!
  
  // MARK: - Init
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  // MARK: - Actions
  @IBAction func nextButtonTapped(_ sender: UIButton) {
    // Create user
    createUser()
  }
  
  // MARK: - Methods
  func createUser() {
    // Make sure user is logged in
    guard let firUser = Auth.auth().currentUser,
      // Get the username from text field
      let username = usernameTextField.text,
      // Make sure it isn't empty
      !username.isEmpty else { return }
  
    UserService.create(firUser, username: username) { (user) in
      // If no user return
      guard let user = user else { return }
  
      // Set current user
      User.setCurrent(user, writeToUserDefaults: true)
      
      // Go to main view
      self.goToMainView()
    }
  }
  
  func goToMainView() {
    // Instantiate storyboard
    let initialViewController = UIStoryboard.initialViewController(for: .main)
    // Make it the root view controller
    self.view.window?.rootViewController = initialViewController
    // Put in in front of everything
    self.view.window?.makeKeyAndVisible()
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
