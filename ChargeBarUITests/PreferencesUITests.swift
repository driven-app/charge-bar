//
//  PreferencesUITests.swift
//  ChargeBarUITests
//
//  Created by Damien Glancy on 01/05/2021.
//

import XCTest

class PreferencesUITests: BaseUITestCase {

  // MARK: - Lifecycle
  
  override func setUp() {
    super.setUp()
    tapMenuBar()
  }
  
  // MARK: - Tests
  
  func testOpenClosePreferencesDialog() {
    openPreferencesWindow()
    app.windows["ChargeBar Preferences"].buttons[XCUIIdentifierCloseWindow].click()
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
    mockNetworkRoutes.mockGetVehiclesSuccessful(router: MockPorscheConnectServer.shared.router)
    loginToPorscheConnect()
  }
    
  func testAppLoginFailed() {
    loginToPorscheConnect(successfully: false)
  }

}
