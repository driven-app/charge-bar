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

  let service = EmobilityService(porscheConnect: PorscheConnect(username: "homer.simpson@icloud.example", password: "Duh!"))
  
  // MARK: - Tests

  func testSyncWhileNotCharging() {
    mockNetworkRoutes.mockGetEmobilityNotChargingSuccessful(router: MockPorscheConnectServer.shared.router)
    
    service.sync()
  }
}
