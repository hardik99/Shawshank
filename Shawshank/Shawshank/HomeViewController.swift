//
//  ViewController.swift
//  Shawshank
//
//  Created by Harry Twan on 2018/8/11.
//  Copyright © 2018 Harry Twan. All rights reserved.
//

import UIKit
import NEKit
import CocoaLumberjack
import RxDataSources
import RxCocoa
import RxSwift
import Differentiator
import SnapKit

class HomeViewController: UIViewController {
    
    private let tableView = UITableView(frame: .zero, style: .grouped)
    
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Double>>(
        configureCell: { (_, tv, indexPath, element) in
            let cell = tv.dequeueReusableCell(withIdentifier: "cell")!
            cell.textLabel?.text = "\(element) @row \(indexPath.section) -> \(indexPath.row)"
            return cell
        }
    )
    
    var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViews()
        initialDatas()
        initialLayouts()
    }
    
    private func initialViews() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Shawshank"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
    }
    
    private func initialDatas() {
        let item = Observable.just(
            (0..<20).map { "\($0)" }
        )

        item.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) {
                row, element, cell in
                cell.textLabel?.text = "\(element) @row \(row)"
            }
            .disposed(by: disposeBag)
        

        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: { pair in
                print("tap \(pair)")
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemAccessoryButtonTapped
            .subscribe(onNext: { indexPath in
                print("tap \(indexPath.row)")
            })
            .disposed(by: disposeBag)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func initialLayouts() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
}

//    var observerAdded: Bool = true
//
//    private func loadVpn() {
//
//
//        NETunnelProviderManager.loadAllFromPreferences { managers, error in
//            guard let managers = managers else { return }
//            var manager: NETunnelProviderManager
//            if managers.count > 0 {
//                manager = managers[0]
//            } else {
//                manager = self.createProviderManager()
//            }
//
//            manager.isEnabled = true
//            self.setRulerConfig(manager)
//            manager.saveToPreferences(completionHandler: { error in
//                guard let error = error else {
//                    return
//                }
//                manager.loadFromPreferences(completionHandler: { error2 in
//                    guard let error2 = error2 else {
//                        print("ok")
//                        return
//                    }
//                })
//            })
//        }
//    }
//
//
//    func createProviderManager() -> NETunnelProviderManager {
//        let manager = NETunnelProviderManager()
//        let conf = NETunnelProviderProtocol()
//        conf.serverAddress = "Test VPN"
//        manager.protocolConfiguration = conf
//        manager.localizedDescription = "Shawshank VPN Proxy"
//        manager.isEnabled = true
//        return manager
//    }
//
//    private func createVpn() {
//    }
//
//    private func saveVpn() {
//
//    }
//
//    func getRuleConf() -> String{
////        let Path = Bundle.main.path(forResource: "NEKitRule", ofType: "conf")
////        let Data = try? Foundation.Data(contentsOf: URL(fileURLWithPath: Path!))
////        let str = String(data: Data!, encoding: String.Encoding.utf8)!
//        return ""
//    }
//
//    func setRulerConfig(_ manager: NETunnelProviderManager) {
//        var conf = [String: AnyObject]()
//        conf["ss_address"] = "YOUR SS URL" as AnyObject?
//        conf["ss_port"] = 1025 as AnyObject?
//        conf["ss_method"] = "CHACHA20" as AnyObject? // 大写 没有横杠 看Extension中的枚举类设定 否则引发fatal error
//        conf["ss_password"] = "YOUR SS PASSWORD" as AnyObject?
//        conf["ymal_conf"] = getRuleConf() as AnyObject?
//        let orignConf = manager.protocolConfiguration as! NETunnelProviderProtocol
//        orignConf.providerConfiguration = conf
//        manager.protocolConfiguration = orignConf
//    }


