//
//  Settings.swift
//  Forte
//
//  Created by Nathan Andersen on 3/29/16.
//  Copyright © 2016 Noah Grumman. All rights reserved.
//

import Foundation


let onboardingKey = "onboardingShown"
let autoRefresh = "autoRefreshEnabled"

class Settings {
    class func groupDefaults() -> NSUserDefaults {
        return NSUserDefaults.standardUserDefaults()
    }
    class func registerDefaults() {
        let defaults = groupDefaults()
        defaults.registerDefaults(
            [onboardingKey: false,
                autoRefresh: true]
        )
    }
}