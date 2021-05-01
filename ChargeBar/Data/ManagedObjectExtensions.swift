//
//  ManagedObjectExtenstions.swift
//  ChargeBar
//
//  Created by Damien Glancy on 01/05/2021.
//

import Foundation

extension AccountMO {
  
  func markProvisioned() {
    provisioned = true
    managedObjectContext?.saveOrRollback()
  }
}
