//
//  VehiclesService.swift
//  ChargeBar
//
//  Created by Damien Glancy on 01/05/2021.
//

import Foundation
import CoreData
import PorscheConnect

struct VehiclesService {
  
  // MARK: - Properties
  
  let porscheConnect: PorscheConnect
  let accountMO: AccountMO
  
  // MARK: - Public
  
  func sync(completion: @escaping (Result<(), Error>) -> Void) {
    guard let viewContext = accountMO.managedObjectContext else { return }
    
    porscheConnect.vehicles() { result in
      switch result {
      case .success(let (vehicles, _)):
        DispatchQueue.global(qos: .userInitiated).async {
          handleVehicles(vehicles: vehicles, context: viewContext)
          DispatchQueue.main.async { completion(.success(())) }
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  // MARK: - Private
  
  private func handleVehicles(vehicles: [Vehicle]?, context: NSManagedObjectContext) {
    guard let existingVehicleMOs = accountMO.vehicles,
          let vehicles = vehicles else { return }
    
    accountMO.removeFromVehicles(existingVehicleMOs)
    
    vehicles.enumerated().forEach { (index, vehicle) in    
      let vehicleMO = VehicleMO(context: context)
      vehicleMO.modelDescription = vehicle.modelDescription
      vehicleMO.modelYear = vehicle.modelYear
      vehicleMO.modelType = vehicle.modelType
      vehicleMO.vin = vehicle.vin
      vehicleMO.selected = (index == 0)
      
      if let attributes = vehicle.attributes, let licensePlateAttribute = attributes.first(where: {$0.name == "licenseplate"}) {
        vehicleMO.licensePlate = licensePlateAttribute.value
      }
      
      accountMO.addToVehicles(vehicleMO)
      
      let semaphore = DispatchSemaphore(value: 0)
      handleCapabilitiesForVehicle(vehicle: vehicle, vehicleMO: vehicleMO, context: context, semaphore: semaphore)
      _ = semaphore.wait(wallTimeout: .distantFuture)
    }
    
    context.saveOrRollback()
  }
  
  private func handleCapabilitiesForVehicle(vehicle: Vehicle, vehicleMO: VehicleMO, context: NSManagedObjectContext, semaphore: DispatchSemaphore) {
    porscheConnect.capabilities(vehicle: vehicle) { result in
      switch result {
      case .success(let (capability, _)):
        guard let capability = capability else { break }
        
        let capabilitiesMO = CapabilitiesMO(context: context)
        capabilitiesMO.carModel = capability.carModel
        capabilitiesMO.engineType = capability.engineType
        vehicleMO.capabilities = capabilitiesMO
      case .failure(_):
        break
      }
      semaphore.signal()
    }
  }
}
