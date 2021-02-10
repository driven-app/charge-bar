//
//  Constants.swift
//  ChargeBar
//
//  Created by Damien Glancy on 09/02/2021.
//

import Foundation
import os.log

let kAppBundleId = "eu.drivenapp.chargebar"
let kBlankString = ""

// MARK: - Logging

let LifecycleLoger = Logger(subsystem: kAppBundleId, category: "Lifecycle")
let CoreDataLoger = Logger(subsystem: kAppBundleId, category: "CoreData")
let UILoger = Logger(subsystem: kAppBundleId, category: "UI")
