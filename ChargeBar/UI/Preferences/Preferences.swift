//
//  Preferences.swift
//  ChargeBar
//
//  Created by Damien Glancy on 09/02/2021.
//

import Cocoa
import CoreData
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
  @IBOutlet var vehiclesArrayController: NSArrayController!
  @IBOutlet var loginSheetWindow: LoginSheetWindow!
  
  private var isConnected: Bool { AppDelegate.porscheConnect != nil }
  
  // MARK: - Dynamic Properties
  
  @objc dynamic var viewContext: NSManagedObjectContext = PersistenceManager.shared.container.viewContext
  
  @objc private dynamic var accountStatusText: String {
    return NSLocalizedString(isConnected ? "Connected" : "Not Connected", comment: kBlankString)
  }
  
  @objc private dynamic var accountStatusTextColor: NSColor {
    return isConnected ? .systemGreen : .systemRed
  }
  
  @objc private dynamic var loginLogoutBtnText: String {
    return NSLocalizedString(isConnected ? "Logout" : "Login ...", comment: kBlankString)
  }
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loginSheetWindow.loginDelegate = self
  }
  
  // MARK: - Actions
  
  @IBAction func loginLogoutBtnPressed(_ sender: Any) {
    UILogger.info("Login/Logout button pressed.")
    
    PersistenceManager.shared.deleteAll(entityName: AccountMO.className(), context: viewContext)
    viewContext.saveOrRollback()
    
    if let window = self.view.window {
      window.beginSheet(loginSheetWindow, completionHandler: nil)
    }
  }
  
  // MARK: - Login Sheet Delegate
  
  func loginSheetWantsToDismiss(username: String?, password: String?) {
    view.window?.endSheet(loginSheetWindow)
    guard let username = username, let password = password else { return }
    
    AppDelegate.porscheConnect = PorscheConnect(username: username,
                                                password: password,
                                                environment: AppDelegate.isRunningInTestMode() ? .Test : .Germany)
    
    guard let porscheConnect = AppDelegate.porscheConnect else { return }
    
    updateUILoggingIn()
    
    porscheConnect.auth(application: .Portal) { [self] result in
      DispatchQueue.main.async {
        switch result {
        case .success(_):
          handleLoginSuccess(porscheConnect: porscheConnect, username: username, password: password)
        case .failure(_):
          handleLoginFailure()
        }
      }
    }
  }
  
  // MARK: - Private Functions
  
  private func handleLoginSuccess(porscheConnect: PorscheConnect, username: String, password: String) {
    let keychain = KeychainSwift()
    keychain.set(password, forKey: kPasswordKeyForKeychain)
    
    let accountMO = AccountMO(context: viewContext)
    accountMO.username = username
    
    VehiclesService(porscheConnect: porscheConnect, accountMO: accountMO).sync { [self] result in
      accountMO.markProvisioned()
      updateUINoLongerLoggingIn()
    }
  }
  
  private func handleLoginFailure() {
    AppDelegate.porscheConnect = nil
    updateUINoLongerLoggingIn()
    
    let alert = NSAlert()
    alert.alertStyle = .critical
    alert.messageText = NSLocalizedString("Login Error", comment: kBlankString)
    alert.informativeText = NSLocalizedString("There was an issue logging into your Porsche Connect account, please check your username and password and try again.", comment: kBlankString)
    alert.beginSheetModal(for: self.view.window!)
  }
  
  private func forceUpdateBindings() {
    ["accountStatusText", "accountStatusTextColor", "loginLogoutBtnText"].forEach { key in
      self.willChangeValue(forKey: key)
      self.didChangeValue(forKey: key)
    }
  }
  
  private func updateUILoggingIn() {
    accountStatusTextField.isHidden = true
    progressIndicator.startAnimation(nil)
    forceUpdateBindings()
  }
  
  private func updateUINoLongerLoggingIn() {
    progressIndicator.stopAnimation(nil)
    accountStatusTextField.isHidden = false
    forceUpdateBindings()
  }
}

// MARK: - Table View Delegate

extension PreferencesViewController: NSTableViewDelegate  {
  
  func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
    guard let selectedObjects = vehiclesArrayController.selectedObjects,
          let selectedVehicleMO = selectedObjects.first as? VehicleMO else { return false }
    
    return selectedVehicleMO.selected
  }
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    guard let selectedObjects = vehiclesArrayController.selectedObjects,
          let selectedVehicleMO = selectedObjects.first as? VehicleMO,
          let accountMO = PersistenceManager.shared.findFirst(entityName: AccountMO.className(), context: viewContext) as? AccountMO,
          let vehicles = accountMO.vehicles,
          accountMO.provisioned else { return }
    
    vehicles.forEach { vehicleMO in
      guard let vehicleMO = vehicleMO as? VehicleMO else { return }
      vehicleMO.selected = (vehicleMO == selectedVehicleMO)
    }
    
    viewContext.saveOrRollback()
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
    
    if usernameTextField.stringValue.isEmpty || passwordTextField.stringValue.isEmpty { return }
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
