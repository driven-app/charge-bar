//
//  PersistenceManager.swift
//  ChargeBar
//
//  Created by Damien Glancy on 25/04/2021.
//

import CoreData

struct PersistenceManager {
  
  // MARK: - Singleton
  
  static let shared = PersistenceManager()
  
  // MARK: - Properties
  
  let container: NSPersistentContainer
  
  // MARK: - Lifecycle
  
  private init(inMemory: Bool = false) {
    container = NSPersistentContainer(name: "ChargeBar")
    
    if inMemory {
      container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
    }
    
    container.loadPersistentStores { (_, error) in
      if let errorMessage = error?.localizedDescription {
        CoreDataLogger.error("Error creating persistent container and store: \(errorMessage)")
      }
    }
  }
  
  // MARK: - Actions
  
  func count(entityName: String, context: NSManagedObjectContext) -> Int {
    return try! context.count(for: NSFetchRequest(entityName: entityName))
  }
  
  func deleteAll(entityName: String, context: NSManagedObjectContext) {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    try! context.execute(batchDeleteRequest)
    context.saveOrRollback()
  }
}

extension NSManagedObjectContext {

  // MARK: - Save Functions

  @discardableResult func saveOrRollback(date: Date = Date()) -> Bool {
    guard hasChanges else {
      return false
    }

    insertedObjects.union(updatedObjects).compactMap { $0 as? BaseManagedObject }.forEach { baseManagedObject in
      baseManagedObject.updateProperties(date: date)
    }

    let result: Bool

    do {
      try save()
      result = true
    } catch {
      rollback()
      result = false
    }

    return result
  }
}
