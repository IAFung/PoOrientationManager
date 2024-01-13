//
//  UIViewController+Orientation.swift
//  PoOrientationManager
//
//  Created by zhongshan on 2024/1/5.
//

import UIKit

extension UIViewController {
    
    private enum AssociatedKeys {
        static var isActive: UInt8 = 0
        static var supportedMask: UInt8 = 0
        static var preferredMask: UInt8 = 0
        static var currentMask: UInt8 = 0
        static var currentOrientation: UInt8 = 0
        static var recoverInterface: UInt8 = 0
        static var tempSupportedMask: UInt8 = 0
        static var portraitRotationLockedSubviews: UInt8 = 0
        static var horizontalRotationLockedSubviews: UInt8 = 0
    }
    
    /// 页面是否处于活跃状态
    public var isActive: Bool {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.isActive) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.isActive, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 当前页面所支持的旋转方向,
    public var supportedMask: UIInterfaceOrientationMask {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.supportedMask) as? UIInterfaceOrientationMask) ?? .portrait }
        set { objc_setAssociatedObject(self, &AssociatedKeys.supportedMask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 当前面首选支持的旋转方向
    public var preferredMask: UIInterfaceOrientationMask? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.preferredMask) as? UIInterfaceOrientationMask }
        set { objc_setAssociatedObject(self, &AssociatedKeys.preferredMask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 当前页面当时支持的旋转方向，
    /// 需要在当前页面的supportedInterfaceOrientation中返回currentMask
    public internal(set) var currentMask: UIInterfaceOrientationMask {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.currentMask) as? UIInterfaceOrientationMask {
                return value
            }
            let support = self.supportedMask
            if support.contains(.portrait) {
                return .portrait
            } else if support == .landscapeRight {
                return .landscapeRight
            } else if support == .landscapeLeft {
                return .landscapeLeft
            } else if support == .landscape {
                return deviceHorizontalOrientationMask
            } else {
                return .portrait
            }
        }
        set { objc_setAssociatedObject(self, &AssociatedKeys.currentMask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 当前页面展示方向，建议采用该属性判断页面方向
    public internal(set) var currentOrientation: UIInterfaceOrientation {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.currentOrientation) as? UIInterfaceOrientation) ?? .unknown }
        set { objc_setAssociatedObject(self, &AssociatedKeys.currentOrientation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
        
    /// 页面需要恢复的旋转方向
    private var recoverInterface: UIInterfaceOrientation? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.recoverInterface) as? UIInterfaceOrientation }
        set { objc_setAssociatedObject(self, &AssociatedKeys.recoverInterface, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 页面发生Present时临时支持方向
    var tempSupportedMask: UIInterfaceOrientationMask? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.tempSupportedMask) as? UIInterfaceOrientationMask }
        set { objc_setAssociatedObject(self, &AssociatedKeys.tempSupportedMask, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var deviceHorizontalOrientationMask: UIInterfaceOrientationMask {
        switch UIDevice.current.orientation {
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        default:
            return .landscapeRight
        }
    }
    
    public var devicePreferredHorizontalInterfaceOrientation: UIInterfaceOrientation {
        switch UIDevice.current.orientation {
        case .landscapeRight:
            return .landscapeLeft
        case .landscapeLeft:
            return .landscapeRight
        default:
            return .landscapeRight
        }
    }
    
    // MARK: - subview lock
    
    /// 是否被子视图锁定旋转
    public var isRotationLockedBySubviews: Bool {
        (portraitRotationLockedSubviews != nil && portraitRotationLockedSubviews!.count > 0) ||
        ( horizontalRotationLockedSubviews != nil && horizontalRotationLockedSubviews!.count > 0)
    }
    
    private var lockedSubviewsOrientationMask: UIInterfaceOrientationMask? {
        if portraitRotationLockedSubviews != nil && portraitRotationLockedSubviews!.count > 0 {
            return .portrait
        }
        if horizontalRotationLockedSubviews != nil && horizontalRotationLockedSubviews!.count > 0 {
            return .landscape
        }
        return nil
    }
    
    private var portraitRotationLockedSubviews: NSHashTable<UIView>? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.portraitRotationLockedSubviews) as? NSHashTable<UIView> }
        set { objc_setAssociatedObject(self, &AssociatedKeys.portraitRotationLockedSubviews, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var horizontalRotationLockedSubviews: NSHashTable<UIView>? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.horizontalRotationLockedSubviews) as? NSHashTable<UIView> }
        set { objc_setAssociatedObject(self, &AssociatedKeys.horizontalRotationLockedSubviews, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 按照当前设备方向锁定旋转subview
    public func lockRotation(by subview: UIView) {
        if currentOrientation.isLandscape {
            if horizontalRotationLockedSubviews == nil {
                horizontalRotationLockedSubviews = NSHashTable.weakObjects()
            }
            horizontalRotationLockedSubviews?.add(subview)
            portraitRotationLockedSubviews?.removeAllObjects()
        } else {
            if portraitRotationLockedSubviews == nil {
                portraitRotationLockedSubviews = NSHashTable.weakObjects()
            }
            portraitRotationLockedSubviews?.add(subview)
            horizontalRotationLockedSubviews?.removeAllObjects()
        }
        preferredMask = lockedSubviewsOrientationMask
    }
    
    /// 解开subview的旋转锁定
    public func unlockRotation(by subview: UIView) {
        portraitRotationLockedSubviews?.remove(subview)
        horizontalRotationLockedSubviews?.remove(subview)
        preferredMask = lockedSubviewsOrientationMask
    }
    
    /// 将所有subview的锁定旋转都解开
    public func resetAllLockedViews() {
        portraitRotationLockedSubviews?.removeAllObjects()
        horizontalRotationLockedSubviews?.removeAllObjects()
        preferredMask = lockedSubviewsOrientationMask
    }
}


extension UIViewController {

    /// 保证在所有页面初始化之前调用（建议在didFinishLaunchingWithOptions时调用）
    public static func orientationInitial() {
        do {
            let originalSelector = #selector(UIViewController.viewWillAppear(_:))
            let swizzledSelector = #selector(UIViewController.orientation_viewWillAppear(_:))
            guard let originalMethod = class_getInstanceMethod(self, originalSelector),
                    let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        do {
            let originalSelector = #selector(UIViewController.viewWillDisappear(_:))
            let swizzledSelector = #selector(UIViewController.orientation_viewWillDisappear(_:))
            guard let originalMethod = class_getInstanceMethod(self, originalSelector),
                    let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        do {
            let originalSelector = #selector(UIViewController.present(_:animated:completion:))
            let swizzledSelector = #selector(UIViewController.orientation_present(_:animated:completion:))
            guard let originalMethod = class_getInstanceMethod(self, originalSelector),
                    let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
        do {
            let originalSelector = #selector(UIViewController.dismiss(animated:completion:))
            let swizzledSelector = #selector(UIViewController.orientation_dismiss(animated:completion:))
            guard let originalMethod = class_getInstanceMethod(self, originalSelector),
                    let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else { return }
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
        
    }
    
    
    @objc
    private func orientation_viewWillAppear(_ animated: Bool) {
        orientation_viewWillAppear(animated)
        isActive = true
        if notAllowCheckOrientation { return }
        
        var targetOrientation = currentOrientation
        if targetOrientation == .unknown {
            if supportedMask == .landscape {
                targetOrientation = preferredInterfaceOrientationForPresentation.isLandscape ? preferredInterfaceOrientationForPresentation : devicePreferredHorizontalInterfaceOrientation
            } else {
                targetOrientation = .portrait
            }
        }
        PoOrientationManager.shared.set(targetOrientation, to: self)
    }
    
    @objc
    private func orientation_viewWillDisappear(_ animated: Bool) {
        orientation_viewWillDisappear(animated)
        isActive = false
    }
    
    @objc
    private func orientation_present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        let currentController = self
        let preferredSupportedMask = currentController.preferedSupportedMask
        
        /// 如果当前页面只支持横屏，则需要设置锁定方向，方便回来之后处理
        if (preferredSupportedMask == .landscape || preferredSupportedMask == .landscapeLeft || preferredSupportedMask == .landscapeRight) && viewControllerToPresent.supportedInterfaceOrientations == .portrait {
            // 存储当前页面的supportedMask和方向
            currentController.recoverInterface = currentController.currentOrientation
            currentController.tempSupportedMask = .allButUpsideDown
            
            currentController.delayPresent(viewControllerToPresent, animated: flag, completion: completion)
            return
        }
        /// 如果跳转的页面仅支持竖屏，则需要先转竖屏再跳转
        if viewControllerToPresent.modalPresentationStyle != .fullScreen && viewControllerToPresent.supportedInterfaceOrientations == .portrait {
            currentController.delayPresent(viewControllerToPresent, animated: flag, completion: completion)
            return
        }
        orientation_present(viewControllerToPresent, animated: flag, completion: completion)
    }
    
    private func delayPresent(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        PoOrientationManager.shared.set(.portrait, to: self)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            self.orientation_present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    @objc
    private func orientation_dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        let currentController = presentingViewController
        orientation_dismiss(animated: flag) {
            completion?()
            guard let currentController, let tempMask = currentController.tempSupportedMask else { return }
            
            if tempMask.contains(.landscapeLeft) || tempMask.contains(.landscapeRight),
                let recoverInterface = currentController.recoverInterface {
                currentController.tempSupportedMask = nil
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    PoOrientationManager.shared.set(recoverInterface, to: currentController)
                    currentController.recoverInterface = nil
                }
            }
        }
    }
    
    private var notAllowCheckOrientation: Bool {
//        if self.navigationController == nil {
//            return true
//        }
        if self is UINavigationController || self is UITabBarController {
            return true
        }
        return false
    }
    
    private var preferedSupportedMask: UIInterfaceOrientationMask {
        if let preferredMask {
            return preferredMask
        }
        return self.supportedMask
    }
    
}


