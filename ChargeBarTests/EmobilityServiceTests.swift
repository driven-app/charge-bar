//
//  EmobilityServiceTests.swift
//  ChargeBarTests
//
//  Created by Damien Glancy on 01/05/2021.
//

import XCTest
import PorscheConnect
@testable import ChargeBar

class EmobilityServiceTests: BaseXCTestCase {

  var vehicleMO: VehicleMO?
  var service: EmobilityService?
  
  override func setUp() {
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
    
    let accountMO = AccountMO(context: viewContext)
    accountMO.username = "homer.simpson@icloud.example"
    
    vehicleMO = VehicleMO(context: viewContext)
    vehicleMO!.modelDescription = "Porsche Taycan 4S"
    vehicleMO!.modelType = "A Test Model Type"
    vehicleMO!.modelYear = "2021"
    vehicleMO!.vin = "VIN12345"
    vehicleMO!.licensePlate = "TAY-CAN"
    
    let capabilitiesMO = CapabilitiesMO(context: viewContext)
    capabilitiesMO.carModel = "J1"
    capabilitiesMO.engineType = "BEV"
    vehicleMO!.capabilities = capabilitiesMO

    accountMO.addToVehicles(vehicleMO!)
  
    viewContext.saveOrRollback()
    
    let porscheConnect = PorscheConnect(username: "homer.simpson@icloud.example", password: "Duh!", environment: .Test)
    service = EmobilityService(porscheConnect: porscheConnect, vehicleMO: vehicleMO!)
    
    XCTAssertNotNil(vehicleMO)
    XCTAssertNotNil(service)
  }
  
  override func tearDown() {
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
  }
  
  // MARK: - Tests

  func testSyncWhileNotCharging() {
    let expectation = self.expectation(description: "Network Expectation")

    mockLoginSuccess()
    mockNetworkRoutes.mockGetEmobilityNotChargingSuccessful(router: MockPorscheConnectServer.shared.router)
    
    service!.sync { result in
      expectation.fulfill()
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
}
