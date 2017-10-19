//
//  MainTabBarController.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/18/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
  
  // MARK: - Properties
  let photoHelper = FGPhotoHelper()

  // MARK: - Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()

    // When photo has been taken/selected
    photoHelper.completionHandler = { image in
      // Post image to storage and database
      PostService.create(for: image)
    }

    // Set self as delegate
    delegate = self
    
    // Set item color of tab as black
    tabBar.unselectedItemTintColor = .black
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
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

extension MainTabBarController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    // If Camera tag
    if viewController.tabBarItem.tag == 1 {
      // Present action sheet from this view controller
      photoHelper.presentActionSheet(from: self)
      // Don't display ViewController
      return false
    } else {
      // Allow ViewController to appear
      return true
    }
  }
}
