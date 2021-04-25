//
//  Base.swift
//  ChargeBar
//
//  Created by Damien Glancy on 25/04/2021.
//

import Foundation
import CoreData

protocol Managed: class, NSFetchRequestResult {
  static var entity: NSEntityDescription { get }
  static var entityName: String { get }
}

extension Managed where Self: NSManagedObject {
  
  // MARK: Static Computed Properties
  
  static var entity: NSEntityDescription { return entity() }
  static var entityName: String { return entity.name! }
  
}

// MARK: - Base Managed Object

class BaseManagedObject: NSManagedObject, Managed, Identifiable {
  
  // MARK:  Properties
  
  @NSManaged var id: UUID?
  @NSManaged var createdAt: Date?
  @NSManaged var updatedAt: Date?
  
  // MARK: - Functions
  
  func updateProperties(date: Date) {
    updateTimestamps(date: date)
    if id == nil { createUUID() }
  }
  
  // MARK: - Private Functions
  
  private func createUUID() {
    id = UUID()
  }
  
  private func updateTimestamps(date: Date) {
    if createdAt == nil { createdAt = date }
    updatedAt = date
  }
}
