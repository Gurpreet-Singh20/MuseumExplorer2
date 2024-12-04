//
//  SavedArtifactsTableViewController.swift
//  MuseumExplorer
//
//  Created by Gurpreet Singh on 2024-12-09.
//

import Foundation
import UIKit

class SavedArtifactTableViewController: UITableViewController {
    private var savedArtifacts: [Artifact] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Saved Artifacts"
        fetchSavedArtifacts()
    }

    private func fetchSavedArtifacts() {
        savedArtifacts = CoreDataManager.shared.getAllSavedArtifacts()
//        print("Fetched artifacts: \(savedArtifacts)")
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSavedDetail",
               let destinationVC = segue.destination as? SavedDetailViewController,
               let selectedArtifact = sender as? Artifact {
                destinationVC.artifact = selectedArtifact
            } else {
                print("No artifact data or segue identifier mismatch")
            }
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedArtifacts.count
    }
    


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtifactCell2", for: indexPath)
        let artifact = savedArtifacts[indexPath.row]
        cell.textLabel?.text = artifact.title
        cell.detailTextLabel?.text = artifact.artist
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let selectedArtifact = savedArtifacts[indexPath.row]
            
           
            guard savedArtifacts.indices.contains(indexPath.row) else { return }

           
            performSegue(withIdentifier: "ShowSavedDetail", sender: selectedArtifact)

            tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let artifactToDelete = savedArtifacts[indexPath.row]

            
            CoreDataManager.shared.deleteArtifact(artifact: artifactToDelete)

           
            savedArtifacts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
