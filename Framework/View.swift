//
//  View.swift
//  Framework
//
//  Created by Yuta Saito on 2018/08/23.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import ReactiveSwift
import Result

protocol View {
    associatedtype Action
    associatedtype State

    func bind(state: Signal<State, NoError>) -> Binder<Action>
}

extension View {

    func inject<S: Store>(store: S) -> Disposable? where S.Action == Action, S.State == State {
        let (stateOutput, stateInput) = Signal<State, NoError>.pipe()
        let binder = bind(state: stateOutput)
        let disposable = binder.action
            .combineLatest(with: stateOutput)
            .flatMap(.concurrent(limit: 10)) { (action, state)in
                return store.mutate(action: action, state: state)
                    .combineLatest(with: stateOutput)
                    .map { store.reduce(mutation: $0.0, state: $0.1) }
            }
            .observe(stateInput)

        stateInput.send(value: store.initialState)
        return CompositeDisposable([disposable, binder.disposable])
    }
}

struct Binder<Action> {
    let action: Signal<Action, NoError>
    let disposable: Disposable
}
