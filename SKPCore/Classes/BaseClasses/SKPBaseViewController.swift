//
//  SKPBaseViewController.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/14/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import UIKit
import NSObject_Rx
import SnapKit
import AppTrackingTransparency
import AdSupport

public protocol SKPPresenter {
    
}

open class SKPBaseView: UIView, SKPPresenter, HasDisposeBag {
    
}

open class SKPBaseViewController: UIViewController, SKPPresenter, HasDisposeBag {
    
}
