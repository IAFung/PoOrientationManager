//
//  PoOrientationManager.swift
//  PoOrientationManager
//
//  Created by zhongshan on 2024/1/5.
//

import UIKit

public final class PoOrientationManager {
    public static let shared = PoOrientationManager()
    private init() {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: nil) { [weak self] notification in
            guard let self else { return }
            if UIApplication.shared.applicationState != .active { return }
            
            let deviceOrientation = UIDevice.current.orientation
            if deviceOrientation == .portrait || deviceOrientation.isLandscape {
                if let currentController =  UIViewController.poCurrentViewController, currentController.poCurrentOrientation != deviceOrientation.toInterfaceOrientation {
                    set(deviceOrientation.toInterfaceOrientation, to: currentController)
                }
            }
        }
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
    
    public func set(_ orientation: UIInterfaceOrientation, to viewController: UIViewController? = nil) {
        guard let viewController = viewController ?? UIViewController.poCurrentViewController,
                orientation != .unknown else { return }
        
        if !viewController.validateOrientation(orientation) { return }
        
        viewController.poCurrentSupportedInterfaceOrientations = orientation.toInterfaceOrientationMask
        viewController.poCurrentOrientation = orientation
        
        if #available(iOS 16.0, *) {
            guard let scence = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
//            viewController.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            viewController.setNeedsUpdateOfSupportedInterfaceOrientations()
//            scence.windows.forEach({ $0.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations() })
            let geometryPreferencesIOS = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation.toInterfaceOrientationMask)
            scence.requestGeometryUpdate(geometryPreferencesIOS) { error in
#if DEBUG
                print("OrientationManager \(type(of: viewController)) error: \(error)")
#endif
            }
        } else {
            UIDevice.current.setValue(NSNumber(integerLiteral: orientation.toDeviceOrientation.rawValue), forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

extension UIViewController {
    
    fileprivate func validateOrientation(_ orientation: UIInterfaceOrientation) -> Bool {
        let validMask = orientation.toInterfaceOrientationMask
        if let poPreferredInterfaceOrientations {
            return poPreferredInterfaceOrientations.contains(validMask)
        }
        return poSupportedInterfaceOrientations.contains(validMask)
    }
}

extension UIDeviceOrientation {
    fileprivate var toInterfaceOrientation: UIInterfaceOrientation {
        switch self {
        case .unknown:
            .unknown
        case .portrait:
            .portrait
        case .portraitUpsideDown:
            .portraitUpsideDown
        case .landscapeLeft:
            .landscapeRight
        case .landscapeRight:
            .landscapeLeft
        case .faceUp:
            .unknown
        case .faceDown:
            .unknown
        @unknown default:
            .unknown
        }
    }
}

extension UIInterfaceOrientation {
    fileprivate var toDeviceOrientation: UIDeviceOrientation {
        switch self {
        case .unknown:
            .unknown
        case .portrait:
            .portrait
        case .portraitUpsideDown:
            .portraitUpsideDown
        case .landscapeLeft:
            .landscapeRight
        case .landscapeRight:
            .landscapeLeft
        @unknown default:
            .unknown
        }
    }
    
    internal var toInterfaceOrientationMask: UIInterfaceOrientationMask {
        UIInterfaceOrientationMask(rawValue: 1 << rawValue)
    }
}
