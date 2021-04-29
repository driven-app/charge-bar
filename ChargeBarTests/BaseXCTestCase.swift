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
}
