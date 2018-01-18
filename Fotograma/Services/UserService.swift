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
    let ref = DatabaseReference.toLocation(.showUser(uid: fireUser.uid))
   
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
    let ref = DatabaseReference.toLocation(.showUser(uid: uid))
    
    ref.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let user = User(snapshot: snapshot) else { return completion(nil) }
      completion(user)
    })
  }
  
  static func posts(for user: User, completion: @escaping ([Post]) -> Void) {
    let ref = DatabaseReference.toLocation(.posts(uid: user.uid))
    
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

  static func timeline(pageSize: UInt, lastPostKey: String? = nil, completion: @escaping ([Post]) -> Void) {
    let currentUser = User.current
    
    print("Current user is \(User.current.username)")

    let timelineRef = DatabaseReference.toLocation(.timeline(uid: currentUser.uid))
    
    // Make a query from the ref and limit the number of items to get to pageSize
    var query = timelineRef.queryOrderedByKey().queryLimited(toLast: pageSize)
    
    // If there is a last key
    if let lastPostKey = lastPostKey {
      // End query at last post key
      query = query.queryEnding(atValue: lastPostKey)
    }
    
    query.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let snapshot = snapshot.children.allObjects as? [DataSnapshot]
        else { return completion([]) }
      
      let dispatchGroup = DispatchGroup()
      
      var posts = [Post]()
      
      for postSnap in snapshot {
        guard let postDict = postSnap.value as? [String: Any],
          let posterUID = postDict["poster_uid"] as? String
          else { continue }
        
        dispatchGroup.enter()
        
        PostService.show(forKey: postSnap.key, posterUID: posterUID) { (post) in
          if let post = post {
            posts.append(post)
          }
          
          dispatchGroup.leave()
        }
      }
      
      dispatchGroup.notify(queue: .main, execute: {
        completion(posts.reversed())
      })
    })
  }
  
  static func followers(for user: User, completion: @escaping ([String]) -> Void) {
    let followersRef = DatabaseReference.toLocation(.followers(uid: user.uid))
    
    followersRef.observeSingleEvent(of: .value, with: { (snapshot) in
      guard let followersDict = snapshot.value as? [String: Bool] else {
        return completion([])
      }
      
      // Make a string array out of follower user ids
      let followersKeys = Array(followersDict.keys)
      
      completion(followersKeys)
    })
  }

  static func usersExcludingCurrentUser(completion: @escaping ([User]) -> Void) {
    let currentUser = User.current
    
    // Get users reference
    let ref = DatabaseReference.toLocation(.users)
    
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
