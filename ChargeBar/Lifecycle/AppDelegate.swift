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

  static var porscheConnect: PorscheConnect?
  
  // MARK: - Lifecycle
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    preventMultipleAppsFromRunning()

  }

  // MARK: - Startup
  
  private func preventMultipleAppsFromRunning() {
    if NSRunningApplication.runningApplications(withBundleIdentifier: kAppBundleId).count > 1 {
      LifecycleLogger.error("ChargeBar is already running, terminating this instance.")
      NSApp.terminate(self)
    }
  }

}
