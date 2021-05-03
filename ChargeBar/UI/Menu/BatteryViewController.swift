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
    vehicleMO = findSelectedVehicle()
    prepareBatteryViewForDisplay()
  }
  
  // MARK: - UI
  
  fileprivate func prepareBatteryViewForDisplay() {
    guard let vehicleMO = vehicleMO,
          let licensePlate = vehicleMO.licensePlate else { return }
    
    licensePlateTextField.stringValue = licensePlate
    
    guard let emobilityMO = vehicleMO.emobility else { return }
    
    updateBattery(percentage: emobilityMO.stateOfChargeInPercentage)
  }

  // MARK: - Private functions
  
  fileprivate func updateBattery(percentage: Int32) {
    currentChargePercentageTextField.stringValue = "\(percentage)%"
    batteryLevelIndicator.intValue = percentage
  }
}
