//
//  HPViewController.swift
//  PoOrientationManager
//
//  Created by HzS on 2024/1/11.
//

import UIKit
import PoOrientationManager

class HPViewController: UIViewController {
    
    deinit {
        print("HPViewController die")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回", style: .plain, target: self, action: #selector(handleDismissButtonClick))
        
        supportedMask = .allButUpsideDown
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        currentMask
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
    func changeToSupportPortrait() {
        supportedMask = .portrait
    }
    
    @IBAction
    func changeToSupportAll() {
        supportedMask = .allButUpsideDown
    }
    
    @IBAction
    func lockOrUnlockScreen(_ sender: UIButton) {
        if isRotationLockedBySubviews {
            unlockRotation(by: view)
            sender.setTitle("锁屏", for: .normal)
        } else {
            lockRotation(by: view)
            sender.setTitle("解锁", for: .normal)
        }
    }
    
}
