//
//  APIStatusViewController.swift
//  Canary
//
//  Created by Yuta Saito on 2018/09/08.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import CanaryKit
import ReactiveSwift
import Result
import UIKit

class APIStatusViewController: UIViewController, XibInstantiatable {

    @IBOutlet private weak var statusLabel: UILabel!

    convenience init() {
        self.init(nibName: type(of: self).xibName, bundle: nil)
    }
}

extension APIStatusViewController: View {
    typealias Action = APIStatusAction
    typealias State = APIStatusState

    func bind(state: Signal<State, NoError>) -> Binder<Action> {
        statusLabel.reactive.text <~ state.filterMap { $0.homeTimelineLimit?.limit.description }
        let reload = reactive.viewDidAppear.map(value: Action.reload)
        return Binder(action: .merge([reload]))
    }
}
