//
//  ViewController.swift
//  PoOrientationManager
//
//  Created by zhongshan on 2024/1/5.
//

import UIKit
import PoOrientationManager

extension ViewController {
    enum RotateScene: String, CaseIterable {
        case pushToOnlyPortrait
        case pushToOnlyLandscape
        case pushToAllButUpsideDown
        case presentToOnlyPortrait
        case presentToOnlyLandscape
        case presentToAllButUpsideDown
    }
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let dataList = RotateScene.allCases
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        poSupportedInterfaceOrientations = .allButUpsideDown
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        poSupportedInterfaceOrientations = .allButUpsideDown
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        title = "rotate case"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        poCurrentSupportedInterfaceOrientations
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        poDevicePreferredHorizontalInterfaceOrientation
    }

}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(UITableViewCell.self), for: indexPath)
        if #available(iOS 14.0, *) {
            var config = UIListContentConfiguration.cell()
            config.text = dataList[indexPath.row].rawValue
            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = dataList[indexPath.row].rawValue
        }
        return cell
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch dataList[indexPath.row] {
        case .pushToOnlyPortrait:
            let vc = PortraitViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case .pushToOnlyLandscape:
            let vc = HorizontalViewController()
            vc.poSupportedInterfaceOrientations = .landscape
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case .pushToAllButUpsideDown:
            let vc = HPViewController()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        case .presentToOnlyPortrait:
            let vc = PortraitViewController()
            let nav = NavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .presentToOnlyLandscape:
            let vc = HorizontalViewController()
            vc.poSupportedInterfaceOrientations = .landscape
            let nav = NavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        case .presentToAllButUpsideDown:
            let vc = HPViewController()
            let nav = NavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
}

