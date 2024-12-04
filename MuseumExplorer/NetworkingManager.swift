//
//  NetworkingManager.swift
//  MuseumExplorer
//
//  Created by Gurpreet Singh on 2024-11-26.
//

import Foundation

protocol NetworkingDelegate {
    func networkingDidFinishWithArtifacts(artifacts: [MuseumArtifact])
    func networkingDidFail()
}

class NetworkingManager {
    
    static var shared = NetworkingManager()
    var delegate: NetworkingDelegate?
    
    // Fetch Artifact IDs from API (top-level object)
    func getArtifactIDsFromAPI(completionHandler: @escaping (Result<[Int], Error>) -> Void) {
        let url = URL(string: "https://collectionapi.metmuseum.org/public/collection/v1/objects")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching artifact IDs: \(error)")
                completionHandler(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.delegate?.networkingDidFail()
                return
            }
            
            if let goodData = data {
                let decoder = JSONDecoder()
                do {
                    let response = try decoder.decode(ArtifactIDResponse.self, from: goodData)
                    completionHandler(.success(response.objectIDs))
                } catch {
                    print("Error decoding artifact IDs: \(error)")
                    completionHandler(.failure(error))
                }
            }
        }
        dataTask.resume()
    }
    
    
    func getMuseumArtifactDetailsFromAPI(artifactID: Int, completionHandler: @escaping (Result<MuseumArtifact, Error>) -> Void) {
        let url = URL(string: "https://collectionapi.metmuseum.org/public/collection/v1/objects/\(artifactID)")!
        
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching artifact details for ID \(artifactID): \(error)")
                completionHandler(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                self.delegate?.networkingDidFail()
                return
            }
            
            if let goodData = data {
                let decoder = JSONDecoder()
                do {
                    let artifact = try decoder.decode(MuseumArtifact.self, from: goodData)
                    completionHandler(.success(artifact))
                } catch {
                    print("Error decoding artifact details: \(error)")
                    completionHandler(.failure(error))
                }
            }
        }
        dataTask.resume()
    }
}


struct ArtifactIDResponse: Decodable {
    var objectIDs: [Int]
    
    enum CodingKeys: String, CodingKey {
        case objectIDs = "objectIDs"
    }
}
