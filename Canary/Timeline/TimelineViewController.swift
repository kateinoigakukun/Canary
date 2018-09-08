//
//  TimelineViewController.swift
//  Canary
//
//  Created by Yuta Saito on 2018/08/24.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Result
import APIModel
import CanaryKit
import Repository

class TimelineViewController: UIViewController, XibInstantiatable {
    @IBOutlet private weak var tableView: UITableView!

    lazy var timelineCellToken = self.tableView.canary.register(forNib: TimelineCell.self)

    convenience init() {
        self.init(nibName: type(of: self).xibName, bundle: nil)
    }
}

extension TimelineViewController: View, Injectable {
    typealias Action = TimelineAction
    typealias State = TimelineState
    typealias Dependency = Void

    func inject(with dependency: Void) {}

    func bind(state: Signal<State, NoError>) -> Binder<Action> {
        let dataSource = ReactiveTableViewDataSource<State.Section> { [timelineCellToken] tableView, row, indexPath in
            let cell = timelineCellToken.dequeue(in: tableView, for: indexPath, dependency: row)
            return cell
        }
        tableView.reactive.items(dataSource: dataSource) <~ state.map(\.sections)
        let requestNext = tableView.reactive.reachedBottom
            .withLatest(from: state.map(\.isLoading))
            .filter { !$1 }
            .map { $0.0 }
            .throttle(0.4, on: QueueScheduler.main)
            .map(value: Action.next)
        let reload = reactive.viewDidAppear.map(value: Action.reload)

        return Binder(action: .merge([requestNext, reload]))
    }
}
