//
//  Bundle+Ex.swift
//  LHCoreExtensions iOS
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

import Foundation

public extension Bundle {
    static func stringValue(_ key: String) -> String? {
        return Bundle.main.infoDictionary?[key] as? String
    }
    
    static var shortVersion: String {
        stringValue("CFBundleShortVersionString") ?? ""
    }
}
