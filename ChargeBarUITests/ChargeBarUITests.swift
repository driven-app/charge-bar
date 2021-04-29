//
//  ChargeBarUITests.swift
//  ChargeBarUITests
//
//  Created by Damien Glancy on 09/02/2021.
//

import XCTest

class ChargeBarUITests: BaseUITestCase {
    
  // MARK: - Lifecycle
  
  override func setUp() {
    super.setUp()
    tapMenuBar()
  }
  
  // MARK: - Tests
  
  func testOpenCloseStatusBarMenu() {
    XCTAssertNotNil(menuBarsQuery!.menuItems["Preferences"])
    XCTAssertNotNil(menuBarsQuery!.menuItems["Quit ChargeBar"])
  }
  
  func testOpenClosePreferencesDialog() {
    openPreferencesWindow()
    app.windows["ChargeBar Preferences"].buttons[XCUIIdentifierCloseWindow].click()
  }
  
  func testAppStartsLoggedOutInTestMode() {
    openPreferencesWindow()
    
    let preferencesWindow = app.windows["ChargeBar Preferences"]
    XCTAssertEqual("Not Connected", preferencesWindow.staticTexts["AccountStatusTextField"].value as! String)
    XCTAssertEqual("Login ...", preferencesWindow.buttons["LoginLogoutBtn"].title)
    
    let table = preferencesWindow.tables["VehiclesTable"]
    XCTAssertEqual(3, table.tableColumns.count)
    XCTAssertNotNil(table.tableColumns["Name"])
    XCTAssertNotNil(table.tableColumns["License Plate"])
    XCTAssertNotNil(table.tableColumns["VIN"])
    XCTAssertEqual(0, table.tableRows.count)
  }
  
  func testAppLoginSheetCancelled() {
    openPreferencesWindow()
    
    let preferencesWindow = app.windows["ChargeBar Preferences"]
    preferencesWindow.buttons["LoginLogoutBtn"].click()
    
    XCTAssertEqual(1, preferencesWindow.sheets.count)
    let sheet = preferencesWindow.sheets["LoginSheet"]
    
    let cancelBtn = sheet.buttons["CancelBtn"]
    cancelBtn.click()
    
    XCTAssertEqual(0, preferencesWindow.sheets.count)
  }
  
  func testAppLoginFailed() {
    mockNetworkRoutes.mockPostLoginAuthFailure(router: MockPorscheConnectServer.shared.router)
    
    openPreferencesWindow()
    
    let preferencesWindow = app.windows["ChargeBar Preferences"]
    preferencesWindow.buttons["LoginLogoutBtn"].click()
    
    XCTAssertEqual(1, preferencesWindow.sheets.count)
    let sheet = preferencesWindow.sheets["LoginSheet"]
    
    let usernameField = sheet.textFields["UsernameTextField"]
    XCTAssertEqual(kBlankString, usernameField.value as! String)
    
    let passwordField = sheet.secureTextFields["PasswordSecureTextField"]
    XCTAssertEqual(kBlankString, passwordField.value as! String)
    
    usernameField.typeText("homer.simpson@icloud.example")
    passwordField.tap()
    passwordField.typeText("Duh!")
    
    sheet.buttons["LoginBtn"].click()
        
    _ = app.staticTexts["Login Error"].waitForExistence(timeout: kDefaultTestTimeout)
  }
  
  // MARK: - Private
  
  private func openPreferencesWindow() {
    menuBarsQuery!.menuItems["Preferences..."].click()
  }
}
