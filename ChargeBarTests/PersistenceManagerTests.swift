//
//  PersistenceManagerTests.swift
//  ChargeBarTests
//
//  Created by Damien Glancy on 25/04/2021.
//

import XCTest
@testable import ChargeBar

class PersistenceManagerTests: BaseXCTestCase {
  
  // MARK: - Lifecycle
  
  override func setUp() {
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
  }
  
  override func tearDown() {
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
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
    _ = AccountMO(context: viewContext)

    XCTAssertTrue(viewContext.hasChanges)
    _ = viewContext.saveOrRollback()
    XCTAssertFalse(viewContext.hasChanges)
  }
  
  func testSaveConextUpdateAtOnExistingObject() {
    let object = AccountMO(context: viewContext)
    object.username = "Test Username"
    XCTAssertTrue(viewContext.hasChanges)

    _ = viewContext.saveOrRollback()

    XCTAssertFalse(viewContext.hasChanges)

    object.username = "Updated Username"
    XCTAssertTrue(viewContext.hasChanges)
    _ = viewContext.saveOrRollback()
    XCTAssertFalse(viewContext.hasChanges)
  }
  
  func testCreateNewEntity() {
    let entity = AccountMO(context: viewContext)
    XCTAssertNotNil(entity)
  }
  
  func testEntityName() {
    XCTAssertEqual("AccountMO", AccountMO.entity().name!)
  }

  func testEntityDescription() {
    XCTAssertNotNil(AccountMO.entity())
    XCTAssertTrue(AccountMO.entity().isKind(of: NSEntityDescription.self))
  }
  
  func testCount() {
    XCTAssertEqual(0, PersistenceManager.shared.count(entityName: AccountMO.className(), context: viewContext))
    
    _ = AccountMO(context: viewContext)
    _ = viewContext.saveOrRollback()
    
    XCTAssertEqual(1, PersistenceManager.shared.count(entityName: AccountMO.className(), context: viewContext))
  }
  
  func testFindFirst() {
    XCTAssertEqual(0, PersistenceManager.shared.count(entityName: AccountMO.className(), context: viewContext))
    
    let accountMO = AccountMO(context: viewContext)
    _ = viewContext.saveOrRollback()
    
    XCTAssertEqual(1, PersistenceManager.shared.count(entityName: AccountMO.className(), context: viewContext))
    
    let foundAccountMO = PersistenceManager.shared.findFirst(entityName: AccountMO.className(), context: viewContext) as! AccountMO
    XCTAssertNotNil(foundAccountMO)
    XCTAssertEqual(accountMO, foundAccountMO)
  }
  
  func testFindFirstNothingFound() {
    XCTAssertEqual(0, PersistenceManager.shared.count(entityName: AccountMO.className(), context: viewContext))
    XCTAssertNil(PersistenceManager.shared.findFirst(entityName: AccountMO.className(), context: viewContext))
  }

  func testDeleteAll() {
    _ = AccountMO(context: viewContext)
    _ = viewContext.saveOrRollback()

    XCTAssertEqual(1, PersistenceManager.shared.count(entityName: AccountMO.className(), context: viewContext))
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
    XCTAssertEqual(0, PersistenceManager.shared.count(entityName: AccountMO.className(), context: viewContext))
  }
}
