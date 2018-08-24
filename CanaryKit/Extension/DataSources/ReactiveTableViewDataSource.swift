//
//  ReactiveTableViewDataSource.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

public protocol SectionType {
    associatedtype Row
    var rows: [Row] { get }
}

extension Reactive where Base: UITableView {
    public func items<S>(dataSource: ReactiveTableViewDataSource<S>) -> BindingTarget<[S]> {
        base.dataSource = dataSource
        return makeBindingTarget { base, sections in
            dataSource.setSections(sections)
            base.reloadData()
        }
    }
}

public final class ReactiveTableViewDataSource<Section: SectionType>: NSObject, UITableViewDataSource {

    public typealias ConfigureCell = (UITableView, Section.Row, IndexPath) -> UITableViewCell
    private var _sectionModels: [Section] = []

    private let configureCell: ConfigureCell

    public init(configureCell: @escaping ConfigureCell) {
        self.configureCell = configureCell
    }

    func setSections(_ section: [Section]) {
        self._sectionModels = section
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sectionModels[section].rows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(tableView, _sectionModels[indexPath.section].rows[indexPath.row], indexPath)
    }
}
