//
//  User.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/17/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User {
  // MARK: - Singleton
  
  // Hold current user
  private static var _current: User?

  // Getter for current user
  static var current: User {
    // Make sure current user isn't nil
    guard let currentUser = _current else { fatalError("Error: current user doesn't exit") }
    
    // If not nil return current user
    return currentUser
  }

  // MARK: - Properties
  let uid: String
  let username: String
  
  // MARK: - Init
  init(uid: String, username: String) {
    self.uid = uid
    self.username = username
  }
  
  init?(snapshot: DataSnapshot) {
    // Cast the snapshot as a dictionary
    guard let dict = snapshot.value as? [String: Any],
      // Also make sure snapshot has a username property
      let username = dict["username"] as? String
      // Otherwise return nil
      else { return nil }
    
    // Set user id
    self.uid = snapshot.key
    // Set username
    self.username = username
  }
  
  // MARK: - Class Methods
  
  // Custom setter for singleton
  static func setCurrent(_ user: User) {
    _current = user
  }
}
