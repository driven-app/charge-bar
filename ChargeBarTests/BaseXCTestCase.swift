//
//  BaseXCTestCase.swift
//  ChargeBarTests
//
//  Created by Damien Glancy on 25/04/2021.
//

import XCTest
@testable import ChargeBar

// MARK: - Static Constants

class BaseXCTestCase: XCTestCase {
  
  // MARK: - Static Constants
  
  let kDefaultTestTimeout: TimeInterval = 500
  
  // MARK: - Properties
  
  var viewContext = PersistenceManager.shared.container.viewContext
  let mockNetworkRoutes = MockNetworkRoutes()
  
  // MARK: - Common lifecycle
  
  override func setUp() {
    super.setUp()
    HTTPCookieStorage.shared.cookies?.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
  }
  
  // MARK: - Common functions
  
  func mockLoginSuccess() {
    mockNetworkRoutes.mockPostLoginAuthSuccessful(router: MockPorscheConnectServer.shared.router)
    mockNetworkRoutes.mockGetApiAuthSuccessful(router: MockPorscheConnectServer.shared.router)
    mockNetworkRoutes.mockPostApiTokenSuccessful(router: MockPorscheConnectServer.shared.router)
  }
  
  func mockLoginFailure() {
    mockNetworkRoutes.mockPostLoginAuthFailure(router: MockPorscheConnectServer.shared.router)
  }
}
