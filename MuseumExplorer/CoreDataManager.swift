//
//  CoreDataManager.swift
//  MuseumExplorer
//
//  Created by Gurpreet Singh on 2024-12-09.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
       
       private init() {}

       lazy var persistentContainer: NSPersistentContainer = {
           let container = NSPersistentContainer(name: "MuseumExplorer")
           
           container.loadPersistentStores { storeDescription, error in
               if let error = error as NSError? {
                   print("Core Data failed to load: \(error)")
                   fatalError()
               }
           }
           return container
       }()
       
       func saveContext() {
           let context = persistentContainer.viewContext
           if context.hasChanges {
               do {
                   try context.save()
                   print("Context saved successfully.")
               } catch {
                   print("Error saving context: \(error)")
               }
           }
       }

       func fetchArtifact(byID id: Int) -> Artifact? {
           let context = persistentContainer.viewContext
           let request: NSFetchRequest<Artifact> = Artifact.fetchRequest()
           request.predicate = NSPredicate(format: "objectID == %d", id)

           do {
               let results = try context.fetch(request)
               return results.first
           } catch {
               print("Error fetching artifact by ID: \(error)")
               return nil
           }
       }

       func addArtifactToCoreData(artifact: MuseumArtifact) {
           
           let context = persistentContainer.viewContext
              let fetchRequest: NSFetchRequest<Artifact> = Artifact.fetchRequest()
              fetchRequest.predicate = NSPredicate(format: "id == %d", artifact.objectID)

              do {
                  let results = try context.fetch(fetchRequest)
                  if results.isEmpty {
                      let newArtifact = Artifact(context: context)
                      newArtifact.id = Int64(artifact.objectID)
                      newArtifact.title = artifact.title
                      newArtifact.artifactDescription = artifact.artistDisplayBio
                      newArtifact.date = artifact.objectDate
                      newArtifact.imageURL = artifact.primaryImage
                      newArtifact.artist = artifact.artistDisplayName

                      saveContext()
                      print("Artifact with ID \(artifact.objectID) saved successfully. By artist:\(artifact.artistDisplayName) Title:\(artifact.title) artistbio:\(artifact.artistDisplayBio)")
                  } else {
                      print("Artifact with ID \(artifact.objectID) already exists.")
                  }
              } catch {
                  print("Error checking for duplicate artifacts: \(error)")
              }
       }
    
    func getAllSavedArtifacts() -> [Artifact] {
        var savedArtifacts: [Artifact] = []
        let fetchRequest = Artifact.fetchRequest()

        do {
            savedArtifacts = try persistentContainer.viewContext.fetch(fetchRequest)
            print("Fetched Artifacts Count: \(savedArtifacts.count)")
            for artifact in savedArtifacts {
                print("Artifact ID: \(artifact.id), Title: \(artifact.title)")
            }
        } catch {
            print("Error fetching saved artifacts: \(error)")
        }

        return savedArtifacts
    }
    
    func deleteArtifact(artifact: Artifact) {
        let context = persistentContainer.viewContext

        context.delete(artifact)
        
        do {
            try context.save()
            print("Deleted artifact: \(artifact.title)")
        } catch {
            print("Error deleting artifact: \(error)")
        }
    }
   }
