//
//  BatteryViewController.swift
//  ChargeBar
//
//  Created by Damien Glancy on 01/05/2021.
//

import Foundation
import Cocoa

final class BatteryViewController: NSViewController {
  
  // MARK: - Properties
  
  var vehicleMO: VehicleMO?
  
  @IBOutlet weak var licensePlateTextField: NSTextField!
  @IBOutlet weak var currentChargePercentageTextField: NSTextField!
  
  // MARK: - Lifecycle
  
  override func viewWillAppear() {
    super.viewWillAppear()
    vehicleMO = findSelectedVehicle()
    prepareBatteryViewForDisplay()
  }
  
  // MARK: - UI
  
  fileprivate func prepareBatteryViewForDisplay() {
    guard let vehicleMO = vehicleMO,
          let licensePlate = vehicleMO.licensePlate else { return }
    
    licensePlateTextField.stringValue = licensePlate
  }

  // MARK: - Private functions
  
  fileprivate func findSelectedVehicle() -> VehicleMO? {
    guard let fetchRequest = AppDelegate.persistenceManager.container.managedObjectModel.fetchRequestTemplate(forName: "FetchSelectedVehicle") else { return nil }
    
    do {
      let results = try AppDelegate.persistenceManager.container.viewContext.fetch(fetchRequest)
      return results.first as! VehicleMO?
    } catch {
      CoreDataLogger.error("Error running FetchSelectedVehicle fetch request template.)")
      return nil
    }
  }
  
}
