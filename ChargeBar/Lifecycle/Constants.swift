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

let kUsernameKeyForKeychain = "Porsche Connect Username"
let kPasswordKeyForKeychain = "Porsche Connect Password"

// MARK: - Logging

let LifecycleLogger = Logger(subsystem: kAppBundleId, category: "Lifecycle")
let UILogger = Logger(subsystem: kAppBundleId, category: "UI")
