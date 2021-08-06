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
    PersistenceManager.shared.deleteAll(entityName: EmobilityMO.className(), context: viewContext)
    
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
    PersistenceManager.shared.deleteAll(entityName: EmobilityMO.className(), context: viewContext)
  }
  
  // MARK: - Tests

  func testSyncWhileNotCharging() {
    let expectation = self.expectation(description: "Network Expectation")

    mockLoginSuccess()
    mockNetworkRoutes.mockGetEmobilityNotChargingSuccessful(router: MockPorscheConnectServer.shared.router)
    
    XCTAssertNil(vehicleMO!.emobility)
    
    service!.sync { [self] result in
      expectation.fulfill()
      
      let emobilityMO = vehicleMO!.emobility!
      XCTAssertNotNil(emobilityMO)
      XCTAssertFalse(emobilityMO.chargingInDCMode)
      XCTAssertEqual("OFF", emobilityMO.chargingMode)
      XCTAssertEqual(0, emobilityMO.chargingPower)
      XCTAssertEqual("OFF", emobilityMO.chargingState)
      XCTAssertFalse(emobilityMO.directCharge)
      XCTAssertEqual("NONE", emobilityMO.ledColor)
      XCTAssertEqual("UNLOCKED", emobilityMO.lockState)
      XCTAssertEqual("DISCONNECTED", emobilityMO.plugState)
      XCTAssertEqual(191, emobilityMO.remainingERange)
      XCTAssertEqual("KILOMETER", emobilityMO.remainingERangeUnit)
      XCTAssertEqual(56, emobilityMO.stateOfChargeInPercentage)
      XCTAssertNotNil(emobilityMO.syncDate)
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  func testSyncWhileACDirectCharging() {
    let expectation = self.expectation(description: "Network Expectation")

    mockLoginSuccess()
    mockNetworkRoutes.mockGetEmobilityACDirectChargingSuccessful(router: MockPorscheConnectServer.shared.router)
    
    XCTAssertNil(vehicleMO!.emobility)
    
    service!.sync { [self] result in
      expectation.fulfill()
      
      let emobilityMO = vehicleMO!.emobility!
      XCTAssertNotNil(emobilityMO)
      XCTAssertFalse(emobilityMO.chargingInDCMode)
      XCTAssertEqual("AC", emobilityMO.chargingMode)
      XCTAssertEqual(20.71, emobilityMO.chargingPower)
      XCTAssertEqual("CHARGING", emobilityMO.chargingState)
      XCTAssertTrue(emobilityMO.directCharge)
      XCTAssertEqual("GREEN", emobilityMO.ledColor)
      XCTAssertEqual("LOCKED", emobilityMO.lockState)
      XCTAssertEqual("CONNECTED", emobilityMO.plugState)
      XCTAssertEqual(191, emobilityMO.remainingERange)
      XCTAssertEqual("KILOMETER", emobilityMO.remainingERangeUnit)
      XCTAssertEqual(56, emobilityMO.stateOfChargeInPercentage)
      XCTAssertNotNil(emobilityMO.syncDate)
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  func testSyncWhileACTimerCharging() {
    let expectation = self.expectation(description: "Network Expectation")

    mockLoginSuccess()
    mockNetworkRoutes.mockGetEmobilityACTimerChargingSuccessful(router: MockPorscheConnectServer.shared.router)
    
    XCTAssertNil(vehicleMO!.emobility)
    
    service!.sync { [self] result in
      expectation.fulfill()
      
      let emobilityMO = vehicleMO!.emobility!
      XCTAssertNotNil(emobilityMO)
      XCTAssertFalse(emobilityMO.chargingInDCMode)
      XCTAssertEqual("AC", emobilityMO.chargingMode)
      XCTAssertEqual(6.58, emobilityMO.chargingPower)
      XCTAssertEqual("CHARGING", emobilityMO.chargingState)
      XCTAssertFalse(emobilityMO.directCharge)
      XCTAssertEqual("GREEN", emobilityMO.ledColor)
      XCTAssertEqual("LOCKED", emobilityMO.lockState)
      XCTAssertEqual("CONNECTED", emobilityMO.plugState)
      XCTAssertEqual(191, emobilityMO.remainingERange)
      XCTAssertEqual("KILOMETER", emobilityMO.remainingERangeUnit)
      XCTAssertEqual(56, emobilityMO.stateOfChargeInPercentage)
      XCTAssertNotNil(emobilityMO.syncDate)
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  func testSyncWhileDCCharging() {
    let expectation = self.expectation(description: "Network Expectation")

    mockLoginSuccess()
    mockNetworkRoutes.mockGetEmobilityDCChargingSuccessful(router: MockPorscheConnectServer.shared.router)
    
    XCTAssertNil(vehicleMO!.emobility)
    
    service!.sync { [self] result in
      expectation.fulfill()
      
      let emobilityMO = vehicleMO!.emobility!
      XCTAssertNotNil(emobilityMO)
      XCTAssertTrue(emobilityMO.chargingInDCMode)
      XCTAssertEqual("DC", emobilityMO.chargingMode)
      XCTAssertEqual(48.56, emobilityMO.chargingPower)
      XCTAssertEqual("CHARGING", emobilityMO.chargingState)
      XCTAssertFalse(emobilityMO.directCharge)
      XCTAssertEqual("GREEN", emobilityMO.ledColor)
      XCTAssertEqual("LOCKED", emobilityMO.lockState)
      XCTAssertEqual("CONNECTED", emobilityMO.plugState)
      XCTAssertEqual(191, emobilityMO.remainingERange)
      XCTAssertEqual("KILOMETER", emobilityMO.remainingERangeUnit)
      XCTAssertEqual(56, emobilityMO.stateOfChargeInPercentage)
      XCTAssertNotNil(emobilityMO.syncDate)
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  func testExistingEmobilityRecordOverwritten() {
    let expectation = self.expectation(description: "Network Expectation")
    
    XCTAssertEqual(0, PersistenceManager.shared.count(entityName: EmobilityMO.className(), context: viewContext))
    
    let existingEmobilityMO = EmobilityMO(context: viewContext)
    existingEmobilityMO.syncDate = Date()
    vehicleMO!.emobility = existingEmobilityMO
    
    viewContext.saveOrRollback()
    
    XCTAssertEqual(1, PersistenceManager.shared.count(entityName: EmobilityMO.className(), context: viewContext))

    XCTAssertNotNil(vehicleMO!.emobility)
    XCTAssertFalse(vehicleMO!.emobility!.chargingInDCMode)
    XCTAssertEqual("OFF", vehicleMO!.emobility!.chargingMode)
    XCTAssertEqual(0, vehicleMO!.emobility!.chargingPower)
    XCTAssertEqual("OFF", vehicleMO!.emobility!.chargingState)
    XCTAssertFalse(vehicleMO!.emobility!.directCharge)
    XCTAssertEqual("NONE", vehicleMO!.emobility!.ledColor)
    XCTAssertEqual("UNLOCKED", vehicleMO!.emobility!.lockState)
    XCTAssertEqual("DISCONNECTED", vehicleMO!.emobility!.plugState)
    XCTAssertEqual(0, vehicleMO!.emobility!.remainingERange)
    XCTAssertEqual("KILOMETER", vehicleMO!.emobility!.remainingERangeUnit)
    XCTAssertEqual(0, vehicleMO!.emobility!.stateOfChargeInPercentage)
    XCTAssertNotNil(vehicleMO!.emobility!.syncDate)
    
    mockLoginSuccess()
    mockNetworkRoutes.mockGetEmobilityDCChargingSuccessful(router: MockPorscheConnectServer.shared.router)
        
    service!.sync { [self] result in
      expectation.fulfill()
      
      let emobilityMO = vehicleMO!.emobility!
      XCTAssertNotNil(emobilityMO)
      XCTAssertTrue(emobilityMO.chargingInDCMode)
      XCTAssertEqual("DC", emobilityMO.chargingMode)
      XCTAssertEqual(48.56, emobilityMO.chargingPower)
      XCTAssertEqual("CHARGING", emobilityMO.chargingState)
      XCTAssertFalse(emobilityMO.directCharge)
      XCTAssertEqual("GREEN", emobilityMO.ledColor)
      XCTAssertEqual("LOCKED", emobilityMO.lockState)
      XCTAssertEqual("CONNECTED", emobilityMO.plugState)
      XCTAssertEqual(191, emobilityMO.remainingERange)
      XCTAssertEqual("KILOMETER", emobilityMO.remainingERangeUnit)
      XCTAssertEqual(56, emobilityMO.stateOfChargeInPercentage)
      XCTAssertNotNil(emobilityMO.syncDate)
    }
    
    XCTAssertEqual(1, PersistenceManager.shared.count(entityName: EmobilityMO.className(), context: viewContext))
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
}
