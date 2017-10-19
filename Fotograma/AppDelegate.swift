//
//  AppDelegate.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/17/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    // Configure Firebase
    FirebaseApp.configure()

    // Configure initial root view controller based on authentication
    configureInitialRootViewController(for: window)

    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  
}

extension AppDelegate {
  // Configures initial root ViewController based on user authentication
  func configureInitialRootViewController(for window: UIWindow?) {
    // UserDefaults
    let defaults = UserDefaults.standard
    // Initial root ViewController
    let initialViewController: UIViewController
    
    // If user is already authenticated
    if Auth.auth().currentUser != nil,
      // Get user data from UserDefaults
      let userData = defaults.object(forKey: Constants.UserDefaults.currentUser) as? Data,
      // Unarchive data as User
      let user = NSKeyedUnarchiver.unarchiveObject(with: userData) as? User {
      // Set current user
      User.setCurrent(user)
      
      // Instantiate initial view controller as main
      initialViewController = UIStoryboard.initialViewController(for: .main)
    } else {
      // Otherwise not authenticated instantiate intial view controller as login
      initialViewController = UIStoryboard.initialViewController(for: .login)
    }
    // Make it the root view controller
    window?.rootViewController = initialViewController
    // Position the view in front of all others
    window?.makeKeyAndVisible()
  }
}
