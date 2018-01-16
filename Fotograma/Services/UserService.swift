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
  
  static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
    let ref = Database.database().reference().child("posts").child(user.uid)
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let snapshot = snapshot.children.allObjects as? [DataSnapshot] else {
        return completion([])
      }
      
      // Create DispatchGroup (GCD)
      let dispatchGroup = DispatchGroup()
  
      let posts: [Post] = snapshot
        // Get newest firest
        .reversed()
        // Map
        .flatMap {
          guard let post = Post(snapshot: $0)
            else { return nil }
          
          // Enter dispatch group for async action
          dispatchGroup.enter()
          
          // See if post is liked
          LikeService.isPostLiked(post) { (isLiked) in
            // Set post liked
            post.isLiked = isLiked
            
            // Finish async action
            dispatchGroup.leave()
          }
          
          // Return post
          return post
        }
      
      // Notify main thread when posts are complete
      dispatchGroup.notify(queue: .main, execute: {
        completion(posts)
      })
    })
  }

  static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
    let currentUser = User.current
    
    // Get users reference
    let ref = Database.database().reference().child("users")
    
    //
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
        else { return completion([]) }
      
      // Map users and filter out current user
      let users = snapshot
        .flatMap(User.init)
        .filter { $0.uid != currentUser.uid }
      
      //
      let dispatchGroup = DispatchGroup()
      
      users.forEach { (user) in
        dispatchGroup.enter()
        
        //
        FollowService.isUserFollowed(user) { (isFollowed) in
          user.isFollowed = isFollowed
          dispatchGroup.leave()
        }
      }
      
      dispatchGroup.notify(queue: .main, execute: {
        completion(users)
      })
    })
  }
}
