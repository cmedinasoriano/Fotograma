//
//  HomeViewController.swift
//  Fotograma
//
//  Created by Erick Sauri on 10/18/17.
//  Copyright © 2017 Erick Sauri. All rights reserved.
//

import UIKit
import Kingfisher

class HomeViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!

  // MARK: - Properties
  var posts = [Post]()
  
  let refreshControl = UIRefreshControl()

  let paginationHelper = FGPaginationHelper<Post>(serviceMethod: UserService.timeline)

  let timestampFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    
    return dateFormatter
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    // Style table
    
    setupTableView()
    
    reloadTimeline()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setupTableView() {
    // Remove separators for empty cells
    tableView.tableFooterView = UIView()
    // Remove separators from cells
    tableView.separatorStyle = .none
    // Add pull to refresh
    refreshControl.addTarget(self, action: #selector(reloadTimeline), for: .valueChanged)
    // Add refresh to table
    tableView.addSubview(refreshControl)
  }

  @objc func reloadTimeline() {
    // Get
    self.paginationHelper.reloadData(completion: { [unowned self] (posts) in
      self.posts = posts

      // If currently refrshing
      if (self.refreshControl.isRefreshing) {
        // Stop refreshing
        self.refreshControl.endRefreshing()
      }

      self.tableView.reloadData()
    })
  }

  func handleOptionsButtonTap(from cell: PostHeaderCell) {
    // Make sure we can get the indexPath for the cell to the the post
    guard let indexPath = tableView.indexPath(for: cell) else { return }
    
    // Get the post using indexPath section
    let post = posts[indexPath.section]
    let poster = post.poster
    
    // Create alert controller
    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    
    // If poster is not user
    if poster.uid != User.current.uid {
      // Create flag action
      let flagAction = UIAlertAction(title: "Report as Inappropriate", style: .default) { _ in
        // Flag post
        PostService.flag(post)
        // Create ok alert
        let okAlert = UIAlertController(title: nil, message: "The post has been flagged.", preferredStyle: .alert)
        okAlert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(okAlert, animated: true)
      }
      
      // Attach flag action to alert controller
      alertController.addAction(flagAction)
    }
    
    // Create cancel action and attach to alert controller
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
    alertController.addAction(cancelAction)
    
    // Present the action sheet
    present(alertController, animated: true)
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

// MARK: - UITableViewDelegate
extension HomeViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

    switch indexPath.row {
    case 0:
      return PostHeaderCell.height
    case 1:
      let post = posts[indexPath.section]
      
      return post.imageHeight
    case 2:
      return PostActionCell.height
    default:
      fatalError("Error: unexpected indexPath at heightForRowAt")
    }
  }
}

// MARK: - UITableViewDataSource
extension HomeViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return posts.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let post = posts[indexPath.section]

    switch indexPath.row {
      // Header Cell
    case 0:
      let cell: PostHeaderCell = tableView.dequeueReusableCell()

      cell.usernameLabel.text = post.poster.username
      cell.didTapOptionsButtonForCell = handleOptionsButtonTap(from:)

      return cell
    // Image Cell
    case 1:
      let cell: PostImageCell = tableView.dequeueReusableCell()
      let imageURL = URL(string: post.imageURL)
  
      cell.postImageView.kf.setImage(with: imageURL)
  
      return cell;
    // Actions Cell
    case 2:
      let cell: PostActionCell = tableView.dequeueReusableCell()
      
      cell.delegate = self
      configureCell(cell, with: post)
      
      return cell
    default:
      fatalError("Error: unexpected indexPath!")
    }
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    // If user has scrolled to the end of the content in memory
    if indexPath.section >= posts.count - 1 {
      // Get the next few posts
      paginationHelper.paginate(completion: { [unowned self] (posts) in
        // Append the posts
        self.posts.append(contentsOf: posts)
        
        // On the main thread
        DispatchQueue.main.async {
          // Reload table
          self.tableView.reloadData()
        }
      })
    }
  }
  
  func configureCell(_ cell: PostActionCell, with post: Post) {
    cell.likeButton.isSelected = post.isLiked
    cell.likesLabel.text = "\(post.likeCount) likes"
    cell.timeLabel.text = timestampFormatter.string(from: post.creationDate)
  }
}

// MARK: - PostActionCellDelegate
extension HomeViewController: PostActionCellDelegate {
  func didTapLikeButton(_ likeButton: UIButton, on cell: PostActionCell) {
    // Make sure we can get the indexPath for cell
    guard let indexPath = tableView.indexPath(for: cell) else {
      return
    }
    
    // Disable further user interaction
    likeButton.isUserInteractionEnabled = false
    
    // Get post
    let post = posts[indexPath.section]
    
    // Set liked for post
    LikeService.setIsLiked(!post.isLiked, for: post, success: { (success) in
      // When the closure returns allow user interaction again
      defer {
        likeButton.isUserInteractionEnabled = true
      }
      
      // If there was a network error return
      guard success else { return }
      
      // Change the like properties for the post
      post.likeCount += !post.isLiked ? 1 : -1
      post.isLiked = !post.isLiked
      
      // Get reference to current cell
      guard let cell = self.tableView.cellForRow(at: indexPath) as? PostActionCell
        else { return }
      
      // Update the UI of the cell on the main thread
      DispatchQueue.main.async {
        self.configureCell(cell, with: post)
      }
    })
  }
}
