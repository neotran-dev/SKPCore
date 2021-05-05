//
//  Data++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 11/18/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation

public extension Data {
    var nsData: NSData {
        return self as NSData
    }
}

public extension NSData {
    var data: Data {
        return self as Data
    }
}
