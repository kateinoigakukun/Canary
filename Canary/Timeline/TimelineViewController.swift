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

class TimelineViewController: UIViewController, StoryboardInstantiatable {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
}

extension TimelineViewController: View, Injectable, Debuggable {
    typealias Action = TimelineAction
    typealias State = TimelineState
    typealias Dependency = Void

    enum Section: SectionType {
        typealias Row = Tweet
        case timeline([Tweet])
        var rows: [Tweet] {

            switch self {
            case .timeline(let timeline):
                return timeline
            }
        }
    }

    func inject(with dependency: Void) {}

    func bind(state: Signal<State, NoError>) -> Binder<Action> {
        let dataSource = ReactiveTableViewDataSource<Section> { tableView, row, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            cell.textLabel?.text = row.text
            return cell
        }
        tableView.reactive.items(dataSource: dataSource) <~ state.map {
            [Section.timeline($0.timeline)]
        }

        let requestNext = tableView.reactive.reachedBottom.map(value: Action.next)
            .withLatest(from: state.map(\.isLoading))
            .throttle(0.4, on: QueueScheduler.main)
            .filter { !$1 }
            .map { $0.0 }

        return Binder(
            action: Signal.merge(
                [
                    requestNext,
                    reactive.viewDidAppear.map(value: Action.reload)
                ]
            )
        )
    }
}
