//
//  UITextField++.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 11/13/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

public extension Reactive where Base: UITextField {
    var textChanged: Observable<String?> {
        return Observable.merge(self.base.rx.observe(String.self, "text"),
                                self.base.rx.controlEvent(.editingChanged).withLatestFrom(self.base.rx.text))
    }
}
