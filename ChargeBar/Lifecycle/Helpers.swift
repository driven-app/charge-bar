//
//  Helpers.swift
//  ChargeBar
//
//  Created by Damien Glancy on 03/05/2021.
//

import Foundation

// MARK: - Helper functions

func findSelectedVehicle() -> VehicleMO? {
  guard let fetchRequest = AppDelegate.persistenceManager.container.managedObjectModel.fetchRequestTemplate(forName: "FetchSelectedVehicle") else { return nil }
  
  do {
    let results = try AppDelegate.persistenceManager.container.viewContext.fetch(fetchRequest)
    return results.first as! VehicleMO?
  } catch {
    CoreDataLogger.error("Error running FetchSelectedVehicle fetch request template.)")
    return nil
  }
}
