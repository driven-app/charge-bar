//
//  MenuController.swift
//  ChargeBar
//
//  Created by Damien Glancy on 09/02/2021.
//

import Foundation
import Cocoa

final class MenuController: NSObject, NSMenuDelegate {
  
  // MARK: - Properties
  
  @IBOutlet weak var menu: NSMenu!
  
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

  // MARK: - Lifecycle
  
  override func awakeFromNib() {
    super.awakeFromNib()
    setupMenuUI()
  }
  
  
  // MARK: - UI
  
  private func setupMenuUI() {
    if let button = statusItem.button {
      button.image = NSImage(systemSymbolName: "bolt.car", accessibilityDescription: "")
    }
    
    statusItem.isVisible = true
    statusItem.behavior = .terminationOnRemoval
    statusItem.autosaveName = kAppBundleId
    statusItem.menu = menu
  }
  
  // MARK: - Actions
  
  @IBAction func quitBtnPressed(_ sender: Any) {
    UILoger.info("Quit menu item pressed.")
    NSApp.terminate(sender)
  }
}
