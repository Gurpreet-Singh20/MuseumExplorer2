//
//  MuseumArtifactsTableViewController.swift
//  MuseumExplorer
//
//  Created by Gurpreet Singh on 2024-11-27.
//

import Foundation
import UIKit

class MuseumArtifactsTableViewController: UITableViewController, NetworkingDelegate, UISearchBarDelegate{
    
    @IBOutlet weak var savedArtifact: UIBarButtonItem!
    var artifacts: [MuseumArtifact] = []
    var allArtifacts: [MuseumArtifact] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
       
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ArtifactCell")
        
        
        NetworkingManager.shared.delegate = self
    
        
        fetchMuseumArtifacts()
        
    }
    
    // MARK: - Fetching Data
    func fetchMuseumArtifacts() {
        NetworkingManager.shared.getArtifactIDsFromAPI { result in
            switch result {
            case .success(let artifactIDs):
                print("Fetched \(artifactIDs.count) artifact IDs")
                
              
                let shuffledArtifactIDs = artifactIDs.shuffled()
                
                var fetchedArtifacts: [MuseumArtifact] = []
                let dispatchGroup = DispatchGroup()
                
                
                for id in shuffledArtifactIDs.prefix(10) {  // Pick the first 10 random IDs
                    dispatchGroup.enter()
                    NetworkingManager.shared.getMuseumArtifactDetailsFromAPI(artifactID: id) { result in
                        switch result {
                        case .success(let artifact):
                            fetchedArtifacts.append(artifact)
                        case .failure(let error):
                            print("Failed to fetch artifact details for ID \(id): \(error)")
                        }
                        dispatchGroup.leave()
                    }
                }
                
                
                dispatchGroup.notify(queue: .main) {
                    self.allArtifacts = fetchedArtifacts
                    self.artifacts = fetchedArtifacts
                    self.tableView.reloadData()
                }
                
            case .failure(let error):
                print("Failed to fetch artifact IDs: \(error)")
            }
        }
    }
    
    
    // MARK: - Table View Data Source Methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return artifacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArtifactCell", for: indexPath)
        
       
        let artifact = artifacts[indexPath.row]
        cell.textLabel?.text = artifact.title
        cell.detailTextLabel?.text = artifact.artistDisplayName
        
        return cell
    }
    
    // MARK: - Table View Delegate Methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        let selectedArtifact = artifacts[indexPath.row]
        
       
        performSegue(withIdentifier: "ShowArtifactDetail", sender: selectedArtifact)
        
      
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowArtifactDetail", let destinationVC = segue.destination as? ArtifactDetailViewController, let selectedArtifact = sender as? MuseumArtifact {
           
            destinationVC.artifact = selectedArtifact
        }
    }
    
    // MARK: - NetworkingDelegate Methods
    func networkingDidFinishWithArtifacts(artifacts: [MuseumArtifact]) {
        self.artifacts = artifacts
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func networkingDidFail() {
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: "Failed to fetch artifacts", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - UISearchBarDelegate Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            
            artifacts = allArtifacts
            tableView.reloadData()
        } else {
            // Query the Met Museum API directly with the new input
            searchMuseumArtifacts(for: searchText)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()  // Dismiss keyboard
    }
    
    // MARK: - Search with Met Museum's Search API
    func searchMuseumArtifacts(for query: String) {
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://collectionapi.metmuseum.org/public/collection/v1/search?q=\(queryEncoded)&classification=Paintings&hasImages=true"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching search data: \(error)")
                return
            }
            
            guard let data = data else {
                print("No data received from search API")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let searchResponse = try decoder.decode(SearchResponse.self, from: data)
                guard let objectIDs = searchResponse.objectIDs else {
                    print("No object IDs found in the response")
                    return
                }
                
                self.fetchMuseumDetails(for: objectIDs)
                
            } catch {
                print("Error decoding response from Met Museum API search: \(error)")
            }
        }.resume()
    }
    
   
    func fetchMuseumDetails(for ids: [Int]) {
        let dispatchGroup = DispatchGroup()
        var fetchedArtifacts: [MuseumArtifact] = []
        
        for id in ids.prefix(10) {
            dispatchGroup.enter()
            
            let urlString = "https://collectionapi.metmuseum.org/public/collection/v1/objects/\(id)"
            guard let url = URL(string: urlString) else {
                dispatchGroup.leave()
                continue
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                defer { dispatchGroup.leave() }
                
                if let error = error {
                    print("Error fetching artifact details for ID \(id): \(error)")
                    return
                }
                
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        let artifact = try decoder.decode(MuseumArtifact.self, from: data)
                        fetchedArtifacts.append(artifact)
                    } catch {
                        print("Failed decoding artifact data for ID \(id): \(error)")
                    }
                }
            }.resume()
        }
        
        dispatchGroup.notify(queue: .main) {
            self.artifacts = fetchedArtifacts
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Search Response Model
    struct SearchResponse: Decodable {
        let objectIDs: [Int]?
        
        enum CodingKeys: String, CodingKey {
            case objectIDs = "objectIDs"
        }
    }
}
