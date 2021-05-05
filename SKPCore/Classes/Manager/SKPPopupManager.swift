//
//  SKPPopupManager.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/16/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation
import UIKit

public class SKPPopupManager {
    
    public typealias SKPPopupActionHandler = ((_ alert: UIAlertController, _ action: SKPPopupAction) -> Void)
    
    public enum SKPPopupAction {
        case cancel
        case ok
        case other(index: Int, value: String)
    }
    
    public static let shared = SKPPopupManager()
    
    public func showAlert(withTitle title: String? = nil,
                          message: String? = nil,
                          okButtonTitle: String? = nil,
                          cancelButtonTitle: String? = nil,
                          otherButtonTitles: [String] = [],
                          on viewController: UIViewController? = nil,
                          buttonActionHandler: SKPPopupActionHandler? = nil,
                          completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        for (index, value) in otherButtonTitles.enumerated() {
            let action = UIAlertAction(title: value, style: .default) { _ in
                buttonActionHandler?(alert, .other(index: index, value: value)) }
            alert.addAction(action)
        }
        
        if let cancelTitle = cancelButtonTitle {
            let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel) { _ in  buttonActionHandler?(alert, .cancel) }
            alert.addAction(cancelAction)
        }
        if let okTitle = okButtonTitle {
           let okAction = UIAlertAction(title: okTitle, style: .default) { _ in
            buttonActionHandler?(alert, .ok) }
            alert.addAction(okAction)
        }
        
        if alert.actions.count == 0 { alert.addAction(UIAlertAction(title: "OK", style: .default)) }
       
        guard let vc = viewController else {
            UIApplication.shared.keyWindow?.rootViewController?.topMostViewController.present(alert, animated: true, completion: completion)
            return
        }
        vc.present(alert, animated: true, completion: completion)
    }
    
    public func showErrorAlert(withMessage message: String, actionHandler: (() -> Void)? = nil) {
        showAlert(withTitle: "Error", message: message, buttonActionHandler: { (alert, _) in
            actionHandler?()
            alert.dismiss(animated: true, completion: nil)
        })
    }
    
    public func showActionSheet(withTitle title: String? = nil,
                                message: String? = nil,
                                destructButtonTitle: String = "Cancel",
                                otherButtonTitles: [String] = [],
                                on viewController: UIViewController? = nil,
                                sourceView view: UIView? = nil,
                                sourceRect rect: CGRect? = nil,
                                buttonActionHandler: SKPPopupActionHandler? = nil,
                                completion: (() -> Void)? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for (index, value) in otherButtonTitles.enumerated() {
            let action = UIAlertAction(title: value, style: .default) { _ in
                buttonActionHandler?(alert, .other(index: index, value: value))
            }
            alert.addAction(action)
        }
        
        let desctructAction = UIAlertAction(title: destructButtonTitle, style: .destructive) { _ in buttonActionHandler?(alert, .cancel) }
        alert.addAction(desctructAction)
        
        guard let vc = viewController else {
            UIApplication.shared.keyWindow?.rootViewController?.topMostViewController.present(alert, animated: true, completion: completion)
            return
        }
        if let popOver = alert.popoverPresentationController,
           let sourceView = view,
           let sourceRect = rect {
            popOver.sourceView = sourceView
            popOver.sourceRect = sourceRect
        }
        vc.present(alert, animated: true, completion: completion)
    }
}
