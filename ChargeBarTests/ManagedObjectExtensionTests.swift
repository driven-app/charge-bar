//
//  ManagedObjectExtensionTests.swift
//  ChargeBarTests
//
//  Created by Damien Glancy on 01/05/2021.
//

import XCTest
@testable import ChargeBar

class ManagedObjectTests: BaseXCTestCase {

  // MARK: - Lifecycle
  
  override func setUp() {
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
  }
  
  override func tearDown() {
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
  }
  
  // MARK: - Tests

  func testAccountMarkedProvisioned() {
    let account = AccountMO(context: viewContext)
    XCTAssertFalse(account.provisioned)
    XCTAssertTrue(account.isInserted)
    
    account.markProvisioned()
    XCTAssertTrue(account.provisioned)
    XCTAssertFalse(account.isUpdated)
  }
}
