//
//  CGPoint++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 14/04/2022.
//

import Foundation

public extension CGPoint {

    enum CoordinateSide {
        case topLeft, top, topRight, right, bottomRight, bottom, bottomLeft, left
    }

    static func unitCoordinate(_ side: CoordinateSide) -> CGPoint {
        switch side {
        case .topLeft:      return CGPoint(x: 0.0, y: 0.0)
        case .top:          return CGPoint(x: 0.5, y: 0.0)
        case .topRight:     return CGPoint(x: 1.0, y: 0.0)
        case .right:        return CGPoint(x: 0.0, y: 0.5)
        case .bottomRight:  return CGPoint(x: 1.0, y: 1.0)
        case .bottom:       return CGPoint(x: 0.5, y: 1.0)
        case .bottomLeft:   return CGPoint(x: 0.0, y: 1.0)
        case .left:         return CGPoint(x: 1.0, y: 0.5)
        }
    }
}
