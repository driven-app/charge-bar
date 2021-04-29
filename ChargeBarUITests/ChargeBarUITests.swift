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
    menuBarsQuery!.menuItems["Preferences..."].click()
    app.windows["ChargeBar Preferences"].buttons[XCUIIdentifierCloseWindow].click()
  }
  
  func testAppStartsLoggedOutInTestMode() {
    menuBarsQuery!.menuItems["Preferences..."].click()
    
    let preferencesWindow = app.windows["ChargeBar Preferences"]
    XCTAssertEqual("Not Connected", preferencesWindow.staticTexts["AccountStatusTextField"].value as! String)
    XCTAssertEqual("Login ...", preferencesWindow.buttons["LoginLogoutBtn"].title)
    
    let table = preferencesWindow.tables["VehiclesTable"]
    XCTAssertNotNil(table)
    XCTAssertEqual(3, table.tableColumns.count)
    XCTAssertNotNil(table.tableColumns["Name"])
    XCTAssertNotNil(table.tableColumns["License Plate"])
    XCTAssertNotNil(table.tableColumns["VIN"])
    XCTAssertEqual(0, table.tableRows.count)
  }
}
