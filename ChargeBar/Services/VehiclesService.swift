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
  
  let porscheConnect: PorscheConnect
  let accountMO: AccountMO
  
  // MARK: - Public
  
  func sync(completion: @escaping (Result<(), Error>) -> Void) {
    guard let viewContext = accountMO.managedObjectContext else { return }
    
    porscheConnect.vehicles() { result in
      switch result {
      case .success(let (vehicles, _)):
        handleVehicles(vehicles: vehicles, context: viewContext)
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
        break
      }
    }
  }
  
  // MARK: - Private
  
  private func handleVehicles(vehicles: [Vehicle]?, context: NSManagedObjectContext) {
    guard let vehicles = vehicles else { return }
    
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
    }
    
    context.saveOrRollback()
  }
}
