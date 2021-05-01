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
  
  func openPreferencesWindow() {
    menuBarsQuery!.menuItems["Preferences..."].click()
  }
  
  func loginToPorscheConnect(successfully successful: Bool = true) {
    if successful {
      mockLoginSuccess()
    } else {
      mockLoginFailure()
    }
    
    openPreferencesWindow()
    
    let preferencesWindow = app.windows["ChargeBar Preferences"]
    preferencesWindow.buttons["LoginLogoutBtn"].click()
    
    let table = preferencesWindow.tables["VehiclesTable"]
    XCTAssertEqual(0, table.tableRows.count)
    
    XCTAssertEqual(1, preferencesWindow.sheets.count)
    let sheet = preferencesWindow.sheets["LoginSheet"]
    
    let usernameField = sheet.textFields["UsernameTextField"]
    let passwordField = sheet.secureTextFields["PasswordSecureTextField"]
    
    usernameField.typeText("homer.simpson@icloud.example")
    passwordField.tap()
    passwordField.typeText("Duh!")
    
    sheet.buttons["LoginBtn"].click()
    
    if successful {
      _ = app.staticTexts["Connected"].waitForExistence(timeout: kDefaultTestTimeout)
      
      XCTAssertEqual(1, table.tableRows.count)
      
      let cells = table.tableRows.element(boundBy: 0).cells
      XCTAssertEqual("Porsche Taycan 4S", cells.staticTexts["NameCell"].value as! String)
      XCTAssertEqual("TAY-CAN", cells.staticTexts["LicensePlateCell"].value as! String)
      XCTAssertEqual("VIN12345", cells.staticTexts["VINCell"].value as! String)
      
    } else {
      _ = app.staticTexts["Login Error"].waitForExistence(timeout: kDefaultTestTimeout)
    }
    
    preferencesWindow.buttons[XCUIIdentifierCloseWindow].click()
  }
  
  // MARK: - Private functions
  
  fileprivate func mockLoginSuccess() {
    mockNetworkRoutes.mockPostLoginAuthSuccessful(router: MockPorscheConnectServer.shared.router)
    mockNetworkRoutes.mockGetApiAuthSuccessful(router: MockPorscheConnectServer.shared.router)
    mockNetworkRoutes.mockPostApiTokenSuccessful(router: MockPorscheConnectServer.shared.router)
  }
  
  fileprivate func mockLoginFailure() {
    mockNetworkRoutes.mockPostLoginAuthFailure(router: MockPorscheConnectServer.shared.router)
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
