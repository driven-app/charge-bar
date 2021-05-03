//
//  Constants.swift
//  ChargeBar
//
//  Created by Damien Glancy on 09/02/2021.
//

import Foundation
import os.log

// MARK: - App

let kAppBundleId = "eu.drivenapp.chargebar"
let kBlankString = ""

// MARK: - Keychain

let kPasswordKeyForKeychain = "Porsche Connect Password"

// MARK: - Logging

let LifecycleLogger = Logger(subsystem: kAppBundleId, category: "Lifecycle")
let UILogger = Logger(subsystem: kAppBundleId, category: "UI")
let ServiceLogger = Logger(subsystem: kAppBundleId, category: "Service")
let CoreDataLogger = Logger(subsystem: kAppBundleId, category: "CoreData")

// MARK: - Debugging Aid

func doNothing() {
  LifecycleLogger.info("Do Nothing() - remove this")
}
