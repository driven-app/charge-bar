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

  func testBatteryDisplayViewBeforeLogin() {
    let batteryDisplayView = findBatteryDisplayView()
    
    XCTAssertTrue(batteryDisplayView.staticTexts["LicensePlateTextField"].exists)
    XCTAssertEqual("No Vehicle", batteryDisplayView.staticTexts["LicensePlateTextField"].value as! String)
    
    XCTAssertTrue(batteryDisplayView.staticTexts["BatteryPercentageTextField"].exists)
    XCTAssertEqual("--%", batteryDisplayView.staticTexts["BatteryPercentageTextField"].value as! String)
  }
  
  func testBatteryDisplayViewAfterLogin() {
    mockNetworkRoutes.mockGetVehiclesSuccessful(router: MockPorscheConnectServer.shared.router)

    loginToPorscheConnect()
    tapMenuBar()
    
    let batteryDisplayView = findBatteryDisplayView()
    
    XCTAssertTrue(batteryDisplayView.staticTexts["LicensePlateTextField"].exists)
    XCTAssertEqual("TAY-CAN", batteryDisplayView.staticTexts["LicensePlateTextField"].value as! String)
    
    XCTAssertTrue(batteryDisplayView.staticTexts["BatteryPercentageTextField"].exists)
    XCTAssertEqual("--%", batteryDisplayView.staticTexts["BatteryPercentageTextField"].value as! String)
  }
  
  // MARK: - Private
  
  fileprivate func findBatteryDisplayView() -> XCUIElement {
    return menuBarsQuery!.menuItems.containing(.staticText, identifier: "LicensePlateTextField").element(boundBy: 0)
  }

}
