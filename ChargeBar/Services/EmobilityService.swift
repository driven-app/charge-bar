//
//  EmobilityService.swift
//  ChargeBar
//
//  Created by Damien Glancy on 01/05/2021.
//

import Foundation
import CoreData
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
    
    ServiceLogger.info("Emobility sync: Starting.")
    
    porscheConnect.emobility(vehicle: vehicle, capabilities: capabilities) { result in
      switch result {
      case .success(let (emobility, _)):
        handleEmobility(emobility: emobility, context: viewContext)
        ServiceLogger.info("Emobility sync: Completed successfully.")
        completion(.success(()))
      case .failure(let error):
        ServiceLogger.info("Emobility sync: Completed with failure.")
        completion(.failure(error))
      }
    }
  }
  
  // MARK: - Private functions

  func handleEmobility(emobility: Emobility?, context: NSManagedObjectContext) {
    guard let emobility = emobility else { return }
    
    let emobilityMO = EmobilityMO(context: context)
    emobilityMO.syncDate = Date()
    emobilityMO.chargingInDCMode = emobility.batteryChargeStatus.chargingInDCMode
    emobilityMO.chargingMode = emobility.batteryChargeStatus.chargingMode
    emobilityMO.chargingPower = emobility.batteryChargeStatus.chargingPower
    emobilityMO.chargingState = emobility.batteryChargeStatus.chargingState
    emobilityMO.directCharge = emobility.directCharge.isActive
    emobilityMO.ledColor = emobility.batteryChargeStatus.ledColor
    emobilityMO.ledState = emobility.batteryChargeStatus.ledState
    emobilityMO.lockState = emobility.batteryChargeStatus.lockState
    emobilityMO.plugState = emobility.batteryChargeStatus.plugState
    emobilityMO.remainingERange = Int32(emobility.batteryChargeStatus.remainingERange.value)
    emobilityMO.remainingERangeUnit = emobility.batteryChargeStatus.remainingERange.unit
    emobilityMO.stateOfChargeInPercentage = Int32(emobility.batteryChargeStatus.stateOfChargeInPercentage)
    
    vehicleMO.emobility = emobilityMO
    
    context.saveOrRollback()
  }
  
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
