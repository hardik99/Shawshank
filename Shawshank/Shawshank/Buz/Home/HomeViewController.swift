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
import Differentiator
import RxCocoa
import RxSwift
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
            HomeViewSectionModel.init(header: "代理", items: ["启动",]),
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
        
        tableView.rx.itemSelected
            .map { ($0, dataSource[$0]) }
            .subscribe { [weak self] event in
                guard let indexPath = event.element?.0, let item = event.element?.1 else { return }
                self?.itemSelected(self?.tableView, indexPath: indexPath, item: item)
            }
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

// MARK: Configure Cell
extension HomeViewController {
    private func itemSelected(_ tableView: UITableView?, indexPath: IndexPath, item: HomeViewSectionModel.Item) {
        tableView?.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            VpnManager.shared.connect()
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
