//
//  User.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/17/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import Foundation
import FirebaseDatabase.FIRDataSnapshot

class User: NSObject {
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
    
    // Initialize NSObject
    super.init()
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
    
    // Initialize NSObject
    super.init()
  }
  
  required init?(coder aDecoder: NSCoder) {
    guard let uid = aDecoder.decodeObject(forKey: Constants.UserDefaults.uid) as? String,
      let username = aDecoder.decodeObject(forKey: Constants.UserDefaults.username) as? String
      else { return nil }
    
    self.uid = uid
    self.username = username
    
    super.init()
  }

  // MARK: - Class Methods
  
  // Custom setter for singleton
  static func setCurrent(_ user: User, writeToUserDefaults: Bool = false) {
    // If storing data in UserDefaults
    if writeToUserDefaults {
      // Archive data for storage
      let data = NSKeyedArchiver.archivedData(withRootObject: user)
      
      // Store data in UserDefaults
      UserDefaults.standard.set(data, forKey: Constants.UserDefaults.currentUser)
    }

    // Set current user
    _current = user
  }
}

extension User: NSCoding {
  // Encode
  func encode(with aCoder: NSCoder) {
    // Encode user id
    aCoder.encode(uid, forKey: Constants.UserDefaults.uid)
    // Encode username
    aCoder.encode(username, forKey: Constants.UserDefaults.username)
  }
}
