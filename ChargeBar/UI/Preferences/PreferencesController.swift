//
//  PreferencesController.swift
//  ChargeBar
//
//  Created by Damien Glancy on 09/02/2021.
//

import Cocoa

// MARK: - Window Controller

final class PreferencesWindowController: NSWindowController {
  
  // MARK: - Lifecycle
  
  override func windowDidLoad() {
    super.windowDidLoad()
    
    if let window = self.window {
      window.center()
      window.makeKeyAndOrderFront(nil)
      window.title = NSLocalizedString("ChargeBar Preferences", comment: kBlankString)
    }
    
    NSApp.activate(ignoringOtherApps: true)
  }
}


// MARK: - View Controller

class PreferencesViewController: NSViewController {
  
  // MARK: - Lifecycle

}
