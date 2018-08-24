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

class TimelineViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))
    }
}

extension TimelineViewController: View {
    typealias Action = TimelineStore.Action
    typealias State = TimelineStore.State

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

    func bind(state: Signal<TimelineStore.State, NoError>) -> Binder<TimelineStore.Action> {
        let dataSource = ReactiveTableViewDataSource<Section> { tableView, row, indexPath in
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: UITableViewCell.self), for: indexPath)
            cell.textLabel?.text = row.text
            return cell
        }
        tableView.reactive.items(dataSource: dataSource) <~ state.map {
            [Section.timeline($0.timeline)]
        }

        tableView.reactive.contentOffset
            .logEvents()
            .observeResult { _ in }

        return Binder(action: reactive.viewDidAppear.map(value: Action.reload))
    }
}
