//
//  PostHeaderCell.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/16/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit

class PostHeaderCell: UITableViewCell {

  // MARK: - Subviews
  @IBOutlet weak var usernameLabel: UILabel!
  
  // MARK: - Properties
  static let height: CGFloat = 54
  var didTapOptionsButtonForCell: ((PostHeaderCell) -> Void)?
  
  // MARK: - View Lifecycle
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  

  // MARK: - IBActions
  @IBAction func optionsButtonTapped(_ sender: UIButton) {
    didTapOptionsButtonForCell?(self)
  }
}
