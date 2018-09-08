//
//  View.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/08/23.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import ReactiveSwift
import Result

public protocol View {
    associatedtype Action
    associatedtype State

    func bind(state: Signal<State, NoError>) -> Binder<Action>
    func inject<S: Store>(store: S, mapState transformer: @escaping (S.State) -> State?) -> (Signal<S.State, NoError>, Disposable) where S.Action == Action
}

extension View where Self: UIViewController {

    public func inject<S: Store>(store: S, mapState transformer: @escaping (S.State) -> State?) -> (Signal<S.State, NoError>, Disposable) where S.Action == Action {
        return _inject(store: store, mapState: transformer)
    }

    public func inject<S: Store>(store: S) -> (Signal<S.State, NoError>, Disposable) where S.Action == Action, S.State == State {
        return _inject(store: store, mapState: { $0 })
    }

    func _inject<S: Store>(store: S, mapState transformer: @escaping (S.State) -> State?) -> (Signal<S.State, NoError>, Disposable) where S.Action == Action {
        // FIXME
        _ = view

        let (stateOutput, stateInput) = Signal<S.State, NoError>.pipe()

        let binder = bind(state: stateOutput.filterMap { transformer($0) })
        let disposable = binder.action.withLatest(from: stateOutput)
            .flatMap(.concurrent(limit: 10)) { (action, state) in
                store.mutate(action: action, state: state)
            }
            .withLatest(from: stateOutput)
            .map { store.reduce(mutation: $0.0, state: $0.1) }
            .observe(stateInput)

        stateInput.send(value: store.initialState)
        return (stateOutput, CompositeDisposable([disposable, binder.disposable]))
    }
}

extension View where Self: UIViewController, Self: Debuggable, State: Codable {
    public func inject<S: Store>(store: S, mapState transformer: @escaping (S.State) -> State) -> (Signal<State, NoError>, Disposable) where S.Action == Action, S.State == State {
        let (state, disposable) = _inject(store: store, mapState: transformer)
        hookShake(state: state)
        return (state, disposable)
    }
}

public struct Binder<Action> {
    let action: Signal<Action, NoError>
    let disposable: Disposable

    public init(action: Signal<Action, NoError>, disposable: Disposable = AnyDisposable()) {
        self.action = action
        self.disposable = disposable
    }
}
