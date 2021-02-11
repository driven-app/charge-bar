//
//  PreferencesController.swift
//  ChargeBar
//
//  Created by Damien Glancy on 09/02/2021.
//

import Cocoa
import PorscheConnect

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

class PreferencesViewController: NSViewController, LoginSheetDelegate {
  
  // MARK: - Properties
  
  @IBOutlet var loginSheetWindow: LoginSheetWindow!
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loginSheetWindow.loginDelegate = self
  }
  
  // MARK: - Actions
  
  @IBAction func loginLogoutBtnPressed(_ sender: Any) {
    UILogger.info("Login/Logout button pressed.")
    
    if let window = self.view.window {
      window.beginSheet(loginSheetWindow, completionHandler: nil)
    }
  }
  
  // MARK: - Login Sheet Delegate
  
  func loginSheetWantsToDismiss(username: String?, password: String?) {
    view.window?.endSheet(loginSheetWindow)
    
    guard let username = username, let password = password else {
      return
    }
    
    AppDelegate.porscheConnect = PorscheConnect(username: username, password: password)
    AppDelegate.porscheConnect!.vehicles() { result in
      print(result)
    }
  }
}

// MARK: -  Delegate Protocols

protocol LoginSheetDelegate {
  func loginSheetWantsToDismiss(username: String?, password: String?)
}

// MARK: - Station Detail Sheet Window

class LoginSheetWindow: NSWindow {
  // MARK: - Properties
  
  var loginDelegate: LoginSheetDelegate?
  
  @IBOutlet weak var usernameTextField: NSTextField!
  @IBOutlet weak var passwordTextField: NSSecureTextField!
  
  // MARK: - Actions
  
  @IBAction func okayBtnPressed(_ sender: Any) {
    UILogger.info("Ok button pressed on login detail sheet.")
    
    if usernameTextField.stringValue.isEmpty || passwordTextField.stringValue.isEmpty {
      return
    }
    
    dismissSheet(username: usernameTextField.stringValue, password: passwordTextField.stringValue)
  }
  
  @IBAction func cancelBtnPressed(_ sender: Any) {
    UILogger.info("Cancel button pressed on login detail sheet.")
    
    dismissSheet()
  }
  
  // MARK: - Private
  
  private func dismissSheet(username: String? = nil, password: String? = nil) {
    loginDelegate?.loginSheetWantsToDismiss(username: username, password: password)
  }
}
