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
}
