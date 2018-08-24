//
//  View.swift
//  Framework
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
}

extension View {

    public func inject<S: Store>(store: S) -> Disposable? where S.Action == Action, S.State == State {
        let (stateOutput, stateInput) = Signal<State, NoError>.pipe()
        let binder = bind(state: stateOutput)
        let disposable = binder.action.withLatest(from: stateOutput)
            .flatMap(.concurrent(limit: 10)) { (action, state)in
                return store.mutate(action: action, state: state)
            }
            .withLatest(from: stateOutput)
            .map { store.reduce(mutation: $0.0, state: $0.1) }
            .observe(stateInput)

        stateInput.send(value: store.initialState)
        return CompositeDisposable([disposable, binder.disposable])
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
