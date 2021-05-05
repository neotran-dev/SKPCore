//
//  SKPBaseViewModel.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/14/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation
import NSObject_Rx

open class SKPBaseViewModel<T>: NSObject, HasDisposeBag where T: SKPPresenter {
    public var presenter: T?
    
    public init(with presenter: T) {
        self.presenter = presenter
    }
    
    public override init() {}
}
