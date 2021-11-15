//
//  SKPPopupManager.swift
//  SKPCore
//
//  Created by Tran Tung Lam on 10/16/20.
//  Copyright © 2020 Sketch App Studio. All rights reserved.
//

import Foundation
import UIKit
import SwiftEntryKit

public extension UIEdgeInsets {
    static var safeAreaInset: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.rootViewController?.view.safeAreaInsets ?? .zero
        } else {
            let statusBarMaxY = UIApplication.shared.statusBarFrame.maxY
            return UIEdgeInsets(top: statusBarMaxY, left: 0, bottom: 10, right: 0)
        }
    }
}

public extension CGFloat {
    
    var multipleByDevice: CGFloat {
        return self * UIDevice.width / 320
    }
    
    var subtractVerticalInset: CGFloat {
        return self - UIEdgeInsets.safeAreaInset.top - UIEdgeInsets.safeAreaInset.bottom
    }
}

public class SKPPopupManager {
    
    public typealias SKPPopupActionHandler = ((_ alert: UIAlertController, _ action: SKPPopupAction) -> Void)
    
    public enum SKPPopupAction {
        case cancel
        case ok
        case other(index: Int, value: String)
    }
    
    public static let shared = SKPPopupManager()
    
    // MARK: Alert
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
    
    // MARK: SwiftEntryKit Popup
    public static var dimColor = UIColor.black.withAlphaComponent(0.7)
    public static var popupAnimationDuration: TimeInterval = 0.3
    public static var popupOutsideSpace: CGFloat = 10
    public static var cornerRadius: CGFloat = 10
    
    public static var defaultAttributes: EKAttributes {
        var attributes = EKAttributes.centerFloat
        attributes.windowLevel = .normal
        attributes.screenBackground = .color(color: EKColor(dimColor))
        attributes.entranceAnimation = .init(translate: .init(duration: 0.7, anchorPosition: .top, spring: .init(damping: 1, initialVelocity: 0)), fade: .init(from: 0.8, to: 1, duration: 0.3))
        
        attributes.exitAnimation = .init(translate: .init(duration: 0.7, anchorPosition: .automatic, spring: .init(damping: 1, initialVelocity: 0)),
                                         fade: .init(from: 1, to: 0, duration: popupAnimationDuration))
        
        attributes.popBehavior = .animated(animation: .init(fade: .init(from: 1, to: 0, duration: popupAnimationDuration)))
        
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .easeOut)
        attributes.displayDuration = .infinity
        attributes.screenInteraction = .dismiss
        attributes.entryInteraction = .absorbTouches
        attributes.statusBar = .light
        attributes.precedence = .enqueue(priority: .normal)
        attributes.positionConstraints.size = .init(width: .offset(value: 20), height: .intrinsic)
        // Give the entry maximum width of the screen minimum edge - thus the entry won't grow much when the device orientation changes from portrait to landscape mode.
        let edgeWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: edgeWidth), height: .intrinsic)
        return attributes
    }
    
    public func presentPopup(with viewController: UIViewController,
                                           entryName: String? = nil,
                                           ekAttributes: EKAttributes = SKPPopupManager.defaultAttributes,
                                           insideKeyWindow: Bool = true,
                                           rollbackWindow: SwiftEntryKit.RollbackWindow = .main, isDropCurrentEntry: Bool = false) {
        UIApplication.dismissKeyboard()
        var customAttributes = ekAttributes
        customAttributes.name = entryName
        customAttributes.precedence = .override(priority: .normal, dropEnqueuedEntries: isDropCurrentEntry)
        viewController.view.cornerRadius = SKPPopupManager.cornerRadius
        SwiftEntryKit.display(entry: viewController, using: customAttributes, presentInsideKeyWindow: insideKeyWindow, rollbackWindow: rollbackWindow)
    }
    
    public func dismissPopup(_ completion: (() -> Void)? = nil) {
        SwiftEntryKit.dismiss {
            completion?()
        }
    }
}
