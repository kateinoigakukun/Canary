//
//  ViewController.swift
//  Canary
//
//  Created by Yuta Saito on 2018/08/23.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import UIKit
import ReactiveCocoa
import CanaryKit
import Repository
import OAuthSwift

class ViewController: UIViewController {

    var button: UIButton!
    var disposable: Disposable?

    override func viewDidLoad() {
        super.viewDidLoad()

        button = UIButton(type: .system)
        button.frame = view.frame
        button.setTitle("Hello", for: .normal)
        button.setTitleColor(.cyan, for: .normal)
        view.backgroundColor = .white
        view.addSubview(button)
        // Do any additional setup after loading the view, typically from a nib.

        _ = inject(store: SampleStore())
    }

}

extension ViewController: View {
    typealias Action = SampleStore.Action
    typealias State = SampleStore.State

    func bind(state: Signal<SampleStore.State, NoError>) -> Binder<SampleStore.Action> {

        button.reactive.title <~ state.map { state -> String in
            switch state {
            case .loading(let value): return value
            case .loaded(let value): return value
            }
        }

        button.reactive.controlEvents(.touchUpInside)
            .flatMap(.concat) { [unowned self] _ in
                let client = OAuthSwiftClient(
                    consumerKey: Secret.shared.consumerKey,
                    consumerSecret: Secret.shared.consumerSecret,
                    oauthToken: Secret.shared.oauthToken,
                    oauthTokenSecret: Secret.shared.oauthTokenSecret,
                    version: .oauth1
                )
                let vc = TimelineViewController()
                let store = TimelineStore(
                    repository: PagingReposioty<SinceMaxPaginatedRequest>(
                        initialRequest: UserTimelineRequest(
                            screenName: "OY_A_Official"
                        ),
                        client: client
                    ),
                    apiRepository: APIRepository(client: client)
                )
                //            let store = TimelineStore(
                //                repository: PagingReposioty<SinceMaxPaginatedRequest>(
                //                    initialRequest: SearchRequest(query: "iOSDC"),
                //                    client: client
                //                )
                //            )

//                let vc = APIStatusViewController()
//                let store = APIStatusStore(repository: APIRepository(client: client))
                _ = vc.inject(store: store)
                self.navigationController?.pushViewController(vc, animated: true)
//                self.canary.present(vc, animated: true, store: store)
                return SignalProducer.empty
            }
            .observeValues { (state: APIStatusState) in
                print(state)
        }

        return Binder<Action>(
            action: reactive.viewDidAppear.map(value: Action.viewDidAppear)
        )
    }
}

import ReactiveSwift
import Result

class SampleStore: Store {
    enum Action {
        case viewDidAppear
    }

    enum Mutation {
        case setLoaded(String)
    }

    enum State {
        case loading(String)
        case loaded(String)
    }

    var initialState: SampleStore.State = .loading("Loading")

    let backgroundScheduler = QueueScheduler(qos: .background)

    func mutate(action: Action, state: State) -> SignalProducer<Mutation, NoError> {
        switch action {
        case .viewDidAppear:
            return SignalProducer(value: .setLoaded("Loaded")).delay(2, on: backgroundScheduler)
        }
    }

    func reduce(mutation: Mutation, state: State) -> State {
        switch mutation {
        case .setLoaded(let value):
            return .loaded(value)
        }
    }
}
