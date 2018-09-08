//
//  OutputStore.swift
//  CanaryKit
//
//  Created by Yuta Saito on 2018/09/08.
//  Copyright © 2018年 bangohan. All rights reserved.
//

public enum ResultState<State, Result> {
    case state(State)
    case result(Result)

    public var state: State? {
        switch self {
        case .state(let state): return state
        default: return nil
        }
    }

    public var result: Result? {
        switch self {
        case .result(let result): return result
        default: return nil
        }
    }
}

public protocol OutputStore: Store where State == ResultState<PureState, Output> {
    associatedtype PureState
    associatedtype Output

    func reduce(mutation: Mutation, state: PureState) -> State
}

extension OutputStore {
    public func reduce(mutation: Mutation, state: State) -> State {
        switch state {
        case .result:
            return state
        case .state(let state):
            return reduce(mutation: mutation, state: state)
        }
    }
}
