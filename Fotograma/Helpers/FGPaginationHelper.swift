//
//  FGPaginationHelper.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/17/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import Foundation

/*
 * Ensure our pagination Generic has a key value
 */
protocol FGKeyed {
  var key: String? { get set }
}

class FGPaginationHelper<T: FGKeyed> {
  enum FGPaginationState {
    case initial
    case ready
    case loading
    case end
  }
  
  // MARK: - Properties
  
  // Determines the number of posts that will be on each page
  let pageSize: UInt
  // The service method that returns paginated data
  let serviceMethod: (UInt, String?, @escaping ([T]) -> Void) -> Void
  // Current pagination state of the helper
  var state: FGPaginationState = .initial
  // Key of the last object in pagination data
  var lastObjectKey: String?
  
  init(pageSize: UInt = 2, serviceMethod: @escaping (UInt, String?, @escaping ([T]) -> Void) -> Void) {
    self.pageSize = pageSize
    self.serviceMethod = serviceMethod
  }
  
  /*
   * Resets pagination to its initial state
   */
  func reloadData(completion: @escaping ([T]) -> Void) {
    state = .initial
    
    paginate(completion: completion)
  }
  
  /*
   * Pagination
   */
  func paginate(completion: @escaping ([T]) -> Void) {
    // Determine the behavior of the helper based on state
    switch state {
    // On initial state
    case .initial:
      // Ensure last object key is nil - since we should't have any data
      lastObjectKey = nil
      // Ensure we execute the ready case below
      fallthrough
    // When pagination is ready
    case .ready:
      // Set state to loading
      state = .loading
      // Execute service method to return paginated data
      serviceMethod(pageSize, lastObjectKey) { [unowned self] (objects: [T]) in
        // Defer until closure returns
        defer {
          // If the last returned object has a key value
          if let lastObjectKey = objects.last?.key {
            // Store that as the last object key
            self.lastObjectKey = lastObjectKey
          }
          
          // If the number of objects returned is less than the page size
          self.state = objects.count < Int(self.pageSize)
            // We have retrieved all objects
            ? .end
            // Otherwise we can retrieve more
            : .ready
        }
        
        // If last object key doesn't exist
        guard let _ = self.lastObjectKey else {
          // Return data as is since its the first page of data
          return completion(objects)
        }
        
        // Drop the first object from returned list because it is also the last object from previous list
        let newObjects = Array(objects.dropFirst())
        // Return new objects
        completion(newObjects)
      }
    // If state is loading or finished
    case .loading, .end:
      // Don't to anything
      return
    }
  }
}
