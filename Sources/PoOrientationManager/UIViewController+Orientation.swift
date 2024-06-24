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
        static var supportedInterfaceOrientations: UInt8 = 0
        static var preferredInterfaceOrientations: UInt8 = 0
        static var currentSupportedInterfaceOrientations: UInt8 = 0
        static var currentOrientation: UInt8 = 0
        static var portraitRotationLockedSubviews: UInt8 = 0
        static var horizontalRotationLockedSubviews: UInt8 = 0
    }
    
    /// 页面是否处于活跃状态
    public var poIsActive: Bool {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.isActive) as? Bool) ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.isActive, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 当前页面所支持的旋转方向,
    public var poSupportedInterfaceOrientations: UIInterfaceOrientationMask {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.supportedInterfaceOrientations) as? UIInterfaceOrientationMask) ?? .portrait }
        set { objc_setAssociatedObject(self, &AssociatedKeys.supportedInterfaceOrientations, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 当前面首选支持的旋转方向
    internal var poPreferredInterfaceOrientations: UIInterfaceOrientationMask? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.preferredInterfaceOrientations) as? UIInterfaceOrientationMask }
        set { objc_setAssociatedObject(self, &AssociatedKeys.preferredInterfaceOrientations, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 当前页面当时支持的旋转方向，
    /// 需要在当前页面的supportedInterfaceOrientation中返回poCurrentSupportedInterfaceOrientations
    public internal(set) var poCurrentSupportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.currentSupportedInterfaceOrientations) as? UIInterfaceOrientationMask {
                return value
            }
            let support = poSupportedInterfaceOrientations
            if poCurrentOrientation == .unknown, support.contains(preferredInterfaceOrientationForPresentation.toInterfaceOrientationMask) {
                return preferredInterfaceOrientationForPresentation.toInterfaceOrientationMask
            }
            
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
        set { objc_setAssociatedObject(self, &AssociatedKeys.currentSupportedInterfaceOrientations, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// 当前页面展示方向，建议采用该属性判断页面方向
    public internal(set) var poCurrentOrientation: UIInterfaceOrientation {
        get { (objc_getAssociatedObject(self, &AssociatedKeys.currentOrientation) as? UIInterfaceOrientation) ?? .unknown }
        set { objc_setAssociatedObject(self, &AssociatedKeys.currentOrientation, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
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
    
    public var poDevicePreferredHorizontalInterfaceOrientation: UIInterfaceOrientation {
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
    public var poIsRotationLockedBySubviews: Bool {
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
    }
    
    
    @objc
    private func orientation_viewWillAppear(_ animated: Bool) {
        orientation_viewWillAppear(animated)
        poIsActive = true
        if notAllowCheckOrientation { return }
        if presentingViewController != nil && modalPresentationStyle == .fullScreen { return }
        
        var targetOrientation = poCurrentOrientation
        if targetOrientation == .unknown { // vc第一次展示
            if poSupportedInterfaceOrientations.contains(preferredInterfaceOrientationForPresentation.toInterfaceOrientationMask) {
                targetOrientation = preferredInterfaceOrientationForPresentation
            } else {
                let support = self.poSupportedInterfaceOrientations
                if support.contains(.portrait) {
                    targetOrientation = .portrait
                } else if support == .landscapeRight {
                    targetOrientation = .landscapeRight
                } else if support == .landscapeLeft {
                    targetOrientation = .landscapeLeft
                } else if support == .landscape {
                    targetOrientation = poDevicePreferredHorizontalInterfaceOrientation
                } else {
                    targetOrientation = .portrait
                }
            }
        }
        PoOrientationManager.shared.set(targetOrientation, to: self)
    }
    
    @objc
    private func orientation_viewWillDisappear(_ animated: Bool) {
        orientation_viewWillDisappear(animated)
        poIsActive = false
    }
    
    private var notAllowCheckOrientation: Bool {
        if self is UINavigationController || self is UITabBarController {
            return true
        }
        return false
    }
    
}

// MARK: - subview lock
extension UIViewController {
    /// 按照当前设备方向锁定旋转subview
    public func poLockRotation(by subview: UIView) {
        if poCurrentOrientation.isLandscape {
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
        poPreferredInterfaceOrientations = lockedSubviewsOrientationMask
    }
    
    /// 解开subview的旋转锁定
    public func poUnlockRotation(by subview: UIView) {
        portraitRotationLockedSubviews?.remove(subview)
        horizontalRotationLockedSubviews?.remove(subview)
        poPreferredInterfaceOrientations = lockedSubviewsOrientationMask
    }
    
    /// 将所有subview的锁定旋转都解开
    public func poResetAllLockedViews() {
        portraitRotationLockedSubviews?.removeAllObjects()
        horizontalRotationLockedSubviews?.removeAllObjects()
        poPreferredInterfaceOrientations = lockedSubviewsOrientationMask
    }
}


