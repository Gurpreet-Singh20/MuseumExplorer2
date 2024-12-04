//
//  SavedDetailViewController.swift
//  MuseumExplorer
//
//  Created by Gurpreet Singh on 2024-12-10.
//

import Foundation
import UIKit

class SavedDetailViewController: UIViewController {
    // MARK: - Outlets
      @IBOutlet weak var artifactImageView: UIImageView!
      @IBOutlet weak var titleLabel: UILabel!
      @IBOutlet weak var artistLabel: UILabel!
      @IBOutlet weak var dateLabel: UILabel!
      @IBOutlet weak var descriptionLabel: UILabel!
      
      // The artifact data passed from the table view
      var artifact: Artifact?

      override func viewDidLoad() {
          super.viewDidLoad()
          self.title = "Saved details"
          // Set up the UI with the artifact's details
          setupUI()
      }
      
    private func setupUI() {
        if let artifact = artifact {
                   // Set text with ternary operators for fallback
                   titleLabel.text = artifact.title?.isEmpty == false ? artifact.title : " Title Unavailable"
                   artistLabel.text = artifact.artist?.isEmpty == false ? artifact.artist : "Artist Unknown"
                   dateLabel.text = artifact.date?.isEmpty == false ? artifact.date : "Unknown Date"
                   descriptionLabel.text = artifact.artifactDescription?.isEmpty == false ? artifact.artifactDescription : "No Bio available"
                   
                   if let imageURLString = artifact.imageURL, let imageURL = URL(string: imageURLString) {
                       loadImage(from: imageURL)
                   } else {
                       artifactImageView.image = UIImage(named: "defaultArtifact")
                   }
               } else {
                   print("Artifact is nil - UI won't load with invalid data")
                   
                   // Set placeholders if artifact itself is nil
                   titleLabel.text = "Unknown Artifact"
                   artistLabel.text = "Unknown Artist"
                   dateLabel.text = "Unknown Date"
                   descriptionLabel.text = "No description available"
                   artifactImageView.image = UIImage(named: "defaultArtifact")
               }
       }
       
       private func loadImage(from url: URL) {
           // Fetch the image asynchronously
           URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
               if let data = data, let image = UIImage(data: data) {
                   DispatchQueue.main.async {
                       self?.artifactImageView.image = image
                   }
               } else {
                   DispatchQueue.main.async {
                       self?.artifactImageView.image = UIImage(named: "defaultArtifact")
                   }
               }
           }.resume()
       }
  }

