//
//  Store.swift
//  Framework
//
//  Created by Yuta Saito on 2018/08/23.
//  Copyright © 2018年 bangohan. All rights reserved.
//

import ReactiveSwift
import Result

public protocol Store {
    associatedtype Action
    associatedtype Mutation
    associatedtype State

    var initialState: State { get }

    func mutate(action: Action, state: State) -> SignalProducer<Mutation, NoError>
    func reduce(mutation: Mutation, state: State) -> State
}
