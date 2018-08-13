//
//  HomeViewModel.swift
//  Shawshank
//
//  Created by Gua on 2018/8/13.
//  Copyright © 2018 Harry Twan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Differentiator

struct HomeViewSectionModel {
    var header: String
    var items: [Item]
}

extension HomeViewSectionModel: AnimatableSectionModelType {
    typealias Item = String

    var identity: String {
        return header
    }

    init(original: HomeViewSectionModel, items: [HomeViewSectionModel.Item]) {
        self = original
        self.items = items
    }
}

struct HomeViewCellModel {
    var itemTitle: String
}
