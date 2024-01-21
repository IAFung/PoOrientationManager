//
//  PoOrientationManager.swift
//  PoOrientationManager
//
//  Created by zhongshan on 2024/1/5.
//

import UIKit

public class PoOrientationManager: NSObject {
    public static let shared = PoOrientationManager()
    private override init() {
        super.init()
        
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
    }
    
    public func set(_ orientation: UIInterfaceOrientation, to viewController: UIViewController? = nil) {
        guard let viewController = viewController ?? UIViewController.poCurrentViewController,
                orientation != .unknown else { return }
        
        if !viewController.validateOrientation(orientation) { return }
        
        viewController.poCurrentSupportedInterfaceOrientations = UIInterfaceOrientationMask(rawValue: 1 << orientation.rawValue)
        viewController.poCurrentOrientation = orientation
        
        if #available(iOS 16.0, *) {
            viewController.navigationController?.setNeedsUpdateOfSupportedInterfaceOrientations()
            viewController.setNeedsUpdateOfSupportedInterfaceOrientations()
            guard let scence = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            let geometryPreferencesIOS = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: UIInterfaceOrientationMask(rawValue: 1 << orientation.rawValue))
            scence.requestGeometryUpdate(geometryPreferencesIOS) { error in
                print("OrientationManager \(type(of: viewController)) error: \(error)")
            }
        } else {
            UIDevice.current.setValue(NSNumber(integerLiteral: orientation.toDeviceOrientation.rawValue), forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

extension UIViewController {
    
    fileprivate func validateOrientation(_ orientation: UIInterfaceOrientation) -> Bool {
        let validMask = UIInterfaceOrientationMask(rawValue: 1 << orientation.rawValue)
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
}
