//
//  UITableView+Utility.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/17/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit

/*
 * Protocol for converting a custom UITableCell into it's identifier
 *
 */
protocol CellIdentifiable {
  static var cellIdentifier: String { get }
}

/*
 * CellIdentifiable protocol extension
 *
 */
extension CellIdentifiable where Self: UITableViewCell {
  // Default value for cell identifier
  static var cellIdentifier: String {
    // Returns the name of the custom UITableViewCell as a string
    return String(describing: self)
  }
}

/*
 * Ensure UITableViewCell implements the CellIdentifiable protocol
 */
extension UITableViewCell: CellIdentifiable { }

extension UITableView {
  /*
   * Generic function that returns cell.
   * Type must be of UITableViewCell and conform to the CellIdentifiable protocol
   *
   */
  func dequeueReusableCell<T: UITableViewCell>() -> T where T: CellIdentifiable {
    // Unwrap custom cell based on identifier
    guard let cell = dequeueReusableCell(withIdentifier: T.cellIdentifier) as? T else {
      // If error print message with identifier
      fatalError("Error dequeing cell for identifier \(T.cellIdentifier)")
    }
    
    // Return cell
    return cell
  }
}
