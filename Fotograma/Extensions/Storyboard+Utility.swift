//
//  Storyboard+Utility.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/18/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit

extension UIStoryboard {
  // Fotogram Enum
  enum FGType: String {
    // Cases stand for storyboard names
    case main
    case login
    case findFriends

    // Returns corresponding name of the storyboard
    var filename: String {
      return rawValue.capitalized
    }
  }
  
  
  // Convenience initializer
  // Will initialize correct storyboard based on enum case
  convenience init(type: FGType, bundle: Bundle? = nil) {
    self.init(name: type.filename, bundle: bundle)
  }
  
  
  static func initialViewController(for type: FGType) -> UIViewController {
    // Get storyboard
    let storyboard = UIStoryboard(type: type)
    
    // Make sure storyboard is instantiated
    guard let initialViewController = storyboard.instantiateInitialViewController() else {
      fatalError("Couldn't instantiate initial view controller for \(type.filename) storyboard.")
    }
    
    // Return initial view controller
    return initialViewController
  }
}
