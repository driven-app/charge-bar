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
    XCTAssertTrue(table.tableColumns["Name"].exists)
    XCTAssertTrue(table.tableColumns["License Plate"].exists)
    XCTAssertTrue(table.tableColumns["VIN"].exists)
    XCTAssertEqual(0, table.tableRows.count)
  }
  
  func testAppLoginSheet() {
    openPreferencesWindow()
    
    let preferencesWindow = app.windows["ChargeBar Preferences"]
    preferencesWindow.buttons["LoginLogoutBtn"].click()
    
    XCTAssertEqual(1, preferencesWindow.sheets.count)
    let sheet = preferencesWindow.sheets["LoginSheet"]
    
    let usernameField = sheet.textFields["UsernameTextField"]
    XCTAssertEqual(kBlankString, usernameField.value as! String)
    
    let passwordField = sheet.secureTextFields["PasswordSecureTextField"]
    XCTAssertEqual(kBlankString, passwordField.value as! String)
    
    let loginBtn = sheet.buttons["LoginBtn"]
    XCTAssertNotNil(loginBtn)
    
    let cancelBtn = sheet.buttons["CancelBtn"]
    XCTAssertNotNil(cancelBtn)
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
  
  func testAppLoginSuccess() {
    mockNetworkRoutes.mockPostLoginAuthSuccessful(router: MockPorscheConnectServer.shared.router)
    mockNetworkRoutes.mockGetApiAuthSuccessful(router: MockPorscheConnectServer.shared.router)
    mockNetworkRoutes.mockPostApiTokenSuccessful(router: MockPorscheConnectServer.shared.router)
    mockNetworkRoutes.mockGetVehiclesSuccessful(router: MockPorscheConnectServer.shared.router)
    
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

    _ = app.staticTexts["Connected"].waitForExistence(timeout: kDefaultTestTimeout)
    
    XCTAssertEqual(1, table.tableRows.count)

    let cells = table.tableRows.element(boundBy: 0).cells
    XCTAssertEqual("Porsche Taycan 4S", cells.staticTexts["NameCell"].value as! String)
    XCTAssertEqual("Porsche Taycan", cells.staticTexts["LicensePlateCell"].value as! String)
    XCTAssertEqual("VIN12345", cells.staticTexts["VINCell"].value as! String)
  }
  
  func testAppLoginFailed() {
    mockNetworkRoutes.mockPostLoginAuthFailure(router: MockPorscheConnectServer.shared.router)
    
    openPreferencesWindow()
    
    let preferencesWindow = app.windows["ChargeBar Preferences"]
    preferencesWindow.buttons["LoginLogoutBtn"].click()
    
    XCTAssertEqual(1, preferencesWindow.sheets.count)
    let sheet = preferencesWindow.sheets["LoginSheet"]
    
    let usernameField = sheet.textFields["UsernameTextField"]
    let passwordField = sheet.secureTextFields["PasswordSecureTextField"]

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
