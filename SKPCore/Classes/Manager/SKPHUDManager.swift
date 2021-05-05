//
//  SKPHUDManager.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/15/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation
import KRProgressHUD

public class SKPHUDManager {
    public typealias SKPProgressStyle = KRProgressHUDStyle
    public typealias SKPProgressMaskType = KRProgressHUDMaskType
    public typealias SKPProgressIndicatorColor = [UIColor]
    
    public class SKPHUDAppearance {
        public var style: SKPProgressStyle = .white
        public var maskType: SKPProgressMaskType = .clear
        public var indicatorColors: SKPProgressIndicatorColor = [.black, .lightGray]
    }
    
    public static let shared: SKPHUDManager = SKPHUDManager()
    
    public static let appearance = SKPHUDAppearance()
    
    private func applyStyle() {
        KRProgressHUD.appearance().style = SKPHUDManager.appearance.style
        KRProgressHUD.appearance().maskType = SKPHUDManager.appearance.maskType
        KRProgressHUD.appearance().activityIndicatorColors = SKPHUDManager.appearance.indicatorColors
        KRProgressHUD.appearance().duration = 0
    }
    
    public func show() {
        applyStyle()
        KRProgressHUD.show()
    }
    
    public func dismiss(_ completion: (() -> Void)? = nil) {
        applyStyle()
        KRProgressHUD.dismiss(completion)
    }
}
