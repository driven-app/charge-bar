//
//  EmobilityService.swift
//  ChargeBar
//
//  Created by Damien Glancy on 01/05/2021.
//

import Foundation
import PorscheConnect

struct EmobilityService {
  
  // MARK: - Properties
  
  let porscheConnect: PorscheConnect
  let vehicleMO: VehicleMO
  
  // MARK: - Public
  
  func sync(completion: @escaping (Result<(), Error>) -> Void) {
    guard let viewContext = vehicleMO.managedObjectContext,
          let vehicle = buildVehicleStruct(),
          let capabilities = buidCapabilitiesStruct()
    else { return }
    
    porscheConnect.emobility(vehicle: vehicle, capabilities: capabilities) { result in
      switch result {
      case .success(let (emobility, _)):
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
  
  // MARK: - Private functions
  
  func buildVehicleStruct() -> Vehicle? {
    guard let vin = vehicleMO.vin,
          let modelDescription = vehicleMO.modelDescription,
          let modelType = vehicleMO.modelType,
          let modelYear = vehicleMO.modelYear
    else { return nil }
    
    return Vehicle(vin: vin,
                   modelDescription: modelDescription,
                   modelType: modelType,
                   modelYear: modelYear)
  }
  
  func buidCapabilitiesStruct() -> Capabilities? {
    guard let capabilities = vehicleMO.capabilities,
          let carModel = capabilities.carModel,
          let engineType = capabilities.engineType
    else { return nil }
    
    return Capabilities(engineType: engineType, carModel: carModel)
  }
}
