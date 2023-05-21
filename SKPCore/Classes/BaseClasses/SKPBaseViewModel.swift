//
//  SKPBaseViewModel.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/14/20.
//  Copyright © 2020 Tran Tung Lam. All rights reserved.
//

import Foundation
import NSObject_Rx

open class SKPBaseViewModel<T: AnyObject>: NSObject, HasDisposeBag where T: SKPPresenter {
    public weak var presenter: T?
    
    public init(with presenter: T) {
        self.presenter = presenter
    }
    
    public override init() {}
}
