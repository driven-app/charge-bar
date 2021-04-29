//
//  BaseUITestCase.swift
//  ChargeBarUITests
//
//  Created by Damien Glancy on 25/04/2021.
//

import XCTest

class BaseUITestCase: XCTestCase {

  // MARK: - Properties
  
  var app = XCUIApplication()
  var menuBarsQuery: XCUIElementQuery?
  var menuBarItem: XCUIElement?
  
  let mockNetworkRoutes = MockNetworkRoutes()
  
  // MARK: - Common lifecycle
  
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
    HTTPCookieStorage.shared.cookies?.forEach { HTTPCookieStorage.shared.deleteCookie($0) }
    menuBarsQuery = app.menuBars
    menuBarItem = menuBarsQuery!.children(matching: .statusItem).element
    app.launchEnvironment = ["TEST_MODE": "true"]
    app.launch()
  }
  
  override func tearDown() {
    menuBarsQuery = nil
    menuBarItem = nil
  }
  
  // MARK: - Common functions
  
  func tapMenuBar() {
    menuBarItem!.click()
  }

}

// MARK: - Extensions

extension XCTestCase {
  
  // MARK: - Functions
  
  func wait(forElement element: XCUIElement, timeout: TimeInterval) {
    let predicate = NSPredicate(format: "exists == 1")
    expectation(for: predicate, evaluatedWith: element)
    waitForExpectations(timeout: timeout)
  }
}
