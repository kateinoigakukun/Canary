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
    func inject<S: Store>(store: S) -> Disposable where S.Action == Action, S.State == State
}

extension View where Self: UIViewController {

    public func inject<S: Store>(store: S) -> Disposable where S.Action == Action, S.State == State {
        return _inject(store: store).1
    }
    func _inject<S: Store>(store: S) -> (Signal<State, NoError>, Disposable) where S.Action == Action, S.State == State {
        // FIXME
        _ = view

        let (stateOutput, stateInput) = Signal<State, NoError>.pipe()

        let binder = bind(state: stateOutput)
        let disposable = binder.action
            .withLatest(from: stateOutput)
            .flatMap(.concat) { action, state -> SignalProducer<(Action, State), NoError> in
                return SignalProducer(value: (action, state))
            }
            .flatMap(.concurrent(limit: 10)) { (action, state)in
                store.mutate(action: action, state: state).map { ($0, state) }
            }
            .flatMap(.concat) { mutation, state -> SignalProducer<(S.Mutation, State), NoError> in
                return SignalProducer(value: (mutation, state))
            }
            .map { store.reduce(mutation: $0.0, state: $0.1) }
            .observe(stateInput)

        stateInput.send(value: store.initialState)
        return (stateOutput, CompositeDisposable([disposable, binder.disposable]))
    }
}

extension View where Self: UIViewController, Self: Debuggable, State: Codable {
    public func inject<S: Store>(store: S) -> Disposable where S.Action == Action, S.State == State {
        let (state, disposable) = _inject(store: store)
        hookShake(state: state)
        return disposable
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

protocol Inputtable {
    associatedtype Input

    func input(with input: Input)
}

protocol Outputtable {
    associatedtype Output
    associatedtype State

    func output(state: Signal<State, NoError>) -> Signal<Output, NoError>
}

typealias IOble = Inputtable & Outputtable
