//
//  PortraitViewController.swift
//  PoOrientationManager
//
//  Created by HzS on 2024/1/8.
//

import UIKit
import PoOrientationManager

class PortraitViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(handleDismissButtonClick))
    }


    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return currentMask
    }
    
    // MARK: - Action
    
    @IBAction
    func changeToHorizontal() {
        PoOrientationManager.shared.set(.landscapeRight)
    }
    
    @IBAction
    func changeToPortrait() {
        PoOrientationManager.shared.set(.portrait)
    }
    
    @IBAction
    func pushHPController() {
        let vc = HPViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension UIViewController {
    @objc
    func handleDismissButtonClick() {
        if navigationController?.viewControllers.count == 1 {
            dismiss(animated: true)
        } else {
            navigationController?.popViewController(animated: true)
        }
//        if presentingViewController != nil {
//            dismiss(animated: true)
//        } else {
//            navigationController?.popViewController(animated: true)
//        }
    }
}
