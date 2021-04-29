//
//  AppDelegate.swift
//  ChargeBar
//
//  Created by Damien Glancy on 09/02/2021.
//

import Cocoa
import PorscheConnect

@main
class AppDelegate: NSObject, NSApplicationDelegate {

  // MARK: - Properties
  
  static var porscheConnect: PorscheConnect?
  static let persistenceManager = PersistenceManager.shared
  
  // MARK: - Static methods
  
  static func isRunningInTestMode() -> Bool {
    return ProcessInfo.processInfo.environment["TEST_MODE"] != nil
  }
}
