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
import Result

public protocol SectionType {
    associatedtype Row
    var rows: [Row] { get }
}

extension Reactive where Base: UITableView {
    public func items<S, State>(dataSource: ReactiveTableViewDataSource<S, State>) -> BindingTarget<[S]> {
        base.dataSource = dataSource
        return makeBindingTarget { base, sections in
            dataSource.setSections(sections)
            base.reloadData()
        }
    }
}

public final class ReactiveTableViewDataSource<Section: SectionType, State>: NSObject, UITableViewDataSource {

    public typealias ConfigureCell = (UITableView, Section.Row, IndexPath) -> CellProxy<State>
    private var _sectionModels: [Section] = []

    private let configureCell: ConfigureCell

    public let state: Signal<State, NoError>
    private let stateInput: Signal<State, NoError>.Observer

    public init(configureCell: @escaping ConfigureCell) {
        self.configureCell = configureCell
        (self.state, self.stateInput) = Signal.pipe()
    }

    func setSections(_ section: [Section]) {
        self._sectionModels = section
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sectionModels[section].rows.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let proxy = configureCell(tableView, _sectionModels[indexPath.section].rows[indexPath.row], indexPath)
        let cell = proxy.cell
        let disposeEvent = [cell.reactive.prepareForReuse, cell.reactive.lifetime.ended.map(value: ())]
        Signal.merge(disposeEvent).observeCompleted { proxy.dispose() }
        proxy.state.take(until: cell.reactive.prepareForReuse).observeValues { [weak self] in
            self?.stateInput.send(value: $0)
        }
        return cell
    }
}
