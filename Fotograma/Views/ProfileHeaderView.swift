//
//  ProfileHeaderView.swift
//  Fotograma
//
//  Created by Erick Sauri on 1/18/18.
//  Copyright © 2018 Erick Sauri. All rights reserved.
//

import UIKit

protocol ProfileHeaderViewDelegate: class {
  func didTapSettingsButton(_ button: UIButton, on headerView: ProfileHeaderView)
}

class ProfileHeaderView: UICollectionReusableView {

  // MARK: - Properties
  weak var delegate: ProfileHeaderViewDelegate?

  // MARK: - Subviews
  @IBOutlet weak var settingsButton: UIButton!
  @IBOutlet weak var postCountLabel: UILabel!
  @IBOutlet weak var followerCountLabel: UILabel!
  @IBOutlet weak var followingCountLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    
    settingsButton.clipsToBounds = true
    settingsButton.layer.borderWidth = 1
    settingsButton.layer.cornerRadius = 24
    settingsButton.layer.borderColor = UIColor.fgLightGray.cgColor
    settingsButton.setBackgroundColor(UIColor.fgLightGray, for: .highlighted)
  }

  // MARK: - IbActions
  @IBAction func settingsButtonTapped(_ sender: UIButton) {
    delegate?.didTapSettingsButton(sender, on: self)
  }
}
