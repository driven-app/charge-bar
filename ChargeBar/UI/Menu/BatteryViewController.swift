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
  @IBOutlet weak var batteryLevelIndicator: NSLevelIndicator!
  
  // MARK: - Lifecycle
  
  override func viewWillAppear() {
    super.viewWillAppear()
    prepareBatteryViewForDisplay()
  }
  
  // MARK: - UI
  
  fileprivate func prepareBatteryViewForDisplay() {
    guard let results = PersistenceManager.shared.findWithFetchRequestTemplate(fetchRequestTemplateName: "FetchSelectedVehicle", context: PersistenceManager.shared.container.viewContext) as? [VehicleMO],
          let vehicleMO = results.first
    else { return }
    
    if let licensePlate = vehicleMO.licensePlate {
      licensePlateTextField.stringValue = licensePlate
    }
    
    if let emobilityMO = vehicleMO.emobility {
      updateBattery(percentage: emobilityMO.stateOfChargeInPercentage)
    }
  }

  // MARK: - Private functions
  
  fileprivate func updateBattery(percentage: Int32) {
    currentChargePercentageTextField.stringValue = "\(percentage)%"
    batteryLevelIndicator.intValue = percentage
  }
}
