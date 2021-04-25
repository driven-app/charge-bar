//
//  PersistenceManagerTests.swift
//  ChargeBarTests
//
//  Created by Damien Glancy on 25/04/2021.
//

import XCTest
@testable import ChargeBar

class PersistenceManagerTests: BaseXCTestCase {
  
  // MARK: - Properties
  
  let mockDate = Date(timeIntervalSinceNow: -100)
  
  // MARK: - Lifecycle
  
  override func setUp() {
    PersistenceManager.shared.deleteAll(entityName: VehicleEntity.className(), context: viewContext)
  }
  
  override func tearDown() {
    PersistenceManager.shared.deleteAll(entityName: VehicleEntity.className(), context: viewContext)
  }
  
  // MARK: - Tests

  func testPersistentContainer() {
    XCTAssertNotNil(PersistenceManager.shared.container)
    XCTAssertNotNil(PersistenceManager.shared.container.persistentStoreCoordinator)
    XCTAssertNotNil(PersistenceManager.shared.container.persistentStoreCoordinator.persistentStores)
    XCTAssertEqual(1, PersistenceManager.shared.container.persistentStoreCoordinator.persistentStores.count)
  }
  
  func testSaveContextWhenNothingToSave() {
    XCTAssertFalse(viewContext.hasChanges)
    XCTAssertFalse(viewContext.saveOrRollback())
  }
  
  func testSaveContext() {
    XCTAssertFalse(viewContext.hasChanges)
    let object = VehicleEntity(context: viewContext)
    object.modelDescription = "Test Model"

    XCTAssertTrue(viewContext.hasChanges)
    XCTAssertNil(object.createdAt)
    XCTAssertNil(object.updatedAt)
    XCTAssertNil(object.id)

    _ = viewContext.saveOrRollback(date: mockDate)

    XCTAssertFalse(viewContext.hasChanges)
    XCTAssertEqual(mockDate, object.createdAt)
    XCTAssertEqual(mockDate, object.updatedAt)
    XCTAssertNotNil(object.id)
  }
  
  func testSaveConextUpdateAtOnExistingObject() {
    let mockUpdatedAt = Date()

    let object = VehicleEntity(context: viewContext)
    object.modelDescription = "Test Model"
    XCTAssertTrue(viewContext.hasChanges)

    _ = viewContext.saveOrRollback(date: mockDate)

    XCTAssertFalse(viewContext.hasChanges)
    XCTAssertEqual(mockDate, object.createdAt)
    XCTAssertEqual(mockDate, object.updatedAt)

    object.modelDescription = "Test Model 2"
    XCTAssertTrue(viewContext.hasChanges)
    _ = viewContext.saveOrRollback(date: mockUpdatedAt)

    XCTAssertFalse(viewContext.hasChanges)
    XCTAssertEqual(mockDate, object.createdAt)
    XCTAssertEqual(mockUpdatedAt, object.updatedAt)
  }
  
  func testCreateNewEntity() {
    let entity = VehicleEntity(context: viewContext)
    XCTAssertNotNil(entity)
  }
  
  func testEntityName() {
    XCTAssertEqual("VehicleEntity", VehicleEntity.entityName)
  }

  func testEntityDescription() {
    XCTAssertNotNil(VehicleEntity.entity)
    XCTAssertTrue(VehicleEntity.entity.isKind(of: NSEntityDescription.self))
  }
  
  func testCount() {
    XCTAssertEqual(0, PersistenceManager.shared.count(entityName: VehicleEntity.className(), context: viewContext))
    
    _ = VehicleEntity(context: viewContext)
    _ = viewContext.saveOrRollback()
    
    XCTAssertEqual(1, PersistenceManager.shared.count(entityName: VehicleEntity.className(), context: viewContext))
  }

  func testDeleteAll() {
    _ = VehicleEntity(context: viewContext)
    _ = viewContext.saveOrRollback()

    XCTAssertEqual(1, PersistenceManager.shared.count(entityName: VehicleEntity.className(), context: viewContext))
    PersistenceManager.shared.deleteAll(entityName: VehicleEntity.className(), context: viewContext)
    XCTAssertEqual(0, PersistenceManager.shared.count(entityName: VehicleEntity.className(), context: viewContext))
  }
}
