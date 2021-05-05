//
//  KeyboardHandler.swift
//  Base Utils
//
//  Edit by Dat Ng on 2/23/18.
//  Copyright © 2020 datnm. All rights reserved.
//
#if os(iOS) || os(tvOS)
import Foundation
import UIKit

public typealias LHKeyboardHandlerCallback = (LHKeyboardHandler, LHKeyboardInfo) -> Void

/// Responsible for observing `UIKeyboard` notifications and calling `delegate` to notify about changes.
open class LHKeyboardHandler {
    public static let shared: LHKeyboardHandler = LHKeyboardHandler()
    /// The delegate for keyboard notifications.
    open var callback: LHKeyboardHandlerCallback?

    /// Creates a new instance of `KeyboardHandler` and adds itself as observer for `UIKeyboard` notifications.
    public init() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidShowNotification), name: UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillChangeNotification), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidChangedNotification), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardDidHideNotification), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func keyboardWillShowNotification(_ notification: Notification) {
        let info = LHKeyboardInfo(info: notification.userInfo, state: .willShow)
        callback?(self, info)
    }

    @objc private func keyboardDidShowNotification(_ notification: Notification) {
        let info = LHKeyboardInfo(info: notification.userInfo, state: .visible)
        callback?(self, info)
    }

    @objc private func keyboardWillChangeNotification(_ notification: Notification) {
        let info = LHKeyboardInfo(info: notification.userInfo, state: .willChangeFrame)
        callback?(self, info)
    }

    @objc private func keyboardDidChangedNotification(_ notification: Notification) {
        let info = LHKeyboardInfo(info: notification.userInfo, state: .didChangedFrame)
        callback?(self, info)
    }

    @objc private func keyboardWillHideNotification(_ notification: Notification) {
        let info = LHKeyboardInfo(info: notification.userInfo, state: .willHide)
        callback?(self, info)
    }

    @objc private func keyboardDidHideNotification(_ notification: Notification) {
        let info = LHKeyboardInfo(info: notification.userInfo, state: .hidden)
        callback?(self, info)
    }
}

/// Represents the keyboard state.
public enum LHKeyboardState {

    /// Denotes hidden state of the keyboard.
    /// Corresponds to `UIKeyboardDidHideNotification`.
    case hidden

    /// Denotes state when the keyboard about to show.
    /// Corresponds to `UIKeyboardWillShowNotification`.
    case willShow

    case willChangeFrame
    case didChangedFrame

    /// Denotes visible state of the keyboard.
    /// Corresponds to `UIKeyboardDidShowNotification`.
    case visible

    /// Denotes state when the keyboard about to hide.
    /// Corresponds to `UIKeyboardWillHideNotification`.
    case willHide
}

/// Represents info about keyboard extracted from `NSNotification`.
public struct LHKeyboardInfo {

    /// The state of the keyboard.
    public let state: LHKeyboardState

    /// The start frame of the keyboard in screen coordinates.
    /// Corresponds to `UIKeyboardFrameBeginUserInfoKey`.
    public let beginFrame: CGRect

    /// The end frame of the keyboard in screen coordinates.
    /// Corresponds to `UIKeyboardFrameEndUserInfoKey`.
    public let endFrame: CGRect

    public let visibleHeight: CGFloat
    public let isHidden: Bool

    /// Defines how the keyboard will be animated onto or off the screen.
    /// Corresponds to `UIKeyboardAnimationCurveUserInfoKey`.
    public let animationCurve: UIView.AnimationCurve

    /// The duration of the animation in seconds.
    /// Corresponds to `UIKeyboardAnimationDurationUserInfoKey`.
    public let animationDuration: TimeInterval

    /// Options for animating constructed from `animationCurve` property.
    public var animationOptions: UIView.AnimationOptions {
        switch animationCurve {
        case .easeInOut: return UIView.AnimationOptions.curveEaseInOut
        case .easeIn: return UIView.AnimationOptions.curveEaseIn
        case .easeOut: return UIView.AnimationOptions.curveEaseOut
        case .linear: return UIView.AnimationOptions.curveLinear
        default:
            return UIView.AnimationOptions.curveLinear
        }
    }
}

public extension LHKeyboardInfo {
    /// Creates instance of `KeyboardInfo` using `userInfo` from `NSNotification` object and a keyboard state.
    /// If there is no info or `info` doesn't contain appropriate key-value pair uses default values.
    init(info: [AnyHashable: Any]?, state: LHKeyboardState) {
        self.state = state
        self.beginFrame = (info?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        let kEndFrame = (info?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        self.endFrame = kEndFrame
        let kVisibleHeight = UIScreen.main.bounds.height - kEndFrame.origin.y
        self.visibleHeight = kVisibleHeight
        self.isHidden = state == .hidden || state == .willHide || kVisibleHeight <= 0.0

        let animationCurveRaw = info?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int ?? 0
        if animationCurveRaw == 7 {
            self.animationCurve = .easeInOut
        } else {
            self.animationCurve = UIView.AnimationCurve(rawValue: animationCurveRaw) ?? .easeInOut
        }
        self.animationDuration = TimeInterval(info?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.0)
    }
}

#endif
