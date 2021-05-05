//
//  UIToolbar++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 11/10/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation
import UIKit

public extension UIToolbar {
    
    class func toolbar(with target: Any, cancelSelector: Selector?, doneSelector: Selector) -> UIToolbar {
        let keyboardToolBar = UIToolbar()
        keyboardToolBar.barStyle  = .black
        keyboardToolBar.isTranslucent = true
        keyboardToolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: target, action: doneSelector)
        
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        if let cancelSelector = cancelSelector {
            let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: target, action: cancelSelector)
            keyboardToolBar.items = [spacer, spacer, cancelButton, doneButton]
        } else {
            keyboardToolBar.items = [spacer, spacer, spacer, doneButton]
        }
        return keyboardToolBar
    }
}
