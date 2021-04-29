//
//  MenuController.swift
//  ChargeBar
//
//  Created by Damien Glancy on 09/02/2021.
//

import Foundation
import Cocoa
import KeychainSwift
import PorscheConnect

final class MenuController: NSObject, NSMenuDelegate {
  
  // MARK: - Properties
  
  @IBOutlet weak var menu: NSMenu!
  
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

  lazy var preferencesWindowController: PreferencesWindowController = {
    return NSStoryboard(name: "Preferences", bundle: nil).instantiateController(withIdentifier: "PreferencesWindowController") as! PreferencesWindowController
  }()
  
  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    preventMultipleAppsFromRunning()
    setupMenuUI()
    
    guard ProcessInfo.processInfo.environment["TEST_MODE"] == nil else {
      runInTestMode()
      return
    }
    
//    initPorscheConnect()
    
    LifecycleLogger.info("Launched.")
  }
  
  // MARK: - Startup
  
  private func setupMenuUI() {
    if let button = statusItem.button {
      button.image = NSImage(systemSymbolName: "bolt.car", accessibilityDescription: kBlankString)
    }
    
    statusItem.isVisible = true
    statusItem.behavior = .terminationOnRemoval
    statusItem.autosaveName = kAppBundleId
    statusItem.menu = menu
  }
  
  private func preventMultipleAppsFromRunning() {
    if NSRunningApplication.runningApplications(withBundleIdentifier: kAppBundleId).count > 1 {
      LifecycleLogger.error("ChargeBar is already running, terminating this instance.")
      NSApp.terminate(self)
    }
  }
  
  private func initPorscheConnect() {
    let keychain = KeychainSwift()
    guard let password = keychain.get(kPasswordKeyForKeychain),
          let accountMO = AppDelegate.persistenceManager.findFirst(entityName: AccountMO.className(), context: AppDelegate.persistenceManager.container.viewContext) as? AccountMO,
          let username = accountMO.username else { return }
    
    AppDelegate.porscheConnect = PorscheConnect(username: username, password: password)
    LifecycleLogger.info("Porsche Connect init from existing keychain")
  }
  
  // MARK: - Actions
  
  @IBAction func preferencesBtnPressed(_ sender: Any) {
    UILogger.info("Preferences menu item pressed.")
    preferencesWindowController.showWindow(sender)
    NSApp.activate(ignoringOtherApps: true)
  }
  
  @IBAction func quitBtnPressed(_ sender: Any) {
    UILogger.info("Quit menu item pressed.")
    NSApp.terminate(sender)
  }
  
  // MARK: - Test Support
  
  private func runInTestMode() {
    LifecycleLogger.info("Running in test mode.")
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: AppDelegate.persistenceManager.container.viewContext)
  }
  
}
