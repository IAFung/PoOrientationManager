//
//  HorizontalViewController.swift
//  PoOrientationManager
//
//  Created by HzS on 2024/1/9.
//

import UIKit
import PoOrientationManager

class HorizontalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(handleDismissButtonClick))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        poCurrentSupportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        poDevicePreferredHorizontalInterfaceOrientation
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
    func push() {
        let vc = HPViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction
    func present() {
        let vc = HPViewController()
        let nav = NavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
