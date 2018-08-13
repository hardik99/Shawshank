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

    private let tableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return tableView
    }()

    private var disposeBag = DisposeBag()

    private var dataSource: RxTableViewSectionedAnimatedDataSource<HomeViewSectionModel>?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialViews()
        initialDatas()
        initialLayouts()
    }
    
    private func initialViews() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Shawshank"
        
        view.addSubview(tableView)
    }
    
    private func initialDatas() {

        let sections = [
            HomeViewSectionModel.init(header: "代理", items: ["s1-1", "s1-2",]),
            HomeViewSectionModel.init(header: "高级设置", items: ["自定义 DNS", "智能路由",]),
        ]

        let dataSource = RxTableViewSectionedAnimatedDataSource<HomeViewSectionModel>(
            configureCell: { dataSource, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
                cell.textLabel?.text = dataSource.sectionModels[indexPath.section].items[indexPath.row]
                return cell
            },
            titleForHeaderInSection: { dataSource, index in
                return dataSource.sectionModels[index].identity
            }
        )
        self.dataSource = dataSource

        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: dataSource))
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


