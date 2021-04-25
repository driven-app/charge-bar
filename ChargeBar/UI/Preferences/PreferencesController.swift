//
//  PreferencesController.swift
//  ChargeBar
//
//  Created by Damien Glancy on 09/02/2021.
//

import Cocoa
import PorscheConnect
import KeychainSwift

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
  
  @IBOutlet var accountStatusTextField: NSTextField!
  @IBOutlet var progressIndicator: NSProgressIndicator!
  @IBOutlet var loginLogoutBtn: NSButton!
  @IBOutlet var vehiclesTableView: NSTableView!
  @IBOutlet var loginSheetWindow: LoginSheetWindow!
  
  var vehicles: [Vehicle] = []
  
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
    
    accountStatusTextField.isHidden = true
    progressIndicator.startAnimation(nil)
    
    AppDelegate.porscheConnect = PorscheConnect(username: username, password: password)
    AppDelegate.porscheConnect!.vehicles() { result in
      DispatchQueue.main.async {
        switch result {
        case .success(let (vehicles, _)):
          self.handleLoginSuccess(username: username, password: password, vehicles: vehicles)
        case .failure(_):
          self.handleLoginFailure()
        }
        
        self.progressIndicator.stopAnimation(nil)
        self.accountStatusTextField.isHidden = false
      }
    }
  }
  
  // MARK: - Private Functions
  
  private func handleLoginSuccess(username: String, password: String, vehicles: [Vehicle]?) {
    let keychain = KeychainSwift()
    keychain.set(username, forKey: kUsernameKeyForKeychain)
    keychain.set(password, forKey: kPasswordKeyForKeychain)
    
    if let vehicles = vehicles {
      self.vehicles = vehicles
    }
    
    accountStatusTextField.textColor = .systemGreen
    accountStatusTextField.stringValue = NSLocalizedString("Connected", comment: kBlankString)
    loginLogoutBtn.title = NSLocalizedString("Logout", comment: kBlankString)
    
    vehiclesTableView.reloadData()
  }
  
  private func handleLoginFailure() {
    accountStatusTextField.textColor = .systemRed
    accountStatusTextField.stringValue = NSLocalizedString("Not Connected", comment: kBlankString)
  }
}

// MARK: - Table View Delegate & Datasource

extension PreferencesViewController: NSTableViewDataSource, NSTableViewDelegate  {
  func numberOfRows(in tableView: NSTableView) -> Int {
    return vehicles.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let vehicle = vehicles[row]
    
    guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
    
    switch tableColumn?.identifier.rawValue {
    case "Name":
      cell.textField?.stringValue = vehicle.modelDescription
    case "Model":
      cell.textField?.stringValue = vehicle.modelType
    case "Year":
      cell.textField?.stringValue = vehicle.modelYear
    default:
      cell.textField?.stringValue = vehicle.vin
    }
    
    return cell
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
