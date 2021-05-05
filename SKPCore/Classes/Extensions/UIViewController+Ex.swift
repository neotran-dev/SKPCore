//
//  UIViewController+Ex.swift
//  Base Extensions
//
//  Created by Dat Ng on 14/05/2020.
//  Copyright © 2020 datnm. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
#if canImport(UIKit)
    import UIKit
#endif

extension UIButton {
    func adjustMinimumSize(imageInsets: UIEdgeInsets?) {
        if let insets = imageInsets { self.imageEdgeInsets = insets }
        let offset = 50 - self.width
        guard offset > 0 else { return }
        self.width = 50
        if imageInsets == nil {
            self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (offset - 3) > 0 ? offset - 3 : offset)
        }
    }
    
    func adjustMinimumSize(titleInsets: UIEdgeInsets?) {
        if let insets = titleInsets { self.titleEdgeInsets = insets }
        let offset = 50 - self.width
        guard offset > 0 else { return }
        self.width = 50
        if titleInsets == nil {
            self.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: (offset - 3) > 0 ? offset - 3 : offset)
        }
    }
}

public extension UIViewController {
    var topBarsDistance: CGFloat {
        var mTopDistance = self.navigationController?.navigationBar.intrinsicContentSize.height ?? 0
        mTopDistance += UIApplication.shared.isStatusBarHidden ? 0 : UIApplication.shared.statusBarFrame.height

        return mTopDistance
    }

    var bottomBarsDistance: CGFloat {
        return self.tabBarController?.tabBar.intrinsicContentSize.height ?? 0
    }

    var safeAreaInsets: UIEdgeInsets {
        var _safeAreaInsets = UIDevice.safeAreaInsets
        _safeAreaInsets.top += self.navigationController?.navigationBar.intrinsicContentSize.height ?? 0
        _safeAreaInsets.bottom += self.tabBarController?.tabBar.intrinsicContentSize.height ?? 0

        return _safeAreaInsets
    }
    
    var viewSafeAreaInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return .zero
        }
    }

    var topMostViewController: UIViewController {
        if let viewController = self as? UINavigationController {
            return viewController.topViewController?.topMostViewController ?? viewController
        } else if let viewController = self as? UITabBarController {
            return viewController.selectedViewController?.topMostViewController ?? viewController
        } else if let viewController = self.presentedViewController {
            return viewController.topMostViewController
        }
        return self
    }

    var visibleMostViewController: UIViewController {
        if let viewController = self as? UINavigationController {
            return viewController.visibleViewController?.visibleMostViewController ?? self
        } else if let viewController = self as? UITabBarController {
            return viewController.selectedViewController?.visibleMostViewController ?? self
        } else if let viewController = self.presentedViewController {
            return viewController.visibleMostViewController
        }
        return self
    }
    
    var navigationItemTitle: String? {
        get { return navigationItem.title }
        set { navigationItem.title = newValue }
    }

    @discardableResult
    func setLeftBarButtonItemCustom(image: String, maskColor: UIColor? = nil, target: Any?, action: Selector, insets: UIEdgeInsets? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setImage(UIImage(named: image)?.maskColor(maskColor), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)
        button.sizeToFit()
        button.adjustMinimumSize(imageInsets: insets)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    @discardableResult
    func setLeftBarButtonItemCustom(title: String, color: UIColor? = nil, target: Any?, action: Selector, insets: UIEdgeInsets? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setTitle(title, for: .normal)
        if color != nil { button.setTitleColor(color!, for: .normal) }
        button.addTarget(target, action: action, for: .touchUpInside)
        button.sizeToFit()
        button.adjustMinimumSize(titleInsets: insets)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    @discardableResult
    func setLeftBarButtonItemCustom(image: UIImage?, maskColor: UIColor? = nil, insets: UIEdgeInsets? = nil, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setImage(image?.maskColor(maskColor), for: .normal)
        button.onClicked = { [weak self] button in
            clickedHandler?(button)
            if clickedHandler == nil {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        button.sizeToFit()
        button.adjustMinimumSize(imageInsets: insets)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    @discardableResult
    func setLeftBarButtonItemCustom(imgName: String, maskColor: UIColor? = nil, insets: UIEdgeInsets? = nil, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        return setLeftBarButtonItemCustom(image: UIImage(named: imgName), maskColor: maskColor, insets: insets, clickedHandler: clickedHandler)
    }

    @discardableResult
    func setLeftBarButtonItemCustom(title: String, color: UIColor? = nil, insets: UIEdgeInsets? = nil, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setTitle(title, for: .normal)
        if color != nil { button.setTitleColor(color!, for: .normal) }
        button.onClicked = { [weak self] button in
            clickedHandler?(button)
            if clickedHandler == nil {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        button.sizeToFit()
        button.adjustMinimumSize(titleInsets: insets)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    @discardableResult
    func setRightBarButtonItemCustom(image: String, maskColor: UIColor? = nil, insets: UIEdgeInsets? = nil, target: Any?, action: Selector) -> LHButton {
        let button = LHButton(type: .custom)
        button.setImage(UIImage(named: image)?.maskColor(maskColor), for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.sizeToFit()
        button.adjustMinimumSize(imageInsets: insets)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    @discardableResult
    func setRightBarButtonItemCustom(title: String, color: UIColor? = nil, target: Any?, action: Selector, insets: UIEdgeInsets? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setTitle(title, for: .normal)
        if color != nil { button.setTitleColor(color!, for: .normal) }
        button.addTarget(self, action: action, for: .touchUpInside)
        button.sizeToFit()
        button.adjustMinimumSize(titleInsets: insets)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    @discardableResult
    func setRightBarButtonItemCustom(image: UIImage?, maskColor: UIColor? = nil, insets: UIEdgeInsets? = nil, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setImage(image?.maskColor(maskColor), for: .normal)
        button.onClicked = clickedHandler
        button.sizeToFit()
        button.adjustMinimumSize(imageInsets: insets)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    @discardableResult
    func setRightBarButtonItemCustom(imgName: String, maskColor: UIColor? = nil, insets: UIEdgeInsets? = nil, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        return setRightBarButtonItemCustom(image: UIImage(named: imgName), maskColor: maskColor, insets: insets, clickedHandler: clickedHandler)
    }

    @discardableResult
    func setRightBarButtonItemCustom(title: String, color: UIColor? = nil, insets: UIEdgeInsets? = nil, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setTitle(title, for: .normal)
        if color != nil { button.setTitleColor(color!, for: .normal) }
        button.onClicked = clickedHandler
        button.sizeToFit()
        button.adjustMinimumSize(titleInsets: insets)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    @discardableResult
    func setBackBarButtonCustom(image: UIImage?, maskColor: UIColor? = nil, insets: UIEdgeInsets? = nil, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setImage(image?.maskColor(maskColor), for: .normal)
        button.onClicked = { [weak self] btnBlock in
            if clickedHandler == nil {
                self?.navigationController?.popViewController(animated: true)
            } else {
                clickedHandler?(btnBlock)
            }
        }

        button.sizeToFit()
        button.adjustMinimumSize(imageInsets: insets)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    @discardableResult
    func setBackBarButtonCustom(imgName: String, maskColor: UIColor? = nil, insets: UIEdgeInsets? = nil, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        return setBackBarButtonCustom(image: UIImage(named: imgName), maskColor: maskColor, insets: insets, clickedHandler: clickedHandler)
    }

    @discardableResult
    func setBackBarButtonCustom(title: String, color: UIColor? = nil, insets: UIEdgeInsets? = nil, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setTitle(title, for: .normal)
        if color != nil { button.setTitleColor(color!, for: .normal) }
        button.onClicked = { [weak self] btnBlock in
            if clickedHandler == nil {
                self?.navigationController?.popViewController(animated: true)
            } else {
                clickedHandler?(btnBlock)
            }
        }
        button.sizeToFit()
        button.adjustMinimumSize(titleInsets: insets)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }
    
    @discardableResult
    func setLeftBarButtonItemCustom(image: UIImage?, maskColor: UIColor? = nil, title: String, padding: CGFloat = 16, clickedHandler: ((LHButton) -> ())? = nil) -> LHButton {
        let button = LHButton(type: .custom)
        button.setImage(image?.maskColor(maskColor), for: .normal)
        button.setTitle(title, for: .normal)
        if let color = maskColor { button.setTitleColor(color, for: .normal) }
        
        button.onClicked = { [weak self] button in
            clickedHandler?(button)
            if clickedHandler == nil {
                self?.navigationController?.popViewController(animated: true)
            }
        }
        button.titleEdgeInsets.left = padding
        button.sizeToFit()
        button.width += padding + 2
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
        return button
    }

    func hideBackBarButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: UIView(frame: CGRect.zero))
    }

    static var classIdentifier: String {
        return String(describing: self)
    }

    // return an instance UIViewController from storyboard with class name identifier
    class func instantiate(_ storyboard: UIStoryboard) -> Self {
        return storyboard.viewController(identifier: classIdentifier)
    }
    
    class func instantiateInitial(fromStoryboard storyboardName: String? = nil, bundle bundleOrNil: Bundle? = nil) -> Self {
        let storyboardName = storyboardName ?? classIdentifier
        return UIStoryboard.initialViewController(name: storyboardName, bundle: bundleOrNil)
    }
    
    func initialViewController<T>() -> T {
        storyboard!.initialViewController()
    }

    func viewController<T: UIViewController>(identifier: String = T.classIdentifier) -> T {
        storyboard!.viewController(identifier: identifier)
    }

    func show(_ vc: UIViewController?) {
        guard let vc = vc else { return }
        show(vc, sender: nil)
    }

    func showDetailViewController(_ vc: UIViewController?) {
        guard let vc = vc else { return }
        showDetailViewController(vc, sender: nil)
    }

    func present(onVC: UIViewController? = nil, modalStyle: UIModalPresentationStyle = .fullScreen, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let onVC = onVC ?? UIApplication.topMostViewController else { return }
        self.modalPresentationStyle = modalStyle
        onVC.present(self, animated: animated, completion: completion)
    }
    
    func navigationControllerRootSelf() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
}

open class LHBaseViewController: UIViewController {
    fileprivate var isViewWillAppearAtFirst: Bool = true
    fileprivate var isViewDidAppearAtFirst: Bool = true

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.viewWillAppearAtFirst(self.isViewWillAppearAtFirst, animated: animated)
        self.isViewWillAppearAtFirst = false
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewDidAppearAtFirst(self.isViewDidAppearAtFirst, animated: animated)
        self.isViewDidAppearAtFirst = false
    }

    open func viewWillAppearAtFirst(_ atFirst: Bool, animated: Bool) { }
    open func viewDidAppearAtFirst(_ atFirst: Bool, animated: Bool) { }
}

open class LHBaseTableViewController: UITableViewController {
    fileprivate var isViewWillAppearAtFirst: Bool = true
    fileprivate var isViewDidAppearAtFirst: Bool = true

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.viewWillAppearAtFirst(self.isViewWillAppearAtFirst, animated: animated)
        self.isViewWillAppearAtFirst = false
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewDidAppearAtFirst(self.isViewDidAppearAtFirst, animated: animated)
        self.isViewDidAppearAtFirst = false
    }

    open func viewWillAppearAtFirst(_ atFirst: Bool, animated: Bool) { }
    open func viewDidAppearAtFirst(_ atFirst: Bool, animated: Bool) { }
}

open class LHBaseCollectionViewController: UICollectionViewController {
    fileprivate var isViewWillAppearAtFirst: Bool = true
    fileprivate var isViewDidAppearAtFirst: Bool = true

    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.viewWillAppearAtFirst(self.isViewWillAppearAtFirst, animated: animated)
        self.isViewWillAppearAtFirst = false
    }

    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.viewDidAppearAtFirst(self.isViewDidAppearAtFirst, animated: animated)
        self.isViewDidAppearAtFirst = false
    }

    open func viewWillAppearAtFirst(_ atFirst: Bool, animated: Bool) { }
    open func viewDidAppearAtFirst(_ atFirst: Bool, animated: Bool) { }
}

public extension UIStoryboard {
    func initialViewController<T>() -> T {
        instantiateInitialViewController() as! T
    }

    func viewController<T: UIViewController>(identifier: String = T.classIdentifier) -> T {
        instantiateViewController(withIdentifier: identifier) as! T
    }

    class func initialViewController<T>(name storyboardName: String, bundle bundleOrNil: Bundle? = nil) -> T {
        self.init(name: storyboardName, bundle: bundleOrNil).initialViewController()
    }
    
    class func viewController<T: UIViewController>(name storyboardName: String, bundle bundleOrNil: Bundle? = nil, identifier: String = T.classIdentifier) -> T {
        self.init(name: storyboardName, bundle: bundleOrNil).viewController(identifier: identifier)
    }
    
    convenience init(named: String) {
        self.init(name: named, bundle: nil)
    }
}

@objc public extension UIViewController {
    private func swizzled_present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if #available(iOS 13.0, *) {
            if viewControllerToPresent.modalPresentationStyle == .automatic || viewControllerToPresent.modalPresentationStyle == .pageSheet {
                viewControllerToPresent.modalPresentationStyle = .fullScreen
            }
        }

        swizzled_present(viewControllerToPresent, animated: animated, completion: completion)
    }

    @nonobjc private static let _swizzlePresentationStyle: Void = {
        let instance: UIViewController = UIViewController()
        let aClass: AnyClass! = object_getClass(instance)

        let originalSelector = #selector(UIViewController.present(_:animated:completion:))
        let swizzledSelector = #selector(UIViewController.swizzled_present(_:animated:completion:))

        let originalMethod = class_getInstanceMethod(aClass, originalSelector)
        let swizzledMethod = class_getInstanceMethod(aClass, swizzledSelector)

        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            if !class_addMethod(aClass, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod)) {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            } else {
                class_replaceMethod(aClass, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            }
        }
    }()

    @objc static func swizzlePresentationStyle() {
        _ = _swizzlePresentationStyle
    }
}

public extension UIViewController {
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar
    }
}
#endif
