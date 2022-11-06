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
        
        public var style: SKPProgressStyle = .white { willSet { KRProgressHUD.appearance().style = newValue } }
        
        public var maskType: SKPProgressMaskType = .clear { willSet { KRProgressHUD.appearance().maskType = newValue } }
        
        public var indicatorColors: SKPProgressIndicatorColor = [.black, .lightGray] { willSet { KRProgressHUD.appearance().activityIndicatorColors = newValue } }
    }
    
    public static let shared: SKPHUDManager = SKPHUDManager()
    
    public static let appearance = SKPHUDAppearance()
    
    public func show() {
        DispatchQueue.mainAsync { [weak self] in
            KRProgressHUD.show()
        }
    }
    
    public func dismiss(_ completion: (() -> Void)? = nil) {
        DispatchQueue.mainAsync { [weak self] in
            KRProgressHUD.dismiss(completion)
        }
    }
}
