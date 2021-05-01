//
//  VehiclesServiceTests.swift
//  ChargeBarTests
//
//  Created by Damien Glancy on 01/05/2021.
//

import XCTest
import PorscheConnect
@testable import ChargeBar

class VehiclesServiceTests: BaseXCTestCase {

  var accountMO: AccountMO?
  var service: VehiclesService?

  override func setUp() {
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
    
    accountMO = AccountMO(context: viewContext)
    accountMO!.username = "homer.simpson@icloud.example"
    viewContext.saveOrRollback()
    
    let porscheConnect = PorscheConnect(username: "homer.simpson@icloud.example", password: "Duh!", environment: .Test)
    service = VehiclesService(porscheConnect: porscheConnect, accountMO: accountMO!)
    
    XCTAssertNotNil(accountMO)
    XCTAssertNotNil(service)
  }
  
  override func tearDown() {
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
  }
  
  // MARK: - Tests

  func testSync() {
    let expectation = self.expectation(description: "Network Expectation")
    mockLoginSuccess()
    mockNetworkRoutes.mockGetVehiclesSuccessful(router: MockPorscheConnectServer.shared.router)

    XCTAssertEqual(0, accountMO!.vehicles!.count)
    service!.sync { _ in
      expectation.fulfill()
      XCTAssertEqual(1, self.accountMO!.vehicles!.count)
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
}
