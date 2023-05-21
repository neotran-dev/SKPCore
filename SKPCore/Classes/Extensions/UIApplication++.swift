//
//  UIApplication++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/22/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation
import UIKit
public extension UIApplication {
    class var hasTopNotch: Bool {
        if #available(iOS 11.0, tvOS 11.0, *) {
            // with notch: 44.0 on iPhone X, XS, XS Max, XR.
            // without notch: 24.0 on iPad Pro 12.9" 3rd generation, 20.0 on iPhone 8 on iOS 12+.
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 24
        }
        return false
    }
    
    class var safeAreaTopInset: CGFloat {
        if #available(iOS 11.0, tvOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0
        }
        return 0
    }
    
    /// Trả về keyWindow tương thích iOS 12 và iOS 13+
    var keyWindowCompatible: UIWindow? {
        if #available(iOS 13.0, *) {
            return self.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .flatMap { $0.windows }
                .first { $0.isKeyWindow }
        } else {
            return self.keyWindow
        }
    }
}
