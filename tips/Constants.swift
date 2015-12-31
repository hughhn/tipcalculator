//
//  Constants.swift
//  tips
//
//  Created by Hieu Nguyen on 12/29/15.
//  Copyright © 2015 codepath. All rights reserved.
//

import Foundation

struct AppConfig {
    static let tipPercentages = [0.15, 0.18, 0.2]
    static let maxCacheTime = 600
}

struct AppEvents {
    static let appEnterBackgroundEvent = "appEnterBackgroundEvent"
}

struct AppKeys {
    static let tipIndexKey = "tipIndexKey"
    static let lastTipDateKey = "lastTipDateKey"
    static let lastBillAmountKey = "lastBillAmountKey"
}


