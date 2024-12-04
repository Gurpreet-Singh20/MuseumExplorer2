//
//  ArtifactDetailViewController.swift
//  MuseumExplorer
//
//  Created by Gurpreet Singh on 2024-12-04.
//
import UIKit
import Foundation


class ArtifactDetailViewController: UIViewController {
    
    @IBOutlet weak var saveArtifact: UIBarButtonItem!
    
    @IBOutlet weak var artifactImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
   
    var artifact: MuseumArtifact?
     
    override func viewDidLoad() {
            super.viewDidLoad()
            
            
            if let artifact = artifact {
                titleLabel.text = artifact.title
                artistLabel.text = artifact.artistDisplayName.isEmpty ? "Unknown Artist" : artifact.artistDisplayName
                dateLabel.text = artifact.objectDate.isEmpty ? "Unknown Date" : artifact.objectDate
                descriptionLabel.text = artifact.artistDisplayBio.isEmpty ? "No Description Available" : artifact.artistDisplayBio
                
                // Load the artifact image
                if let imageUrl = URL(string: artifact.primaryImage), !artifact.primaryImage.isEmpty {
                    loadImage(from: imageUrl)
                } else {
                    artifactImageView.image = UIImage(systemName: "photo")
                }
            }
        }
    @IBAction func saveArtifactTapped(_ sender: UIBarButtonItem) {
        guard let artifact = artifact else {
               print("No artifact to save.")
               return
           }

          
           CoreDataManager.shared.addArtifactToCoreData(artifact: artifact)

           // Show confirmation
           let alert = UIAlertController(title: "Saved", message: "Artifact has been saved to your collection.", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           present(alert, animated: true)
    }
        
        
        private func loadImage(from url: URL) {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.artifactImageView.image = image
                    }
                } else {
                    DispatchQueue.main.async {
                        self.artifactImageView.image = UIImage(systemName: "photo")
                    }
                }
            }
        }
}
