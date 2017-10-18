//
//  UserService.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/17/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import Foundation
import FirebaseAuth.FIRUser
import FirebaseDatabase

struct UserService {
  static func create(_ fireUser: FIRUser, username: String, completion: @escaping (User?) -> Void) {
    // Create a tuple of the value we're going to store
    let userAttrs = ["username": username]
    
    // Create a reference to the database
    let ref = Database.database().reference().child("users").child(fireUser.uid)
    
    // Set value in database
    ref.setValue(userAttrs) { (error, ref) in
      // Check for any error
      if let error = error {
        assertionFailure(error.localizedDescription)
        return
      }
      
      // Once user data has been updated in the backend
      ref.observeSingleEvent(of: .value, with: {(snapshot) in
        // Create new user
        let user = User(snapshot: snapshot)
        
        completion(user)
      })
    }
  }
  
  static func show(forUID uid: String, completion: @escaping (User?) -> Void) {
    let ref = Database.database().reference().child("users").child(uid)
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let user = User(snapshot: snapshot) else { return completion(nil) }
      completion(user)
    })
  }
}
