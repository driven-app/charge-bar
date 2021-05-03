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
    mockNetworkRoutes.mockGetCapabilitiesSuccessful(router: MockPorscheConnectServer.shared.router)
    
    XCTAssertEqual(0, accountMO!.vehicles!.count)
    
    service!.sync { (result) in
      expectation.fulfill()
      XCTAssertEqual(1, self.accountMO!.vehicles!.count)
      
      let vehicleMO = self.accountMO!.vehicles!.firstObject as! VehicleMO
      XCTAssertEqual("Porsche Taycan 4S", vehicleMO.modelDescription)
      XCTAssertEqual("A Test Model Type", vehicleMO.modelType)
      XCTAssertEqual("2021", vehicleMO.modelYear)
      XCTAssertEqual("VIN12345", vehicleMO.vin)
      XCTAssertTrue(vehicleMO.selected)
      XCTAssertEqual("TAY-CAN", vehicleMO.licensePlate)
      XCTAssertNotNil(vehicleMO.capabilities)
      
      let capabilitiesMO = vehicleMO.capabilities!
      XCTAssertEqual("J1", capabilitiesMO.carModel)
      XCTAssertEqual("BEV", capabilitiesMO.engineType)
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
}
