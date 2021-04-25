//
//  Models.swift
//  ChargeBar
//
//  Created by Damien Glancy on 25/04/2021.
//

import Foundation
import CoreData

// MARK: - 

@objc(VehicleEntity)
final class VehicleEntity: BaseManagedObject {
  
  // MARK: Properties
    
  @NSManaged var vin: String?
  @NSManaged var modelDescription: String?
  @NSManaged var modelType: String?
  @NSManaged var modelYear: String?
  @NSManaged var licensePlate: String?
}
