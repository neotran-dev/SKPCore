//
//  SKPHUDManager.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/15/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation
import KRProgressHUD

/// Pluggable HUD presenter. Apps can inject a custom visual while keeping
/// `SKPHUDManager.show/dismiss` call sites unchanged.
public protocol SKPHUDPresenting: AnyObject {
    func show()
    func dismiss(_ completion: (() -> Void)?)
}

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

    /// When set, `show`/`dismiss` route here instead of `KRProgressHUD`.
    public var presenter: SKPHUDPresenting?
    
    public func show() {
        DispatchQueue.mainAsync { [weak self] in
            guard let self else { return }
            if let presenter = self.presenter {
                presenter.show()
            } else {
                KRProgressHUD.show()
            }
        }
    }
    
    public func dismiss(_ completion: (() -> Void)? = nil) {
        DispatchQueue.mainAsync { [weak self] in
            guard let self else { return }
            if let presenter = self.presenter {
                presenter.dismiss(completion)
            } else {
                KRProgressHUD.dismiss(completion)
            }
        }
    }
}
