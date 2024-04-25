//
//  Database.swift
//  Quiz Master
//
//  Created by Phua June Jin on 23/04/2024.
//

import CoreData
import Foundation

/// Singleton for CoreData Stack.
class CoreDataStack {
  static let shared = CoreDataStack()

  private init() {}

  lazy var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Quiz_Master")
    container.loadPersistentStores(completionHandler: { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })

    return container
  }()

  func saveContext () {
    let context = persistentContainer.viewContext

    if context.hasChanges {
      do {
        try context.save()
      } catch {
        let nserror = error as NSError

        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
}

/**
 Singleton to access CoreData-related operation.
 */
class Database {
  static let shared = Database(context: CoreDataStack.shared.persistentContainer.viewContext.persistentStoreCoordinator)

  private var mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

  private init(context: NSPersistentStoreCoordinator?) {
    mainContext.persistentStoreCoordinator = context
    mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    mainContext.automaticallyMergesChangesFromParent = true
  }

  @discardableResult func saveScore(score: Int64, initials: String) throws -> Bool {
    guard NSEntityDescription.entity(forEntityName: "Scores", in: self.mainContext) != nil else {
      throw DatabaseError.invalidEntity
    }

    do {
      let new = Scores.init(context: self.mainContext)
      new.setValue(score, forKey: "score")
      new.setValue(initials, forKey: "initials")

      try self.mainContext.save()

      return true
    } catch let error {
      throw error
    }
  }

  func getScore() throws -> [Scores] {
    guard NSEntityDescription.entity(forEntityName: "Scores", in: self.mainContext) != nil else {
      throw DatabaseError.invalidEntity
    }

    do {
      let request = NSFetchRequest<Scores>(entityName: "Scores")
      request.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
      request.fetchLimit = 10

      let fetched = try self.mainContext.fetch(request)

      try self.mainContext.save()

      return fetched
    } catch {
      throw error
    }
  }

  func getLastRankingScore() throws -> Int64 {
    guard NSEntityDescription.entity(forEntityName: "Scores", in: self.mainContext) != nil else {
      throw DatabaseError.invalidEntity
    }

    do {
      let request = NSFetchRequest<Scores>(entityName: "Scores")
      request.sortDescriptors = [NSSortDescriptor(key: "score", ascending: true)]
      request.fetchLimit = 1

      let fetched = try self.mainContext.fetch(request)

      return fetched.first?.score ?? 0
    } catch {
      throw error
    }
  }

  func delete(_ score: Scores) throws {
    guard NSEntityDescription.entity(forEntityName: "Scores", in: self.mainContext) != nil else {
      throw DatabaseError.invalidEntity
    }

    do {
      self.mainContext.delete(score)

      try self.mainContext.save()
    } catch {
      throw error
    }
  }
}
